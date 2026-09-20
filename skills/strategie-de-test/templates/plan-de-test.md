# PT-<NN> — Plan de test « <Fonctionnalité> »

| | |
|---|---|
| **SFD source** | SFD-<NN> |
| **Auteur** | Testeur |
| **Date** | <AAAA-MM-JJ> |
| **Périmètre** | <lots couverts> |

## 1. Traçabilité critères → tests

| CA | Cas de test | Niveau | Fichier | Statut |
|---|---|---|---|---|
| CA-01 | T-01a — <intitulé> | API | `tests/test_x.py::test_…` | vert / rouge / à écrire |

Tout `CA` sans ligne est un trou de couverture : le signaler explicitement.

## 2. Matrice de droits

| Action | anonyme | consultant (propriétaire) | consultant (autre) | manager | super_admin |
|---|---|---|---|---|---|
| | | | | | |

## 3. Cas limites

| # | Situation | Attendu | Statut |
|---|---|---|---|
| T-L01 | Liste vide | | |
| T-L02 | Valeur nulle / champ absent | | |
| T-L03 | Doublon | | |
| T-L04 | Chaîne très longue, accents, émojis | | |
| T-L05 | Double soumission | | |
| T-L06 | Service externe indisponible | | |

## 4. Régression

Fonctionnalités existantes touchées par le même code, et tests qui les couvrent.

## 5. Rapport d'exécution

```
<commande lancée>
<sortie réelle : total, verts, rouges, durée>
```

| Suite | Tests | Verts | Rouges | Durée |
|---|---|---|---|---|
| API | | | | |
| Front | | | | |

## 6. Anomalies

```
ANO-01 — <titre court>
Sévérité   : bloquante / majeure / mineure
Nature     : défaut de code / défaut de spec / défaut d'environnement
Contexte   : rôle, jeu de données, endpoint ou écran
Étapes     : 1. … 2. … 3. …
Attendu    : (CA-xx / RG-xx)
Obtenu     : (sortie réelle)
Piste      : (optionnel)
```

## 7. Avis de recette

**RECETTE OK / OK AVEC RÉSERVES / REFUSÉE** — et les conditions de levée des réserves.
