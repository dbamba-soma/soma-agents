# SOMA Agents & Skills

Agents et skills SOMA Smart, au format Claude Code standard, destinés à être importés dans
**Multica** et réutilisés sur les projets de la practice.

Chaîne de valeur couverte : **besoin → spécification fonctionnelle → spécification
technique → code → revue → recette → preview**.

## Contenu

### Agents (`agents/`)

| Agent | Rôle | Entrée | Sortie |
|---|---|---|---|
| [`business-analyst`](agents/business-analyst.md) | Challenge la feature, interroge l'initiateur du besoin, rédige la SFD | Une idée, un ticket flou | `docs/specs/SFD-NN-*.md` + questions et arbitrages |
| [`senior-developer`](agents/senior-developer.md) | Challenge la SFD, rédige la STD, implémente, teste, livre une branche | Une SFD validée | `docs/specs/STD-NN-*.md`, code, tests, commits |
| [`tech-lead`](agents/tech-lead.md) | Garant des bonnes pratiques : sécurité, architecture, tests, lisibilité | Un diff, une branche, une PR | Rapport classé par sévérité + verdict GO / NO-GO |
| [`qa-tester`](agents/qa-tester.md) | Plan de test tracé sur les critères d'acceptation, tests automatisés, recette | SFD + implémentation | `docs/tests/PT-NN-*.md`, tests, anomalies qualifiées |

### Skills (`skills/`)

| Skill | Sert à | Utilisée par |
|---|---|---|
| [`spec-fonctionnelle`](skills/spec-fonctionnelle/SKILL.md) | Template de SFD + grille d'interview de l'initiateur | business-analyst |
| [`spec-technique`](skills/spec-technique/SKILL.md) | Template de STD + template d'ADR | senior-developer, tech-lead |
| [`revue-de-code`](skills/revue-de-code/SKILL.md) | Grille de revue par axes, sévérités, vigilance FastAPI/React | tech-lead, senior-developer |
| [`strategie-de-test`](skills/strategie-de-test/SKILL.md) | Pyramide, matrice de droits, patterns pytest/httpx et Vitest, plan de test | qa-tester, senior-developer |
| [`somanager-cockpit`](skills/somanager-cockpit/SKILL.md) | Connaissance projet : architecture, conventions, charte, état des lieux | tous, sur ce dépôt |
| [`preview-locale`](skills/preview-locale/SKILL.md) | Lancer, peupler et recetter une preview ; scénario de démonstration | tous, avant démonstration |

Les quatre agents et les quatre premières skills sont **génériques** : réutilisables sur
tout projet SOMA. La connaissance spécifique à un dépôt est isolée dans une skill projet
(ici `somanager-cockpit`) — c'est le seul fichier à dupliquer et adapter pour un nouveau projet.

## Boucle de travail

```
        ┌──────────────────────────────────────────────────┐
        │                  initiateur (toi)                │
        └───────▲──────────────────────────────┬───────────┘
   questions,   │                              │ besoin
   arbitrages   │                              ▼
        ┌───────┴──────────┐    SFD    ┌───────────────────┐
        │ business-analyst ├──────────►│ senior-developer  │
        │                  │◄──────────┤  (challenge, STD) │
        └──────────────────┘ écarts    └─────────┬─────────┘
                 ▲                               │ code + tests
        défaut   │                               ▼
        de spec  │                     ┌───────────────────┐
                 ├─────────────────────┤     tech-lead     │  GO / NO-GO
                 │                     └─────────┬─────────┘
                 │                               │
                 │                               ▼
                 │                     ┌───────────────────┐
                 └─────────────────────┤     qa-tester     │  recette
                                       └───────────────────┘
```

Règles de la boucle :

1. **Rien ne se code avant une SFD** avec des critères d'acceptation testables.
2. Le **développeur challenge le BA** : contradictions, trous, coûts disproportionnés. Le
   BA tranche ou fait trancher. Personne n'implémente une zone d'ombre bloquante.
3. Le **tech lead ne réécrit pas le code** : il classe par sévérité et rend un verdict.
4. Le **testeur ne corrige pas le code** : il qualifie des anomalies reproductibles.
5. Une question sans réponse ne bloque jamais : elle devient une **hypothèse explicite**,
   tracée et visible jusqu'à sa levée.

### Point d'attention — les questions en mode sous-agent

Un sous-agent isolé **ne peut pas dialoguer avec l'utilisateur** : il produit un résultat,
qui remonte à l'orchestrateur. Les agents sont donc écrits pour fonctionner des deux façons :

- en agent principal (ou si un outil de question leur est exposé) : ils questionnent
  directement, par salves de 7 au maximum ;
- en sous-agent : ils terminent par un bloc `## Questions à l'initiateur` (question /
  options / hypothèse par défaut) et **s'arrêtent**, sans jamais simuler les réponses.

C'est la raison pour laquelle chaque question porte une hypothèse par défaut : le travail
avance même quand le dialogue est différé.

## Installation

### Dans un projet (recommandé)

```bash
git clone git@github.com:dbamba-soma/soma-agents.git
mkdir -p .claude
ln -s ../../soma-agents/agents .claude/agents
ln -s ../../soma-agents/skills .claude/skills
```

Ou par copie, si les liens symboliques ne conviennent pas :

```bash
cp -r soma-agents/agents soma-agents/skills .claude/
```

### Pour tous les projets

```bash
cp -r soma-agents/agents/* ~/.claude/agents/
cp -r soma-agents/skills/* ~/.claude/skills/
```

### Import dans Multica

L'arborescence respecte le format standard :

```
agents/<nom>.md            frontmatter YAML : name, description, tools, model
skills/<nom>/SKILL.md      frontmatter YAML : name, description
skills/<nom>/templates/    modèles de documents à copier
skills/<nom>/references/   détail chargé à la demande
```

Le `description` de chaque agent et de chaque skill décrit **quand** l'utiliser : c'est ce
champ qui pilote le déclenchement automatique. Le modifier change le comportement.

## Conventions de rédaction

- Français, pour le contenu comme pour les livrables produits.
- Une skill reste courte ; le détail part dans `references/`, chargé seulement au besoin.
- Les agents décrivent une **procédure et des interdits**, pas une personnalité.
- Les identifiants sont stables et croisés entre documents : `RG-xx` (règle de gestion),
  `CA-xx` (critère d'acceptation), `H-xx` (hypothèse), `T-xx` (test), `ANO-xx` (anomalie),
  `ADR-xx` (décision).

## Ajouter un projet

1. Dupliquer `skills/somanager-cockpit/` sous le nom du nouveau dépôt.
2. Réécrire `SKILL.md` (architecture, rôles, chaîne de qualité, pièges) et les
   `references/` (patterns back, patterns front, état des lieux).
3. Ne rien toucher aux quatre agents : ils lisent la skill projet.
