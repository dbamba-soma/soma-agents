# État des lieux — septembre 2026

Constat établi par lecture du dépôt (98 fichiers, ~5 700 lignes, `main` à `ac77468`).
À réactualiser quand le périmètre bouge.

## Livré et fonctionnel

| Domaine | Contenu |
|---|---|
| One-to-one | Création par le manager, récurrence, humeur, notes partagées **et notes privées cloisonnées**, actions, vue consultant en préparation |
| Rôles & équipes | `super_admin` / `manager` / `consultant`, annuaire, promotion manager, rattachement d'équipe |
| Veille | Fil « 15 min pour apprendre », sources administrables, journal communautaire, votes, classement, enrichissement en français via GitHub Models |
| Contributions | Redirection vers l'application existante (`CONTRIBUTIONS_URL`) |
| Notifications | Panneau en application + moteur d'alertes planifié (rappels 24 h / 1 h, relance de préparation, retard) |
| Authentification | JWT local + SSO Azure AD, Graph délégué (agenda, envoi de mail), jetons chiffrés |
| Industrialisation | CI lint/tests/build + Gitleaks + Trivy, pre-commit, Dependabot groupé, Helm et manifests k3s prêts (non appliqués) |

## Non livré — annoncé dans l'interface

Trois entrées du menu latéral portent `soon: true` : **Newsletter**, **Suivi des DT**,
**Opportunités**. Elles sont visibles mais inertes. Pour une preview, c'est un choix à
assumer explicitement : soit on les retire, soit on affiche un écran « bientôt disponible »
qui décrit la cible. Une entrée qui ne réagit pas au clic dégrade la démonstration.

Les connecteurs **Boond Manager** (`BOOND_TOKEN`, `BOOND_CLIENT_TOKEN`, `BOOND_KEY`) et
**Teams app-only** sont déclarés dans la configuration et le chart Helm, mais **aucun code
ne les appelle**. Le champ `consultants.boond_id` existe et n'est jamais alimenté.

## Dette identifiée

| # | Constat | Effet | Sévérité |
|---|---|---|---|
| D-01 | **Aucun test front** (Vitest installé, zéro fichier) | Toute régression d'interface passe en production | majeure |
| D-02 | **`eslint` absent de la CI** alors que le script existe | La règle « zéro avertissement » n'est pas tenue | majeure |
| D-03 | **`mypy` non bloquant** (`|| true`) | Le typage se dégrade sans alerte | majeure |
| D-04 | **Aucune spec écrite** dans le dépôt (ni SFD, ni STD, ni ADR) | Les décisions ne sont retraçables que par le code | majeure |
| D-05 | Mot de passe d'amorçage `changeme` en clair | Acceptable en local, **inacceptable dès une exposition réseau** | bloquante hors local |
| D-06 | Deux routeurs volumineux (`veille.py` 590 l., `one_to_one.py` 427 l.) | Coût de relecture et de modification croissant | mineure |
| D-07 | 3 PR Dependabot ouvertes | Bruit, risque de dérive de versions | mineure |
| D-08 | `MAIL_OVERRIDE_RECIPIENT` | Si oublié actif, aucun e-mail ne part en démo ; si oublié inactif, les comptes de démo sont spammés | majeure en démo |

## Ce qu'il reste pour une première preview crédible

Par ordre de valeur démontrable par unité d'effort :

1. **Traiter les trois entrées `soon`** — les masquer, ou livrer un écran de présentation
   statique. Décision de périmètre : c'est au Business Analyst de la faire trancher.
2. **Scénario de démonstration reproductible** — jeu de données d'amorçage suffisant pour
   que chaque écran soit plein (un one-to-one passé, un à venir, un en retard ; des
   articles de veille votés ; une équipe de plusieurs consultants).
3. **Combler D-01/D-02/D-03** — premiers tests front sur les écrans de la démo, `eslint` et
   `mypy` branchés en CI. Une démo qui casse en direct coûte plus cher que le temps gagné.
4. **Sécuriser l'amorçage (D-05)** dès que la preview sort du poste local.
5. **Décider du sort des connecteurs Boond / Teams** : branchés pour de vrai, ou
   explicitement hors périmètre de la preview. Les laisser à moitié est la pire option.

Le lot 1 à 4 se traite avec les agents `business-analyst` → `senior-developer` →
`tech-lead` → `qa-tester` sans dépendance externe. Le lot 5 dépend d'accès (jetons Boond,
consentement administrateur Microsoft) qui ne se décident pas dans le dépôt.
