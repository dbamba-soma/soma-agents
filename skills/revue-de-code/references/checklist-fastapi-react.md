# Points de vigilance — FastAPI (async) + React/TypeScript

Complément spécifique à la grille générale de `revue-de-code`.

## Backend — FastAPI / SQLAlchemy async / Alembic

- **Dépendance de sécurité présente sur chaque route.** Une route sans dépendance de rôle
  est publique : c'est un choix, il doit être délibéré et visible.
- **Filtrage des champs sensibles côté serveur.** Un schéma de sortie unique pour deux
  publics différents (ex. manager vs. consultant) fuit tôt ou tard : deux schémas, ou un
  filtrage explicite selon le rôle.
- **`async` jusqu'au bout.** Un appel bloquant (I/O fichier, requête HTTP synchrone,
  `time.sleep`) dans une route `async` bloque la boucle d'événements.
- **Relations chargées explicitement.** En SQLAlchemy async, l'accès paresseux à une
  relation hors session lève une erreur ou déclenche un N+1 : charge-les explicitement.
- **Session par requête**, jamais partagée entre tâches concurrentes.
- **Migration Alembic pour tout changement de modèle**, avec une révision descendante
  cohérente. Vérifier que la migration s'applique sur une base existante, pas seulement vide.
- **Validation par schéma** pour toute entrée : types, longueurs, valeurs autorisées.
- **Codes de statut corrects** : `201` à la création, `204` sans corps, `403` pour un droit
  refusé (pas `404`, sauf si l'existence même est confidentielle), `409` pour un conflit.
- **Timeouts sur les clients HTTP externes.** Un appel sans timeout fige une requête.
- **Tâches planifiées** : idempotentes, sans supposer un lancement unique, arrêtées
  proprement à l'extinction.

## Frontend — React / TypeScript / Vite

- **Pas de `any`** introduit ; les types viennent d'un fichier de types partagé et reflètent
  les schémas serveur.
- **Trois états gérés pour chaque écran de données** : chargement, vide, erreur. L'écran
  vide est le plus souvent oublié et c'est celui de la démo.
- **Les droits ne se gèrent pas côté front.** Masquer un bouton est du confort ; la
  protection est serveur. Une revue qui voit un droit *uniquement* côté front le classe
  `BLOQUANT`.
- **Clés de liste stables** (identifiant, pas l'index) dès que la liste peut être réordonnée.
- **Pas d'appel d'API dans un effet sans nettoyage** ni garde contre la réponse obsolète ;
  préférer le client de données du projet (cache, invalidation) au `fetch` manuel.
- **Invalidation du cache après mutation** : sinon l'écran ment après une action.
- **Jeton d'authentification** : un seul point de lecture/écriture, jamais recopié dans
  plusieurs composants.
- **Textes en français** cohérents avec l'existant, dates formatées avec la locale du projet.
- **Styles** : réutiliser les variables et classes existantes plutôt que des valeurs en dur.
