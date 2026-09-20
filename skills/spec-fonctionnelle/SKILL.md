---
name: spec-fonctionnelle
description: Rédiger une spécification fonctionnelle détaillée (SFD) exploitable — règles de gestion numérotées, matrice de droits, critères d'acceptation testables, cas limites. À utiliser dès qu'un besoin doit être formalisé avant développement, qu'il s'agisse d'une feature, d'une évolution ou d'un lot de preview. Fournit le template de SFD et la grille d'interview de l'initiateur du besoin.
---

# Spécification fonctionnelle détaillée

Une SFD est réussie quand le développeur n'a plus besoin d'appeler son auteur, et quand le
testeur peut écrire ses tests sans interpréter.

## Règles de rédaction

1. **Le quoi, pas le comment.** Aucune table, aucun endpoint, aucun composant. Si tu ne
   peux pas décrire la règle sans nommer une technologie, la règle n'est pas comprise.
2. **Tout est identifié et référencé** : `RG-01` pour les règles de gestion, `CA-01` pour
   les critères d'acceptation, `H-01` pour les hypothèses. Les critères citent les règles.
3. **Un critère d'acceptation est testable ou n'existe pas.** Format
   `Étant donné … / Quand … / Alors …`, avec des valeurs concrètes. Bannis : « rapide »,
   « ergonomique », « pertinent », « le cas échéant », « à définir ».
4. **Le hors-périmètre est écrit.** C'est la section qui évite 80 % des malentendus.
5. **Les hypothèses sont visibles** (`[HYPOTHÈSE H-02]` en ligne + section récapitulative),
   jamais dissoutes dans le texte.
6. **La matrice de droits est complète** : aucune case vide. Si un rôle n'a pas de droit,
   écris « non » — l'absence de réponse est un défaut.
7. **Langue du repo.** Sur les projets SOMA : français, y compris les identifiants de
   statut métier s'ils existent déjà en français dans le code.

## Procédure

1. Lire l'existant (code, specs déjà écrites) avant d'écrire une ligne.
2. Remplir la grille d'interview → `references/grille-interview.md`.
3. Poser les questions ouvertes par salve de 7 maximum, chacune avec une hypothèse par défaut.
4. Copier `templates/SFD.md` vers `docs/specs/SFD-<NN>-<slug>.md` et le remplir.
5. Relire avec la checklist de sortie ci-dessous.

## Checklist de sortie

- [ ] Chaque `CA` est écrit en Étant donné / Quand / Alors, avec des valeurs concrètes
- [ ] Chaque `CA` est rattaché à au moins une `RG`
- [ ] La matrice de droits ne contient aucune case vide
- [ ] Les cas limites listés ont chacun un comportement attendu
- [ ] Le hors-périmètre est rempli et justifié
- [ ] Aucune occurrence de « à définir », « TBD », « etc. » dans les règles et critères
- [ ] Les hypothèses sont récapitulées et attribuées à un décideur
- [ ] Les impacts sur l'existant (écrans, données, droits) sont listés
