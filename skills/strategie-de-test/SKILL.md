---
name: strategie-de-test
description: Construire et exécuter une stratégie de test utile — traçabilité critère d'acceptation → cas de test, matrice de droits, cas limites, tests d'API et de composants, qualification des anomalies. À utiliser pour écrire des tests sur une feature qui vient d'être développée, combler un déficit de couverture, ou préparer la recette d'une preview.
---

# Stratégie de test

Un test vert ne prouve rien s'il ne pouvait pas devenir rouge. La valeur d'une suite se
mesure aux défauts qu'elle attrape, pas au nombre de lignes couvertes.

## Ce qu'on teste, par ordre de priorité

1. **Les refus.** 401 sans jeton, 403 avec le mauvais rôle, accès à la ressource d'autrui.
   C'est là que se logent les vraies fuites, et c'est ce qui est le moins testé.
2. **Les règles de gestion.** Une par une, avec les valeurs de la spec.
3. **Les cas limites.** Vide, nul, doublon, très long, accentué, concurrent, en bord de page.
4. **Les erreurs.** Entrée invalide, ressource absente, dépendance externe indisponible.
5. **Le chemin nominal.** Nécessaire, mais le moins informatif : ne commence pas par lui.

## Pyramide adaptée aux projets SOMA

| Niveau | Cible | Quand |
|---|---|---|
| **Test d'API (majoritaire)** | Endpoint réel via un client HTTP en mémoire, base éphémère | Défaut : toute règle métier et tout droit |
| **Test unitaire** | Fonction pure complexe (calcul, agrégat, formatage, parsing) | Quand la logique mérite d'être isolée |
| **Test de composant front** | Rendu et interactions d'un écran, API simulée | États chargement / vide / erreur, logique d'affichage |
| **Bout en bout** | Parcours complet dans un navigateur | Rare : 1 à 3 parcours de démo, pas plus |

Le test d'API porte l'essentiel : il traverse routage, validation, droits, persistance et
sérialisation en une fois, pour un coût d'écriture faible.

## Matrice de droits — obligatoire

Pour chaque ressource, un tableau exhaustif rôle × action, **y compris les refus** :

| Action | anonyme | consultant (propriétaire) | consultant (autre) | manager | super_admin |
|---|---|---|---|---|---|
| Lire | 401 | 200 | 403 | 200 | 200 |
| Créer | 401 | 403 | 403 | 201 | 201 |
| Modifier | 401 | 200 (champs limités) | 403 | 200 | 200 |
| Supprimer | 401 | 403 | 403 | 204 | 204 |

Chaque case donne un test. Les cases de refus ne sont pas optionnelles.

Ajoute le **cloisonnement champ par champ** : une donnée réservée à un rôle (note privée,
évaluation, ressenti) fait l'objet d'un test qui vérifie son **absence** dans la réponse
de l'autre rôle. Vérifier la présence ne suffit pas.

## Règles d'écriture

- **Suivre les patterns du repo** : fixtures, isolation de base, client, nommage. Ne crée
  jamais une deuxième façon de tester. Voir `references/patterns-api-python.md` et
  `references/patterns-front-vitest.md`.
- Un test = un comportement, nommé par ce qu'il vérifie.
- Déterminisme : pas de réseau réel, pas d'horloge système non maîtrisée, pas de dépendance
  à l'ordre d'exécution ni à l'état d'un test précédent.
- Les doublures de services externes respectent le **vrai contrat** : mêmes codes, mêmes
  formes de réponse, erreurs comprises.
- **Vérifie qu'un test peut échouer** avant de le considérer fini.

## Anomalies

Format de qualification dans `templates/plan-de-test.md`. Trois natures à distinguer :
défaut de **code** (→ développeur), défaut de **spec** (→ business analyst), défaut
d'**environnement** (→ plan de test). Ne jamais corriger le code applicatif pour verdir un test.

## Checklist de sortie

- [ ] Chaque critère d'acceptation a au moins un cas de test, tracé dans le tableau
- [ ] La matrice de droits est couverte, refus compris
- [ ] Les données sensibles font l'objet d'un test d'absence pour les rôles non autorisés
- [ ] Les trois états d'écran (chargement, vide, erreur) sont testés côté front
- [ ] La suite complète a été exécutée, sortie réelle rapportée
- [ ] Aucun test ignoré, aucune assertion affaiblie pour faire passer la suite
- [ ] Les anomalies sont reproductibles sans l'auteur du test
