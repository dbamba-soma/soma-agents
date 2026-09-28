---
name: workflow-somanager
description: Règle du jeu de la chaîne d'agents Multica sur le projet somanager — qui passe la main à qui, quand solliciter l'initiateur (Dramane), format des commentaires et des questions, ouverture et fusion des PR, clôture des tickets. À charger en premier à chaque run d'un agent du projet somanager (business-analyst, senior-developer, tech-lead, qa-tester, preview-runner). Prime sur la fiche de l'agent en cas de conflit.
---

# Workflow somanager — la chaîne tourne seule

L'initiateur (Dramane) ne route rien, n'ouvre aucune PR, ne fusionne rien, ne clôt
aucun ticket. Il intervient **une seule fois par feature — la validation de la SFD** — et
sinon **uniquement sur blocage réel**. Tout le reste, c'est toi et les autres agents.

Tu n'as pas de mémoire entre deux runs : **lis tout le fil du ticket** (et la PR liée s'il
y en a une) avant d'agir, pour savoir où en est la chaîne.

## 1. La chaîne

```
Ticket (1 phrase) ─► business-analyst ─► ❓ Dramane valide la SFD ─► BA crée les lots
                                                                         │
      ┌──────────────────────────────────────────────────────────────────┘
      ▼   (par lot / sous-ticket)
senior-developer ─► tech-lead ─► qa-tester ─► tech-lead fusionne ─► preview-runner ─► done
        ▲               │NO-GO        │KO code
        └───────────────┴─────────────┘   (3 tours max, puis ❓ Dramane)
```

| Tu es | Tu reçois | Tu rends la main à |
|---|---|---|
| business-analyst | un ticket neuf | Dramane (validation SFD), puis crée les lots → senior-developer |
| senior-developer | un lot, ou un NO-GO / KO QA | tech-lead (PR ouverte, CI verte) |
| tech-lead (revue) | une PR | GO → qa-tester · NO-GO → senior-developer |
| qa-tester | une PR avec GO | OK → tech-lead · KO code → senior-developer · KO spec → business-analyst |
| tech-lead (fusion) | « QA OK » | fusionne, puis → preview-runner |
| preview-runner | une fusion sur `main` | passe le ticket en `done` |

**Passer la main = réassigner le ticket**, jamais une simple mention, jamais une
question « veux-tu que je transmette ? » :

```bash
multica issue assign <KEY> --to <agent>        # déclenche le run du suivant
```

Le ticket a toujours **un seul** porteur : l'agent qui doit agir maintenant. Poste ta
carte (§3) **avant** de réassigner.

## 2. Quand solliciter Dramane — et seulement là

| Situation | Statut du ticket | Qui reste assigné |
|---|---|---|
| SFD prête à valider (BA) | `in_review` | business-analyst |
| Blocage réel (liste ci-dessous) | `blocked` | toi |

Ne réassigne pas le ticket à Dramane : **tu restes assigné**, sa réponse en commentaire
te réveille. Blocage réel = uniquement :

- un accès, un secret ou un consentement que lui seul peut donner ;
- une décision métier **sans défaut raisonnable** (change le modèle de données, les
  droits, ou le périmètre promis) ;
- le **3ᵉ NO-GO ou KO QA** sur le même lot ;
- une CI rouge que personne dans la chaîne ne sait corriger ;
- une action destructive (suppression de données, production).

Tout le reste — choix technique, cas limite, libellé, ordre des lots, question de
fusion — **tu tranches** sur l'option la plus simple et réversible, et tu l'écris en
`[CHOIX PAR DÉFAUT]` dans la PR.

**Demande mineure** (bug, libellé, ajustement < ½ journée, sans changement de modèle
de données ni de droits) : pas de SFD à valider. Le BA écrit un cadrage de 5 lignes
dans le ticket, crée le lot et passe directement au senior-developer.

## 3. Format des commentaires sur le ticket — la carte

Tout commentaire sur le ticket tient en **5 lignes maximum**. Le détail (revue, plan de
test, sorties de commandes, diff) va **dans la PR** (`gh pr comment`, `gh pr review`) ou
dans un fichier du dépôt — jamais dans le ticket.

```
**✅ FAIT** — <ce qui est livré, en une phrase>
Toi : rien
Suite : @tech-lead — revue de la PR
Détail : PR #52 · docs/specs/SFD-03-xxx.md
```

Statuts possibles : `✅ FAIT`, `❓ DÉCISION` (on attend Dramane), `⛔ BLOQUÉ`,
`🔁 RETOUR` (renvoi dans la boucle dev/revue/QA). La ligne `Toi :` vaut **« rien »**
dans l'immense majorité des cas ; si elle ne vaut pas « rien », c'est que tu es dans un
cas du §2.

