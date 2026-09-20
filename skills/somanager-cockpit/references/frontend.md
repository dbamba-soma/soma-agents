# Frontend — patterns en vigueur

React 19 + Vite + TypeScript, `@tanstack/react-query` pour l'état serveur,
`react-router-dom` v7 pour la navigation. Aucune bibliothèque de composants : CSS maison
dans `src/index.css` avec variables.

## Client d'API

`src/api.ts` : fonction `api<T>(path, options)` unique — injecte le jeton, force le
`Content-Type`, gère le `401` (purge du jeton + `ApiError`), extrait `detail` des erreurs,
renvoie `undefined` sur `204`.

**Ne jamais appeler `fetch` directement dans un composant.** Tout passe par `api<T>()`.
Le jeton se lit et s'écrit uniquement via `tokenStore`.

## Organisation

```
src/
  App.tsx                 routes, séparées par rôle (manager / consultant)
  auth.tsx                contexte d'authentification, utilisateur courant
  api.ts                  client HTTP + gestion du jeton
  types.ts                types partagés, alignés sur les schémas serveur
  ui.tsx                  primitives : StatusBadge, formatDate, moodEmoji, cadenceLabel
  components/             Layout (barre latérale), NotificationsPanel
  pages/                  un fichier par écran ; sous-dossiers manager/ et admin/
  index.css               variables de charte + styles
```

Routage par rôle dans `App.tsx` : `isSuperAdmin` / `isManager` conditionnent les routes.
Une route ajoutée doit l'être **dans la bonne branche**, et son écran protégé côté serveur.

## Règles

- Réutiliser `ui.tsx` (badges de statut, `formatDate` en `fr-FR`, libellés de cadence,
  émojis d'humeur) plutôt que de reformater localement.
- Les types de `types.ts` reflètent les schémas serveur : les tenir synchronisés, pas de `any`.
- Trois états à gérer sur chaque écran de données : **chargement, vide, erreur**.
- Invalider le cache après mutation, sinon l'écran ment.
- Le masquage d'un bouton selon le rôle est du confort : la protection reste serveur.
- Textes en français ; dates via `formatDate`.

## Charte SOMA (variables CSS de `index.css`)

| Variable | Valeur | Usage |
|---|---|---|
| `--primary` | `#000099` | bleu SOMA, éléments principaux |
| `--primary-light` / `--primary-dark` | `#1a1ab3` / `#151648` | variations |
| `--deep-koamaru` | `#2d2e60` | dégradé de la barre latérale |
| `--accent` | `#f50a63` | rose SOMA, accents et actions |
| `--success` / `--warning` / `--danger` | `#2e7d32` / `#f57f17` / `#c62828` | états |
| `--bg` / `--card` / `--card-surface` | `#f5f6fa` / `#ffffff` / `#f0f1f8` | fonds |
| `--text` / `--text-light` | `#263238` / `#607d8b` | textes |
| `--radius` | `10px` | rayon standard |

Police : « Plus Jakarta Sans ». Barre latérale : dégradé bleu nuit, largeur `--sidebar-w`.

**Aucune couleur en dur** dans un composant : ajouter une variable si elle manque.

## Commandes

```bash
npm run dev        # serveur de développement, proxy /api → 8002
npm run typecheck  # tsc --noEmit (bloquant en CI)
npm run lint       # eslint --max-warnings 0 (non branché en CI)
npm run test       # vitest (aucun test écrit à ce jour)
npm run build      # tsc -b && vite build (bloquant en CI)
```
