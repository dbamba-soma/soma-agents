# Patterns de test front — Vitest / React / TypeScript

Sur `somanager-cockpit`, Vitest est installé et `npm run test` existe, **mais aucun test
front n'est écrit**. C'est le premier déficit de couverture à combler. Poser les patterns
proprement dès le premier test.

## Mise en place (première fois)

Dépendances de test à ajouter : `@testing-library/react`, `@testing-library/user-event`,
`@testing-library/jest-dom`, `jsdom`.

Configuration Vite/Vitest : environnement `jsdom`, `globals: true`, fichier de mise en
place important les matchers et réinitialisant les doublures entre tests.

Emplacement : `frontend/src/**/*.test.tsx`, à côté du composant testé.

## Ce qu'on teste en priorité

1. **Les trois états d'un écran de données** : chargement, **vide**, erreur. L'état vide est
   celui que la démo rencontre le plus souvent et celui qui est le moins écrit.
2. **La logique d'affichage conditionnelle liée au rôle** : un bouton réservé au manager
   n'apparaît pas pour un consultant. (Confort d'interface — la vraie protection reste
   serveur et se teste côté API.)
3. **Les fonctions utilitaires d'affichage** : formatage de date, libellés de statut, de
   cadence, d'humeur. Tests unitaires purs, rapides, à fort rendement.
4. **Les formulaires** : validation, désactivation pendant l'envoi, message d'erreur
   serveur affiché à l'utilisateur.

## Règles

- **Doubler le réseau, pas les composants** : simuler `fetch` (ou la couche client d'API)
  et rendre le composant réel. Un test qui ne rend pas le vrai composant ne prouve rien.
- Interagir comme un utilisateur (`getByRole`, `getByLabelText`, `userEvent`), jamais par
  classe CSS ni par structure interne.
- La doublure renvoie **la forme réelle** de la réponse serveur, erreurs comprises
  (`{"detail": "..."}` et le bon code de statut).
- Réinitialiser le stockage local et les doublures entre les tests.
- Ne pas tester le routeur ni la bibliothèque de données : tester **notre** code.

## Exécution

```bash
cd frontend
npm run test          # suite Vitest
npm run typecheck     # types (bloquant en CI)
npm run lint          # eslint --max-warnings 0 (présent, à brancher en CI)
npm run build         # build de production (bloquant en CI)
```
