#!/usr/bin/env bash
# Preview locale de somanager-cockpit, toujours sur http://localhost:8012/.
#
# Déploie la dernière version de main dans un checkout dédié, tue la preview
# précédente (et tout ce qui écoute sur 8012), relance, puis vérifie la santé et
# la connexion des comptes de démo. Sortie : une ligne OK, ou KO + fin du journal.
#
#   ~/somanager-preview/repo          checkout dédié (réservé à ce script)
#   ~/somanager-preview/.env          secrets de la preview (non versionné)
#   ~/somanager-preview/data/         base SQLite persistante
#   ~/somanager-preview/preview.log   journal du serveur
#   ~/somanager-preview/pid           PID du serveur
set -uo pipefail

PORT=8012
URL="http://localhost:${PORT}"
HOME_DIR="${SOMANAGER_PREVIEW_HOME:-$HOME/somanager-preview}"
REPO="$HOME_DIR/repo"
LOG="$HOME_DIR/preview.log"
PIDFILE="$HOME_DIR/pid"
REMOTE="https://github.com/dbamba-soma/somanager-cockpit.git"
# Comptes amorcés par backend/main.py (hors production), mot de passe par défaut.
ACCOUNTS="dbamba@soma-smart.com alice.martin@soma-smart.com bob.durand@soma-smart.com chloe.dubois@soma-smart.com"

ko() {
  echo "KO — $1"
  [ -f "$LOG" ] && { echo "--- fin du journal ($LOG)"; tail -n 30 "$LOG"; }
  exit 1
}

mkdir -p "$HOME_DIR/data"
[ -f "$HOME_DIR/.env" ] || ko "fichier $HOME_DIR/.env absent"

# 1. Code : dernière version de main
if [ ! -d "$REPO/.git" ]; then
  git clone -q "$REMOTE" "$REPO" || ko "clone impossible"
fi
cd "$REPO" || ko "checkout introuvable"
git fetch -q origin main && git reset -q --hard origin/main && git clean -qfd -e .venv -e frontend/node_modules \
  || ko "mise à jour de main impossible"
COMMIT=$(git log -1 --format='%h %s' | cut -c1-70)
ln -sf "$HOME_DIR/.env" backend/.env

# 2. Dépendances, réinstallées seulement si leur verrou a changé
stamp() { shasum "$@" 2>/dev/null | shasum | cut -c1-12; }
[ -x .venv/bin/python ] || python3 -m venv .venv || ko "création du venv impossible"
PY_STAMP=$(stamp backend/requirements.txt)
if [ "$(cat .venv/.stamp 2>/dev/null)" != "$PY_STAMP" ]; then
  .venv/bin/pip install -q -r backend/requirements.txt >"$LOG" 2>&1 || ko "pip install"
  echo "$PY_STAMP" > .venv/.stamp
fi
JS_STAMP=$(stamp frontend/package-lock.json)
if [ "$(cat frontend/node_modules/.stamp 2>/dev/null)" != "$JS_STAMP" ]; then
  (cd frontend && npm ci --silent) >"$LOG" 2>&1 || ko "npm ci"
  echo "$JS_STAMP" > frontend/node_modules/.stamp
fi
(cd frontend && npm run -s build) >"$LOG" 2>&1 || ko "build du front"
[ -f frontend/dist/index.html ] || ko "build du front sans index.html"

# 3. Arrêt de la preview précédente, puis de tout ce qui tient encore le port
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
sleep 1
PIDS=$(lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null)
[ -n "$PIDS" ] && kill $PIDS 2>/dev/null && sleep 2
PIDS=$(lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null)
[ -n "$PIDS" ] && kill -9 $PIDS 2>/dev/null && sleep 1
lsof -tiTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1 && ko "port $PORT toujours occupé"

# 4. Démarrage (les variables exportées priment sur backend/.env)
export ENVIRONMENT=development
export DATABASE_URL="sqlite+aiosqlite:///$HOME_DIR/data/somanager.db"
export MAIL_OVERRIDE_RECIPIENT=dbamba@soma-smart.com
export FRONTEND_BASE_URL="$URL"
export AZURE_REDIRECT_URI="$URL/api/auth/sso/callback"
nohup .venv/bin/uvicorn backend.main:app --host 127.0.0.1 --port $PORT >"$LOG" 2>&1 &
echo $! > "$PIDFILE"
disown

# 5. Vérifications
for _ in $(seq 1 60); do
  curl -fs "$URL/api/health" >/dev/null 2>&1 && break
  kill -0 "$(cat "$PIDFILE")" 2>/dev/null || ko "le serveur s'est arrêté au démarrage"
  sleep 1
done
curl -fs "$URL/api/health" >/dev/null || ko "/api/health ne répond pas après 60 s"
curl -fs "$URL/" | grep -qi "<div id=\"root\"" || ko "la page d'accueil ne sert pas le front"

FAILED=""
for email in $ACCOUNTS; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$URL/api/auth/login" \
    -H 'Content-Type: application/json' -d "{\"email\":\"$email\",\"password\":\"changeme\"}")
  [ "$code" = "200" ] || FAILED="$FAILED $email($code)"
done
[ -z "$FAILED" ] || ko "connexion refusée :$FAILED"
grep -qE "Traceback|ERROR" "$LOG" && ko "erreur dans le journal au démarrage"

echo "OK — preview à jour sur $URL/ — $COMMIT"
