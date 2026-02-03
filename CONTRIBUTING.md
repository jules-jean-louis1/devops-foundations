# Guide de Contribution - CloudNative Labs

Bienvenue sur le projet **DevOps Foundations**. Pour maintenir une infrastructure de référence et une qualité de code optimale, nous appliquons des standards de développement rigoureux.

## 1. Stratégie de Branching (GitFlow)

Nous utilisons une implémentation stricte de **GitFlow** pour la gestion de nos versions.

![GitFlow](docs/images/Git%20Flow.png "GitFlow")

### Branches Permanentes
*   **`main`** : Branche de production. Elle contient uniquement du code stable et déployable. Cette branche est **protégée**.
*   **`develop`** : Branche principale d'intégration. Toutes les nouvelles fonctionnalités y sont fusionnées avant d'aller en production. Cette branche est également **protégée**.

## 2. Conventions de Commits

Afin de garantir un historique Git clair et maintenable, le projet adopte la convention **Conventional Commits**.

Chaque message de commit doit respecter le format suivant : 

```bash
<type>(<scope>): <description>
```
**type**: nature du changement
**scope**(*optionnel*): partie du projet impactée
**description**: description courte et impérative du changement

### 2.1 Types de Commits

Les types de commits suivants sont autorisés dans ce projet :

| Type     | Description                                                                                |
| -------- | ------------------------------------------------------------------------------------------ |
| feat     | Ajout d’une nouvelle fonctionnalité                                                        |
| fix      | Correction d’un bug                                                                        |
| refactor | Modification du code n’ajoutant ni fonctionnalité ni correction                            |
| style    | Changements de style sans impact fonctionnel (formatage, indentation, renommage, espaces…) |
| docs     | Rédaction ou mise à jour de la documentation                                               |
| chore    | Tâches diverses et maintenance (outillage, configuration, dépendances, scripts…)           |

**Atomicité** : Chaque commit doit représenter une seule unité logique de changement.

## 3. Workflow de Fusion : Merge vs Rebase

Conformément à notre politique technique :

*   **Merge (Fusion)** : Privilégié pour l'intégration des branches feature vers `develop`. Cela garantit la **traçabilité** et l'auditabilité en créant un point de fusion explicite et en conservant les IDs originaux des commits.
*   **Rebase** : Autorisé uniquement en **local** pour nettoyer l'historique personnel avant de pousser une branche. Le rebase sur les branches protégées (`main`, `develop`) est strictement interdit.

## 3. Checklist de Self-Review

Avant de soumettre une Pull Request ou de procéder à un merge, chaque développeur doit valider les points suivants :

### Sécurité & Configuration
- [ ] Aucun credential (mot de passe, clé API) n'est présent en clair dans le code.
- [ ] Le fichier `.env` est bien listé dans le `.gitignore`.
- [ ] Aucun port applicatif n'est exposé directement (tout passe par Traefik).

### Docker & Optimisation
- [ ] Le `Dockerfile` utilise un **multi-stage build**.
- [ ] L'image finale est basée sur une version minimale (**Alpine**).
- [ ] L'application tourne avec un **utilisateur non-root** (UID/GID explicites).
- [ ] Le fichier `.dockerignore` est présent et complet.
- [ ] Des **Healthchecks** sont configurés dans le Docker Compose.

### Qualité du Code
- [ ] Les routes obligatoires (`/health`, `/db`, etc.) sont fonctionnelles.
- [ ] La documentation (README ou docs spécifiques) a été mise à jour.

***
