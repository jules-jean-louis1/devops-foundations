# Merge vs Rebase : Quelle Stratégie Adopter ?

## Pourquoi Privilégier le Merge pour l'Intégration ?

### 1. Sécurité et Traçabilité

Le **merge** est la stratégie recommandée pour intégrer des branches de fonctionnalités (`feature`) vers les branches partagées (`develop`, `main`) pour plusieurs raisons :

- **Préservation des IDs de commits** : Les commits originaux de la feature conservent leurs identifiants SHA-1, garantissant une traçabilité complète et une auditabilité du code.
- **Commit de fusion explicite** : Chaque intégration de feature crée un commit de merge dédié, permettant d'identifier clairement quand et comment une fonctionnalité a été intégrée.
- **Historique authentique** : L'historique reflète fidèlement la chronologie réelle du développement, ce qui est essentiel pour les audits de sécurité et la conformité.

### 2. Avantages en Termes de Gestion de Conflits

Avec le merge, les conflits sont résolus **une seule fois** au moment de la fusion, contrairement au rebase qui peut nécessiter de résoudre les mêmes conflits plusieurs fois.

## Quand Utiliser le Rebase ?

Le **rebase** reste utile, mais uniquement dans un **contexte local** :

### Usage Recommandé

- **Nettoyage de l'historique local** : Avant de pousser une branche, le rebase permet de réorganiser les commits pour un historique plus linéaire et lisible.
- **Mise à jour d'une branche personnelle** : Synchroniser sa branche locale avec `develop` sans polluer l'historique.

### Limitations du Rebase

- **Récriture de l'historique** : Chaque commit est recréé avec un nouvel ID (SHA-1), ce qui peut poser des problèmes de traçabilité.
- **Conflits multiples** : Les conflits doivent être résolus pour chaque commit appliqué, ce qui alourdit le processus.
- **Risque de perte de contexte** : La suppression des commits de merge rend plus difficile la compréhension de l'intégration des fonctionnalités.

## Règle d'Or

> **JAMAIS de rebase sur les branches partagées** (`main`, `develop`) : cela réécrit l'historique public et crée des divergences pour les autres contributeurs.

## Résumé

| Critère                  | Merge                          | Rebase                         |
| ------------------------ | ------------------------------ | ------------------------------ |
| **Traçabilité**          | ✅ Préserve les IDs originaux  | ❌ Crée de nouveaux IDs        |
| **Sécurité**             | ✅ Historique authentique      | ⚠️ Historique réécrit          |
| **Gestion des conflits** | ✅ Résolution unique           | ❌ Résolution multiple         |
| **Lisibilité**           | ⚠️ Historique non-linéaire     | ✅ Historique linéaire         |
| **Usage recommandé**     | Intégration vers branches partagées | Nettoyage local avant push |
