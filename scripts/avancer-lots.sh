#!/usr/bin/env bash
# Fait avancer une feature après la clôture d'un de ses lots, sans réveiller le BA.
#
#   avancer-lots.sh <KEY du lot qui vient de passer en done>
#
# Si toutes les étapes sont closes, le ticket parent passe en done. Sinon, les lots
# en backlog de la première étape encore ouverte passent en todo, ce qui démarre leur
# dev. Sortie : une ligne.
#
# Le lot passé en argument est tenu pour clos quel que soit le statut lu : l'agent qui
# appelle le script vient de le clore, mais la lecture des enfants peut encore renvoyer
# l'ancien statut (appel concurrent ou lecture périmée), ce qui bloquait le parent.
set -uo pipefail

KEY="${1:?usage: avancer-lots.sh <KEY>}"
PARENT=$(multica issue get "$KEY" --output json | python3 -c \
  "import json,sys; print(json.load(sys.stdin).get('parent_issue_id') or '')")
[ -n "$PARENT" ] || { echo "$KEY n'a pas de ticket parent : rien à faire"; exit 0; }

multica issue children "$PARENT" --output json | python3 -c '
import json, sys, subprocess
parent, lot = sys.argv[1], sys.argv[2]
closed = {"done", "cancelled"}
stages = sorted(json.load(sys.stdin).get("stages", []), key=lambda s: s.get("stage") or 0)
for st in stages:
    issues = st.get("issues", [])
    for i in issues:
        if i["identifier"] == lot:
            i["status"] = "done"
    if all(i["status"] in closed for i in issues):
        continue
    todo = [i for i in issues if i["status"] == "backlog"]
    for i in todo:
        subprocess.run(["multica", "issue", "status", i["identifier"], "todo"],
                       check=True, capture_output=True)
    if todo:
        print("étape %s démarrée : %s" % (st.get("stage"), ", ".join(i["identifier"] for i in todo)))
    else:
        print("étape %s en cours, rien à démarrer" % st.get("stage"))
    sys.exit(0)
subprocess.run(["multica", "issue", "status", parent, "done", "--no-start"],
               check=True, capture_output=True)
key = json.loads(subprocess.run(["multica", "issue", "get", parent, "--output", "json"],
                                check=True, capture_output=True, text=True).stdout)["identifier"]
print("tous les lots sont clos : %s passe en done" % key)
' "$PARENT" "$KEY"
