# Backend — patterns en vigueur

## Structure d'un routeur

```python
router = APIRouter(prefix="/<domaine>", tags=["<domaine>"])

@router.get("/", response_model=list[XxxOut])
async def list_xxx(
    user: User = Depends(require_manager),      # rôle TOUJOURS explicite
    db: AsyncSession = Depends(get_db),
) -> list[Xxx]:
    ...
```

Routeurs existants et préfixes (tous montés sous `/api` dans `main.py`) :

| Routeur | Préfixe | Rôle dominant |
|---|---|---|
| `health` | *(aucun)* | public |
| `auth` | `/auth` | public (login) |
| `sso` | `/auth/sso` | public (redirections Azure AD) |
| `admin` | `/admin` | `require_super_admin` |
| `team` | `/team` | `require_manager` |
| `notifications` | `/me/notifications` | utilisateur courant |
| `integrations` | `/graph` | utilisateur courant (jeton délégué) |
| `app_config` | `/config` | lecture |
| `veille` | `/veille` | mixte |
| `one_to_one` | *(aucun)* — `/one-to-ones`, `/consultants` | manager / consultant cloisonnés |

Ajouter un routeur : le créer dans `backend/routers/`, l'importer et le monter dans
`main.py` avec le préfixe `/api`, **avant** le repli SPA.

## Modèles et migrations

Modèles dans `backend/models.py` (`users`, `consultants`, `one_to_ones`,
`one_to_one_actions`, `notifications`, `ms_token_cache`, `veille_items`,
`veille_interests`, `veille_feed_items`, `veille_votes`, `veille_sources`, `alerts_sent`).

Règles :
- Une révision Alembic par changement, numérotée (`0009_<slug>.py`), avec `downgrade`.
- Vérifier la migration sur une base **existante**, pas seulement vide.
- Colonne ajoutée sur une table peuplée : `nullable=True` ou valeur par défaut serveur.

## Schémas

`backend/schemas.py` : schémas d'entrée et de sortie séparés. **Deux publics = deux schémas
de sortie** (par exemple vue manager avec notes privées vs. vue consultant sans). Ne jamais
s'en remettre au front pour masquer un champ.

## Authentification

- JWT HS256, 8 h, `sub` = e-mail. `backend/auth.py` : hachage, création et lecture du jeton.
- SSO Azure AD (MSAL) : `routers/sso.py`, jeton renvoyé au front dans le fragment d'URL.
- Graph délégué (`User.Read`, `Calendars.ReadWrite`, `Mail.Send`) : `graph.py` +
  `graph_token.py`, jetons de rafraîchissement chiffrés (Fernet) en base.
- Dégradation attendue : sans identifiants Azure, l'application fonctionne, les
  fonctionnalités déléguées sont inertes. **Conserver ce comportement** : aucune nouvelle
  dépendance dure à un service externe.

## Tâches planifiées

`backend/scheduler.py` (APScheduler, toutes les 15 min, démarré dans le lifespan) :
alertes one-to-one. Modèle à suivre pour toute nouvelle tâche —

- **décision pure et testable sans I/O** (`due_alerts`), séparée de la livraison ;
- **livraison idempotente** via une table de trace (`alerts_sent`, une ligne par
  (objet, type d'alerte)) ;
- notification en base **toujours** créée, e-mail en meilleur effort ;
- arrêt propre dans le lifespan.

## Style

- `from __future__ import annotations` en tête de module.
- Types de retour annotés sur les fonctions publiques ; `dict[str, str]`, `list[X]`, `X | None`.
- Docstring de module expliquant le rôle et les choix, en français.
- Journalisation via `logging.getLogger("somanager")`, sans données personnelles.
- Pas d'appel bloquant dans une route `async`.
