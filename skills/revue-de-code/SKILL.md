---
name: revue-de-code
description: Conduire une revue de code qui tranche — grille par axes (sécurité, conformité à la spec, correction, architecture, tests, lisibilité, performance, exploitabilité), classement par sévérité et verdict GO / NO-GO. À utiliser avant toute fusion, pour relire un diff ou une pull request, ou pour auditer l'état des garde-fous d'un repo.
---

# Revue de code

Une revue produit une **décision**, pas une liste d'impressions. Toute remarque porte une
sévérité, une conséquence concrète et un correctif.

## Méthode

1. **Délimiter** : `git diff`, la branche ou la PR. Ne relis pas ce qui n'a pas changé,
   sauf pour comprendre un impact.
2. **Récupérer la spec** (SFD / STD). Sans référence, tu ne peux juger que la forme — dis-le.
3. **Passer la grille** dans l'ordre : la sécurité avant le style, toujours.
4. **Exécuter la chaîne de qualité** du projet. Une revue qui ne lance rien est une lecture.
5. **Classer et trancher.**

## Grille

### 1. Sécurité et cloisonnement `BLOQUANT` par défaut
- [ ] Chaque route/endpoint a un contrôle d'accès **explicite**, jamais hérité par accident
- [ ] Les données sensibles sont filtrées **selon le rôle** avant sérialisation (pas côté front)
- [ ] Un utilisateur ne peut pas accéder à une ressource d'un autre en changeant un identifiant
- [ ] Aucun secret, jeton, mot de passe ou clé dans le code, les tests ou les fixtures
- [ ] Aucune donnée personnelle dans les logs, les URL ou les messages d'erreur
- [ ] Entrées validées côté serveur (types, bornes, longueurs) — la validation front ne compte pas
- [ ] Pas de concaténation de requête avec une entrée utilisateur

### 2. Conformité à la spec
- [ ] Chaque critère d'acceptation du lot est réellement implémenté
- [ ] Les règles de gestion sont appliquées là où la spec le dit
- [ ] Les écarts assumés sont documentés dans le compte rendu, pas découverts en revue

### 3. Correction
- [ ] Cas limites traités : liste vide, valeur nulle, doublon, suppression, concurrence
- [ ] Erreurs gérées et remontées avec le bon code, pas avalées silencieusement
- [ ] Dates et fuseaux horaires cohérents (stockage en UTC, conversion à l'affichage)
- [ ] Transactions correctement bornées ; pas d'écriture partielle possible
- [ ] Pas d'état global mutable introduit

### 4. Architecture
- [ ] La modification suit le découpage existant (couche, module, routeur, dossier)
- [ ] Pas de deuxième façon de faire une chose déjà faite ailleurs
- [ ] Pas de couplage nouveau entre modules qui devaient rester indépendants
- [ ] La logique métier n'est pas dupliquée entre back et front
- [ ] Dépendance ajoutée : justifiée, maintenue, licence compatible

### 5. Tests
- [ ] Les chemins critiques et les **refus de droits** sont testés
- [ ] Les tests vérifient un comportement observable, pas une implémentation
- [ ] Les tests peuvent échouer (pas d'assertion tautologique, pas de test ignoré)
- [ ] Pas de dépendance au réseau réel, à l'ordre d'exécution ou à l'horloge

### 6. Lisibilité et cohérence
- [ ] Nommage explicite, dans la langue du repo
- [ ] Densité de commentaires alignée sur le voisinage ; les commentaires disent *pourquoi*
- [ ] Pas de code mort, d'import inutile, de `TODO` sans suite
- [ ] Pas de reformatage massif noyant le diff utile

### 7. Performance
- [ ] Pas de requête dans une boucle (N+1) — vérifie les relations chargées
- [ ] Pagination ou limite là où la volumétrie croît
- [ ] Appels externes bornés : timeout, nombre de tentatives, dégradation gracieuse
- [ ] Pas de travail lourd dans le cycle de requête sans raison

### 8. Exploitabilité
- [ ] Journalisation utile au diagnostic, sans bruit ni données personnelles
- [ ] Messages d'erreur actionnables pour l'utilisateur
- [ ] Migration réversible, ou irréversibilité assumée et signalée
- [ ] Nouvelle configuration documentée (fichier d'exemple, README)

## Signaux d'alerte — toujours `BLOQUANT`

- Une règle de lint désactivée, un test ignoré, une assertion vidée, un seuil abaissé
  **dans le même lot** que la feature.
- Un contrôle de qualité qui existe mais n'est pas branché dans la CI.
- Un changement de modèle sans migration.
- Un secret, même de test, commité.

## Format du rapport

```
## Verdict : GO / GO SOUS RÉSERVE / NO-GO

### Bloquants
1. `chemin/fichier.py:42` — <ce qui ne va pas>
   Conséquence : <scénario d'échec concret>
   Correctif : <une à deux lignes>

### Majeurs
…

### Mineurs
…

### Pistes (hors périmètre, à verser au backlog)
…

### Contrôles exécutés
<commandes lancées et résultat réel>
```

Un lot propre se dit en une ligne : « GO — rien à signaler, contrôles verts. »