Pas de politesse, pas de récapitulatif de ce qu'a fait l'agent précédent, pas de
« vérifié à l'instant ». Pas de tableau dans le ticket.

## 4. Format des questions à Dramane

Au plus **3 questions par tour**, toujours à options, toujours avec un défaut :

```
**❓ DÉCISION** — SFD-03 prête, 2 points à trancher
Q1. Qui voit la newsletter avant envoi ? A) le manager seul  B) toute la practice  [défaut A]
Q2. Fréquence ? A) mensuelle  B) à la demande  [défaut A]
→ Réponds « ok » pour les défauts, ou « 1B », « 1B 2B »…
```

Interprétation de la réponse : `ok` / `go` / `valide` = tous les défauts ; `1B` = option
B pour Q1, défauts pour le reste ; texte libre = à intégrer, sans reposer la question
sauf contradiction. Ne redemande **jamais** une validation déjà donnée dans le fil.

## 5. Git et GitHub

- `gh` est disponible et authentifié en écriture (`gh auth status`). Si la commande est
  introuvable, utilise `/Users/ledream/bin/gh`. N'écris jamais « la PR reste à créer
  d'un clic » : tu la crées.
- **Une PR par lot**, ouverte par le senior-developer :
  `gh pr create --base main --title "<type>(<portée>): Lot <n> — <titre>" --body …`.
  Le corps contient : lien du ticket, SFD/STD concernées, mapping CA → test, les
  `[CHOIX PAR DÉFAUT]`.
- **La SFD voyage avec le code** : le BA pousse la SFD sur sa branche et indique son nom
  dans la description de chaque lot. Le senior-developer du premier lot l'intègre à sa
  branche (`git fetch origin && git merge --ff-only origin/<branche-sfd>` ou rebase) :
  la PR du lot embarque la SFD. Pas de PR de spec séparée. Une révision de SFD pendant
  un lot est commitée par le BA **sur la branche du lot en cours**.
- **Fusion** : par le tech-lead uniquement, après **GO tech-lead + OK QA + CI verte** :
  ```bash
  gh pr checks <n> --watch && gh pr merge <n> --rebase --delete-branch
  ```
  Historique linéaire, pas de commit de fusion. Personne ne demande à Dramane « qui
  fusionne ? » ni « je fusionne ? ».
- Toute la discussion technique (revue classée par sévérité, anomalies QA, réponses du
  dev) se fait **dans la PR**.

## 6. Boucle revue / QA

- Le tech-lead tient le compte des tours dans la PR (« Revue 1/3 », « Revue 2/3 »…).
  Un KO QA sur défaut de code compte comme un tour.
- `GO SOUS RÉSERVE` : le dev corrige, le tech-lead vérifie **les seuls points listés**
  (pas de nouvelle revue complète), puis passe au QA.
- Au 3ᵉ NO-GO/KO : le tech-lead passe le ticket en `blocked` et pose à Dramane **une**
  question à options (ex. A) accepter en l'état avec dette tracée B) réduire le lot
  C) arrêter).

## 7. Lots et clôture

- À la validation de la SFD, le BA crée les lots en sous-tickets **séquencés par stage** :
  ```bash
  multica issue create --parent <KEY> --stage <n> --project <projet> \
    --assignee senior-developer --title "Lot <n> — …" --description "SFD: <chemin> · branche: <branche-sfd> · CA couverts: …"
  ```
  Un lot = une intention = une PR. Les lots d'un même stage peuvent tourner en parallèle
  s'ils ne touchent pas les mêmes fichiers (migrations notamment) ; sinon, stages
  différents.
- Le ticket parent reste assigné au BA, statut `in_progress`. Quand Multica le réveille
  en fin de stage, le BA ne fait rien de plus que vérifier ; au dernier stage terminé, il
  passe le parent en `done` avec une carte de 3 lignes.
- Chaque lot est passé en `done` par le **preview-runner** après la preview.

## 8. Preview automatique après fusion

- Tout passe par `soma-agents/scripts/preview-somanager.sh` : dernière version de `main`
  dans `~/somanager-preview/repo`, arrêt de la preview précédente et de tout ce qui écoute
  sur 8012, base persistante `~/somanager-preview/data`, e-mails redirigés vers
  `dbamba@soma-smart.com`. URL toujours **http://localhost:8012/**.
- Le preview-runner poste une ligne (`✅ OK — …`), ou `⛔ KO` + journal et crée un ticket
  `Correctif preview — …` pour le senior-developer. Dans les deux cas, le lot passe en
  `done`.
- Aucun autre agent ne lance de preview ni n'occupe le port 8012.
