# STD-<NN> — <Titre>

| | |
|---|---|
| **SFD source** | SFD-<NN> |
| **Auteur** | Senior Developer |
| **Date** | <AAAA-MM-JJ> |
| **Estimation totale** | <n> j |

## 1. Compréhension et écarts

Reformulation en 5 lignes de ce qui est à construire.
Puis les **points renvoyés au Business Analyst** :

| # | Point | Impact | Option recommandée | Statut |
|---|---|---|---|---|
| D-01 | | | | ouvert / tranché |

## 2. Conception générale

Comment la feature s'insère dans l'existant : quels modules touchés, quel flux de bout en
bout (déclencheur → traitement → persistance → affichage). Un schéma texte si utile.

## 3. Modèle de données

### Tables / champs

| Table | Champ | Type | Contraintes | Index | Commentaire |
|---|---|---|---|---|---|
| | | | | | |

### Migration

- Opérations : …
- Données existantes : valeur par défaut / rétro-remplissage / nullable
- Réversibilité : …

## 4. Contrats d'API

### `<MÉTHODE> /api/<chemin>`

- **Rôle requis** : …
- **Entrée** : champs, types, obligatoires, validations
- **Sortie 2xx** : forme de la réponse
- **Erreurs** : `400` … / `401` … / `403` … / `404` … / `409` …
- **Règles appliquées** : RG-xx, RG-yy
- **Critères couverts** : CA-xx

## 5. Front

| Écran / composant | Rôle | Données consommées | États (chargement, vide, erreur) |
|---|---|---|---|
| | | | |

Navigation et points d'entrée modifiés : …

## 6. Sécurité

- Contrôle d'accès par endpoint : …
- Données sensibles filtrées selon le rôle : …
- Validation des entrées, limites de taille : …
- Journalisation : ce qui est tracé, ce qui ne doit PAS l'être

## 7. Performance et volumétrie

- Volumes attendus : …
- Requêtes à risque (boucles, agrégats, jointures) et parade : …
- Appels externes : timeout, nombre de tentatives, comportement en cas d'indisponibilité

## 8. Configuration et secrets

| Clé | Usage | Valeur par défaut | Sensible |
|---|---|---|---|
| | | | |

À reporter dans le fichier d'exemple d'environnement du projet.

## 9. Lots d'implémentation

| Lot | Contenu | Livrable indépendant | Estimation | Dépendances |
|---|---|---|---|---|
| L1 | | oui/non | | |

## 10. Tests attendus

| CA | Niveau (API / unitaire / front) | Cas à couvrir |
|---|---|---|
| CA-01 | | |

## 11. Hors périmètre technique

Ce qui est volontairement non fait, et ce que ça coûtera plus tard.

## 12. Alternatives écartées

| Option | Pourquoi écartée |
|---|---|
| | |
