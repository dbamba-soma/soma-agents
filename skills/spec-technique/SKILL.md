---
name: spec-technique
description: Traduire une spécification fonctionnelle en spécification technique détaillée (STD) — modèle de données et migration, contrats d'API avec rôle requis, découpage front, impacts config/sécurité/performance, lots d'implémentation — et tracer les décisions structurantes en ADR. À utiliser avant d'implémenter une feature spécifiée, ou pour instruire techniquement un besoin avant arbitrage de périmètre.
---

# Spécification technique détaillée

La STD sert trois lecteurs : le développeur qui implémente, le Tech Lead qui relit, le
testeur qui cherche les angles morts. Elle est **courte et décisive**, pas exhaustive.

## Règles de rédaction

1. **Chaque décision est rattachée à un critère d'acceptation.** Un élément de conception
   qui ne sert aucun `CA` est du périmètre non demandé : supprime-le ou justifie-le.
2. **Contrats d'API complets** : méthode, chemin, corps attendu, corps retourné, codes
   d'erreur, **et le rôle requis**. Le rôle n'est jamais implicite.
3. **Tout changement de schéma vient avec sa migration**, et avec le comportement pour les
   données existantes (valeur par défaut, rétro-remplissage, nullable).
4. **Les lots sont livrables indépendamment**, dans un ordre où chaque lot laisse
   l'application fonctionnelle.
5. **Les alternatives écartées sont nommées** en une ligne chacune. C'est ce qui évite de
   refaire le débat trois semaines plus tard.
6. **Le coût est estimé par lot**, en jours ou demi-journées. Une estimation absente
   empêche l'arbitrage de périmètre.

## Décisions structurantes → ADR

Ouvre un ADR (`docs/adr/ADR-<NN>-<slug>.md`, template fourni) dès que la décision :
- ajoute une dépendance ou un service externe ;
- change la façon dont on fait quelque chose de déjà établi dans le repo ;
- arbitre un compromis durable (cohérence vs. latence, simplicité vs. généricité) ;
- sera coûteuse à inverser.

Sinon, un paragraphe dans la STD suffit. N'inflationne pas les ADR.

## Checklist de sortie

- [ ] Chaque `CA` de la SFD est couvert par au moins un élément de conception
- [ ] Chaque endpoint indique son rôle requis et ses codes d'erreur
- [ ] Chaque changement de schéma a sa migration et son traitement de l'existant
- [ ] Les points de performance identifiés (volumétrie, requêtes en boucle, appels externes)
- [ ] Les nouveaux paramètres de configuration et secrets sont listés et documentés
- [ ] Les lots sont ordonnés, estimés, et livrables indépendamment
- [ ] Les questions restantes pour le Business Analyst sont isolées en fin de document
