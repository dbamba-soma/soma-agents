# Analyse de `dbamba-soma/somanager-cockpit` — quels agents et skills pour la première preview

Lecture du dépôt au commit `ac77468` (branche `main`) : 98 fichiers, ~5 700 lignes.
Ce document justifie le choix des agents et des skills livrés ici.

## 1. Ce que le dépôt impose

| Constat | Conséquence sur l'outillage |
|---|---|
| Stack double : FastAPI async + React/TS, une seule image en production | Les agents doivent connaître **deux** jeux de conventions → skill projet avec deux fichiers de référence |
| Cloisonnement de données sensibles (notes privées d'entretien, ressenti) | La sécurité passe avant le style dans la grille de revue ; matrice de droits obligatoire en spec et en test |
| Rôles multiples (`super_admin`, `manager`, `consultant`) avec routage front par rôle | Toute SFD porte une matrice de droits complète ; tout plan de test couvre les **refus** |
| Migrations appliquées au démarrage | Une migration cassée empêche le lancement → point bloquant explicite en revue |
| Services externes dégradables (Azure AD, Graph, IA de veille) | Les tests doivent rester hermétiques ; la démo ne doit pas reposer sur un service dégradé |
| Configuration lue à l'import | Piège de test à documenter, sinon chaque nouveau test est fragile |
| Commits conventionnels en français, commentaires en français | Les agents produisent en français |
| **Aucune spec, aucun ADR dans le dépôt** | C'est le trou principal : d'où un agent BA et deux skills de spécification |
| **Aucun test front**, `eslint` hors CI, `mypy` non bloquant | D'où un agent testeur avec des patterns Vitest prêts à poser, et un tech lead qui traite un garde-fou débranché comme une dette |
| 3 entrées de menu `soon: true` (Newsletter, Suivi des DT, Opportunités) | Décision de périmètre à faire trancher avant la preview → travail du BA |
| Connecteurs Boond et Teams déclarés mais jamais appelés | Dépendance externe : à sortir du périmètre de la preview ou à obtenir |

## 2. Les quatre agents demandés, et ce qu'ils traitent ici

### `business-analyst`
Le dépôt ne contient aucune spécification : les règles de gestion ne sont lisibles que dans
le code. Le premier travail utile est de **faire trancher le périmètre de la preview** —
notamment le sort des trois entrées de menu inertes et des connecteurs non branchés — puis
de produire des SFD pour les lots retenus. D'où un agent qui challenge avant d'écrire, et
qui pose des questions avec hypothèse par défaut pour ne jamais bloquer.

### `senior-developer`
Le code existant est homogène et idiomatique : le risque principal n'est pas la
compétence, c'est **la divergence de style et la sécurité oubliée** sur une nouvelle route.
D'où un agent qui charge les conventions projet avant d'écrire, exige une migration pour
tout changement de schéma, un contrôle d'accès explicite par route, et qui **rapporte la
sortie réelle** de la chaîne de qualité plutôt que de la supposer.

### `tech-lead`
Les garde-fous existent mais deux sont débranchés (`mypy || true`, `eslint` hors CI). Un
tech lead qui ne fait que relire du code passerait à côté. D'où une grille qui inclut
l'**état des garde-fous** et qui classe comme bloquant tout affaiblissement de contrôle
(règle désactivée, test ignoré, assertion vidée) livré dans le même lot qu'une feature.

### `qa-tester`
Déficit net côté front (Vitest installé, zéro test) et enjeu fort de cloisonnement côté
API. D'où un agent qui **trace chaque critère d'acceptation vers un test**, impose la
matrice de droits avec ses refus, teste l'**absence** des champs sensibles pour les rôles
non autorisés, et pose les premiers patterns Vitest proprement.

## 3. Les skills, et pourquoi celles-là

| Skill | Problème du dépôt qu'elle résout |
|---|---|
| `spec-fonctionnelle` | Aucune spec existante : il faut un format imposé, avec critères testables et matrice de droits, sinon chacun improvise |
| `spec-technique` | Décisions structurantes (Graph délégué, chiffrement des jetons, moteur d'alertes idempotent) non tracées : ADR + STD |
| `revue-de-code` | Grille générique + vigilances FastAPI async et React qui correspondent aux pièges réels du dépôt (N+1, appel bloquant, droits côté front) |
| `strategie-de-test` | Patterns pytest/httpx recopiés de l'existant + patterns Vitest à poser, matrice de droits |
| `somanager-cockpit` | Toute la connaissance projet, y compris l'état des lieux et la dette chiffrée — le seul fichier à réécrire pour un autre dépôt |
| `preview-locale` | Une preview se rate sur un écran vide ou un menu inerte, pas sur le code : checklist et scénario minuté |

## 4. Chemin proposé vers la première preview

| Étape | Agent | Livrable | Dépendance |
|---|---|---|---|
| 1. Arbitrer le périmètre de la preview (entrées `soon`, connecteurs) | `business-analyst` | Note de périmètre + questions à l'initiateur | Tes réponses |
| 2. SFD des lots retenus | `business-analyst` | `docs/specs/SFD-01…` | Étape 1 |
| 3. STD + estimation par lot | `senior-developer` | `docs/specs/STD-01…` + écarts renvoyés au BA | Étape 2 |
| 4. Implémentation par lots | `senior-developer` | Branche + commits + tests | Étape 3 |
| 5. Brancher `eslint` et `mypy` en CI, premiers tests front | `senior-developer` + `qa-tester` | CI durcie, tests des écrans de démo | Aucune |
| 6. Revue | `tech-lead` | Rapport + verdict | Étapes 4 et 5 |
| 7. Recette + scénario de démonstration | `qa-tester` + `preview-locale` | Plan de test, anomalies, scénario minuté | Étape 6 |

Les étapes 1 à 7 ne dépendent d'aucun accès externe. Le branchement réel de **Boond** et de
**Teams app-only** dépend de jetons et d'un consentement administrateur Microsoft : à
traiter comme un lot post-preview, ou à débloquer en parallèle.
