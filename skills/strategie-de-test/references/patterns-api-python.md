# Patterns de test d'API — Python / pytest / httpx / FastAPI async

Patterns en vigueur sur `somanager-cockpit`. Les reproduire tels quels : ne pas introduire
une seconde mécanique de test.

## Isolation

Une base éphémère par module de test, configurée **avant** le premier import de
l'application (la configuration est lue à l'import) :

```python
@pytest.fixture(scope="module", autouse=True)
def _env(tmp_path_factory: pytest.TempPathFactory) -> None:
    db = tmp_path_factory.mktemp("data") / "<module>.db"
    os.environ["DATABASE_URL"] = f"sqlite+aiosqlite:///{db}"
    os.environ["ENVIRONMENT"] = "test"
    os.environ["JWT_SECRET"] = "test-secret"
```

Le `conftest.py` racine neutralise les identifiants externes (SSO, jetons d'IA, redirection
de mail) pour que les tests soient hermétiques même avec un `.env` local présent. **Toute
nouvelle variable sensible doit y être ajoutée**, sinon la machine d'un développeur teste
autre chose que la CI.

## Client

Client HTTP en mémoire sur l'application, avec le cycle de vie applicatif (migrations et
amorçage des données de démo inclus) :

```python
@pytest.fixture(scope="module")
async def client():
    from backend.main import app, lifespan
    async with lifespan(app):
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as ac:
            yield ac
```

`asyncio_mode = "auto"` est configuré : pas besoin de décorer chaque test.

## Authentification

Helpers courts, un par rôle testé :

```python
async def _hdr(client: AsyncClient, email: str) -> dict[str, str]:
    res = await client.post("/api/auth/login", json={"email": email, "password": "changeme"})
    assert res.status_code == 200, res.text
    return {"Authorization": f"Bearer {res.json()['access_token']}"}
```

Comptes amorcés en développement/test : le super admin, et les consultants de démo
(l'un rattaché à une équipe, l'un sans équipe). S'appuyer dessus plutôt que de créer des
utilisateurs à la main, sauf si le cas testé l'exige.

## Conventions

- Assertions avec le corps en message : `assert res.status_code == 200, res.text` — sinon
  un échec en CI n'est pas diagnosticable.
- Un test nommé par le comportement : `test_consultant_ne_voit_pas_les_notes_privees`.
- Tester l'**absence** d'un champ sensible, pas seulement sa présence pour l'autorisé :
  `assert "private_notes" not in payload`.
- Services externes (Graph, IA, flux) : neutralisés par variable d'environnement vide, ou
  remplacés par une doublure respectant le contrat réel (codes de statut compris).
- Ne pas dépendre de l'ordre : chaque test crée ce dont il a besoin, ou le module documente
  explicitement son enchaînement.

## Exécution

```bash
pytest -q                        # suite complète
pytest -q tests/test_x.py -k nom # ciblé
ruff check backend tests         # lint (bloquant en CI)
mypy backend                     # types (non bloquant en CI — le traiter quand même)
```
