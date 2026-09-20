---
name: preview-locale
description: Préparer, lancer et recetter une preview locale d'une application SOMA — démarrage back et front, jeu de données de démonstration, scénario de démo minuté, checklist de recette avant présentation. À utiliser avant de montrer l'application à un commanditaire, de tourner une démo, ou pour valider qu'un lot est réellement démontrable de bout en bout.
---

# Preview locale

Une preview se rate rarement sur le code : elle se rate sur un écran vide, un compte qui ne
se connecte pas, un onglet qui ne répond pas, ou une donnée absente. Cette skill sert à
éliminer ces causes **avant** la présentation.

## 1. Lancer

Sur `somanager-cockpit` :

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r backend/requirements-dev.txt
cd frontend && npm ci && npm run build && cd ..     # front servi par le back, comme en prod
uvicorn backend.main:app --port 8002                # http://127.0.0.1:8002
```

Démontrer sur le **build servi par le backend** (port 8002), pas sur le serveur de
développement : c'est la configuration de production, et cela évite la surprise d'un écran
qui ne fonctionne qu'en mode développement.

Les migrations s'appliquent au démarrage et les données de démonstration sont amorcées hors
production (idempotent). Pour repartir propre : supprimer le fichier `somanager.db`.

## 2. Vérifier l'environnement de démo

| Point | Vérification | Pourquoi |
|---|---|---|
| Base | Partir d'une base fraîche, puis jouer le scénario une fois **en entier** | Révèle les écrans vides |
| Comptes | Tester la connexion de **chaque** compte utilisé dans le scénario | Un mot de passe erroné en direct est fatal |
| Envoi d'e-mails | Décider : `MAIL_OVERRIDE_RECIPIENT` actif (rien ne part) ou inactif (envoi réel) | Ni spam des comptes de démo, ni démonstration d'un envoi qui n'arrive pas |
| SSO / Graph | Sans identifiants Azure, les fonctions déléguées sont inertes : **ne pas les inscrire au scénario** | Éviter la démonstration d'une fonctionnalité dégradée |
| Console | Ouvrir la console du navigateur, vérifier l'absence d'erreur | Une erreur visible décrédibilise |
| Entrées inertes | Aucune entrée de menu ne doit rester sans réaction au clic | La première chose qu'un spectateur essaie |

## 3. Écrire le scénario

Un scénario tient sur une page et se minute. Structure recommandée :

| # | Écran | Acteur (compte) | Action | Ce que ça prouve | Durée |
|---|---|---|---|---|---|
| 1 | | | | | 1 min |

Règles :
- **Un fil narratif**, pas un tour du propriétaire : une journée de manager vaut mieux
  qu'une visite de menu.
- **Chaque écran montré est plein** de données réalistes. Un tableau vide annule la
  démonstration, même si le code est bon.
- **Une seule fonctionnalité en cours de construction** peut être montrée, annoncée comme
  telle, et jamais cliquée au hasard.
- Prévoir le **plan B** : capture d'écran ou enregistrement des étapes qui dépendent d'un
  service externe.
- Terminer sur ce qu'on demande au commanditaire : arbitrage de périmètre, accès à obtenir,
  prochain lot.

Modèle complet : `references/scenario-demo.md`.

## 4. Recette avant présentation

- [ ] Base repartie de zéro, scénario joué intégralement **la veille**, sans échec
- [ ] Chaque compte du scénario testé le jour même
- [ ] Chaîne de qualité verte (lint, types, tests back et front, build)
- [ ] Aucune erreur dans la console du navigateur sur les écrans du scénario
- [ ] Aucune entrée de menu inerte (ou message « bientôt disponible » explicite)
- [ ] Décision d'envoi d'e-mails prise et vérifiée
- [ ] Données affichées présentables : pas de « Test test », pas de nom réel sensible
- [ ] Scénario minuté, avec 30 % de marge sur le temps annoncé
- [ ] Plan B prêt pour les étapes dépendant d'un service externe
- [ ] Liste des questions et arbitrages à poser à la fin de la démonstration
