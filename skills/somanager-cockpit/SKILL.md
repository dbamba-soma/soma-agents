---
name: somanager-cockpit
description: Connaissance du projet SOManager Cockpit — architecture FastAPI async + React/Vite/TypeScript, conventions de code, rôles et cloisonnement des données, chaîne de qualité, état des lieux et reste à faire pour la preview. À charger avant toute analyse, spécification, développement, revue ou test sur le dépôt somanager-cockpit, afin de produire du code et des specs cohérents avec l'existant.
---

# SOManager Cockpit — conventions projet

Application de suivi des consultants pour les managers SOMA : one-to-one, contributions,
veille « 15 min pour apprendre », newsletter de practice, suivi des Dossiers Techniques,
opportunités.

Approche **local-first** : tout tourne en local ; le déploiement on-prem (k3s) est préparé
mais différé (Phase B).

## Architecture

```
backend/    FastAPI : main.py (lifespan : migrations + amorçage + statique), routers/,
            models.py, schemas.py, auth.py, permissions.py, config.py, secrets.py,
            graph.py + graph_token.py (Microsoft Graph délégué), scheduler.py (alertes),
            veille_feed.py, ai.py
frontend/   React 19 + Vite + TypeScript → build dans dist/, servi par FastAPI
alembic/    migrations, appliquées automatiquement au démarrage
tests/      pytest (API), backend uniquement à ce jour
deploy/ k8s/  Helm + manifests (Phase B, non appliqués)
```

Une seule image en production : le backend sert le build du front avec repli SPA.

## Règles structurantes

1. **Rôles** : `super_admin` (aussi manager), `manager`, `consultant`. `admin` est toléré
   pour rétrocompatibilité. Les dépendances de sécurité sont dans `backend/permissions.py`
   (`require_manager`, `require_super_admin`, `require_consultant`) — **toute nouvelle
   route en déclare une**.
2. **Cloisonnement** : les notes privées d'un one-to-one ne sortent jamais vers le
   consultant. Toute donnée à sensibilité RH se filtre **côté serveur**, par le rôle.
3. **Configuration** : tout passe par `backend/config.py` → `get_secret` (fichier secret ou
   variable d'environnement). Aucune valeur sensible en dur, jamais. Toute nouvelle clé est
   ajoutée à `backend/.env.example`.
4. **Schéma** : tout changement de modèle → migration Alembic numérotée
   (`alembic/versions/000N_<slug>.py`). Les migrations s'appliquent au démarrage : une
   migration cassée casse le lancement.
5. **Langue** : code, commentaires, libellés d'interface et messages d'erreur en français.
   Les docstrings expliquent le *pourquoi*, pas le *quoi*.
6. **Commits** : conventionnels, en français — `feat(veille): …`, `fix(ci): …`, `chore(deps): …`.

Détail des patterns : `references/backend.md` et `references/frontend.md`.
État des lieux, manques et périmètre de preview : `references/etat-des-lieux.md`.

## Chaîne de qualité

```bash
ruff check backend tests                        # bloquant en CI
mypy backend                                    # non bloquant en CI (`|| true`) — à traiter quand même
pytest -q                                       # bloquant
cd frontend && npm run typecheck && npm run build   # bloquants
cd frontend && npm run lint                     # existe, PAS branché en CI
cd frontend && npm run test                     # Vitest installé, AUCUN test écrit
pre-commit install                              # ruff, ruff-format, gitleaks, hygiène fichiers
```

Réglages : ruff `line-length = 100`, cible `py311`, règles `E,F,I,UP,B,C4,SIM` (`B008`
ignoré — idiome `Depends()`). pytest en `asyncio_mode = "auto"`, `pythonpath = ["."]`.

CI (`.github/workflows/ci.yml`) : backend (lint, types, tests) · frontend (typecheck,
build) · sécurité (Gitleaks, Trivy `CRITICAL,HIGH` bloquant). CD sous `if: false`, Phase B.

**Deux garde-fous sont débranchés** : `mypy` avec `|| true`, et `eslint` absent de la CI.
Ne pas s'en servir comme prétexte : un lot doit passer `mypy` et `eslint` avant d'être rendu.

## Démarrage local

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r backend/requirements-dev.txt
uvicorn backend.main:app --reload --port 8002      # http://127.0.0.1:8002
cd frontend && npm install && npm run dev          # http://127.0.0.1:5173 (proxy /api → 8002)
```

Comptes amorcés hors production : super admin `dbamba@soma-smart.com`, consultants de démo
`alice.martin@` (rattachée à une équipe), `bob.durand@` et `chloe.dubois@` (sans équipe) —
mot de passe `changeme`. L'amorçage est idempotent et désactivé en production.

## Pièges connus

- La configuration est lue **à l'import** : dans les tests, poser les variables
  d'environnement avant le premier import de `backend.config` (cf. `tests/conftest.py`).
- `tests/conftest.py` neutralise les identifiants externes pour rendre les tests
  hermétiques. **Toute nouvelle variable sensible doit y être ajoutée**, sinon un `.env`
  local fait diverger la machine du développeur et la CI.
- Le repli SPA capture toutes les routes non `/api` : une nouvelle route API doit être
  montée avant, sous le préfixe `/api`.
- Les jetons de rafraîchissement Graph sont chiffrés (Fernet, `TOKEN_ENC_KEY`) : sans clé,
  les fonctions déléguées (agenda, envoi de mail) se dégradent silencieusement.
- `MAIL_OVERRIDE_RECIPIENT` redirige **tout** e-mail sortant : indispensable en test,
  dangereux si on l'oublie activé en démo.
