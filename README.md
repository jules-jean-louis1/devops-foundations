# DevOps Foundations

Ce dépôt contient une stack de démonstration containerisée destinée à l'apprentissage des fondamentaux DevOps : reverse proxy Traefik, collecte de métriques avec Prometheus, exposition de métriques système avec cAdvisor, visualisation via Grafana, et deux services applicatifs (backend API et frontend). Le document suivant explique les prérequis, donne un guide d'installation pas à pas, récapitule les commandes utiles et décrit les URLs et rôles des services.

## Prérequis

Vous devez disposer de Docker installé et d'un client `docker` fonctionnel. Le projet utilise `docker compose`; sur la plupart des systèmes modernes la commande est `docker compose`. Il est recommandé d'installer `mkcert` pour générer des certificats TLS de développement. Si `mkcert` n'est pas installé, le projet fournit une alternative basée sur Docker. Enfin, vous devez avoir les permissions d'écriture dans le répertoire du projet pour générer les certificats et le fichier `traefik/.htpasswd`.

## Installation pas à pas

### 1. Préparer l'environnement

Exécutez la cible suivante pour créer `docker/.env` à partir de l'exemple si nécessaire :

```bash
make env
```

### 2. Générer les certificats TLS

Si vous avez `mkcert` installé sur votre machine, exécutez :

```bash
make certs
```

Ce qui lancera le script `traefik/generate-certs.sh` et écrira `traefik/certs/local.crt` et `traefik/certs/local.key`. Si vous ne souhaitez pas installer `mkcert`, suivez l'alternative Docker indiquée par le script.

### 3. Générer le fichier d'authentification pour Traefik

Le projet fournit une cible qui lance un conteneur `httpd:alpine` et vous demande le mot de passe en mode sécurisé (invite interactive) afin de ne pas inscrire le mot de passe en clair dans l'historique ou les scripts :

```bash
make auth_traefik
```

Le fichier résultant `traefik/.htpasswd` sera monté en lecture seule dans le conteneur Traefik.

### 4. Installation complète et démarrage

La cible `make install` effectue les étapes préparatoires (création de `docker/.env`, génération des certificats, création de `traefik/.htpasswd`) et démarre la stack en construisant les images si nécessaire. Pour lancer l'ensemble, exécutez :

```bash
make install
```

Si vous préférez préparer les fichiers manuellement puis lancer la stack, exécutez d'abord `make env`, `make certs` et `make auth_traefik` puis démarrez avec :

```bash
make start
```

## Services, hôtes et ports

| Service | Port interne | Accès externe | Description |
|---------|-------------|----------------|-------------|
| `traefik` | 80, 443, 8082 | `https://traefik.localhost` | Reverse-proxy, dashboard (basic auth) |
| `prometheus` | 9090 | `http://localhost:9090` | Collecte des métriques |
| `cadvisor` | 8080 | `http://localhost:8080` | Metrics système et containers |
| `grafana` | 3000 | `http://localhost:3000` | Visualisation et dashboards |
| `backend` | 3002 | `https://api.localhost` | API Node.js (/health, /db, /cache, /contact) |
| `frontend` | 3001 | `https://app.localhost` | Application web (dashboard) |
| `postgres` | 5432 | `postgres:5432` (réseau interne) | Base de données |
| `redis` | 6379 | `redis:6379` (réseau interne) | Cache |
| `mailhog` | 8025 | `https://mail.localhost` | SMTP et UI web pour emails test |
| `adminer` | 8080 | `https://db.localhost` | Administration de la base de données |

### Configuration de `/etc/hosts`

Pour accéder aux services via leurs noms locaux, ajoutez cette ligne à votre fichier `/etc/hosts` :

```
127.0.0.1 traefik.localhost api.localhost app.localhost monitor.localhost prometheus.localhost mail.localhost db.localhost
```

Sous Linux/macOS, éditez `/etc/hosts`. Sous Windows, éditez `C:\Windows\System32\drivers\etc\hosts`.

## Quick Reference - Commandes copiables

### Vérifier l'état des services

```bash
make ps
```

### Afficher les logs d'un service

```bash
# Logs récents (Prometheus par exemple)
./docker/docker.sh logs --tail 200 prometheus

# Logs de plusieurs services
./docker/docker.sh logs --tail 200 prometheus cadvisor traefik grafana

# Suivre les logs en temps réel
./docker/docker.sh logs -f traefik
```

### Ouvrir un shell dans un conteneur

```bash
# Shell dans le backend
./docker/docker.sh exec -it ${PROJECT}_backend sh

# Shell dans Prometheus
./docker/docker.sh exec prometheus sh

# Shell dans PostgreSQL
./docker/docker.sh exec postgres psql -U postgres
```

### Tester l'accès à l'API

```bash
# Via Traefik (TLS auto-signé, accepter les avertissements)
curl -k https://api.localhost/health

# Directement depuis le réseau Docker (depuis un conteneur)
./docker/docker.sh exec prometheus curl -s http://backend:3002/health
```

### Consulter Prometheus

```bash
# Lister les targets et leur statut
curl -s 'http://localhost:9090/api/v1/targets' | jq '.'

# Lister les métriques contenant 'traefik', 'cadvisor' ou 'container'
curl -s 'http://localhost:9090/api/v1/label/__name__/values' | jq '.data[]' | grep -E 'traefik|cadvisor|container' -n || true
```

### Gestion de la stack

```bash
# Démarrer la stack
make start

# Arrêter la stack
make stop

# Supprimer la stack et les volumes
make remove

# Redémarrer un service
./docker/docker.sh restart prometheus
```

## Tests et diagnostics

### Vérifier que tout démarre correctement

Après avoir exécuté `make install`, attendez quelques secondes que tous les services deviennent `healthy`, puis vérifiez :

```bash
./docker/docker.sh ps
```

### Vérifier que Prometheus scrape les metrics

Ouvrez `http://localhost:9090` dans votre navigateur, allez à la page `Targets` et confirmez que tous les endpoints (Traefik, cAdvisor, Prometheus) sont `UP`.

### Vérifier que l'API répond

Accédez à `https://api.localhost/health` dans votre navigateur (acceptez l'avertissement TLS auto-signé). Ou utilisez curl :

```bash
curl -k https://api.localhost/health
```

### Vérifier que la base de données est accessible

```bash
./docker/docker.sh exec -it ${PROJECT}_backend sh
curl http://backend:3002/db
```

### Si Grafana n'affiche aucune donnée

1. Ouvrez `http://localhost:3000` dans votre navigateur.
2. Allez à Configuration → Data Sources.
3. Cliquez sur Prometheus.
4. Vérifiez que l'URL est `http://prometheus:9090` et faites `Test & Save`.

## Sécurité et bonnes pratiques

Ne stockez jamais de secrets en clair dans le code versionné. Le dépôt fournit un fichier `docker/.env.example` documenté ; copiez-le en `docker/.env` et ajoutez `docker/.env` à `.gitignore`. Pour la production, n'utilisez pas `mkcert` mais des certificats émis par une autorité de certification appropriée ou un gestionnaire de secrets.

Aucun port applicatif (backend sur 3002, frontend sur 3001) n'est exposé sur l'hôte. Tous les accès passent par Traefik sur les ports 80 et 443 (HTTP et HTTPS). Les services internes (PostgreSQL, Redis) ne sont accessibles que depuis le réseau Docker interne.

## Support et collecte d'informations pour diagnostic

Si vous rencontrez des problèmes, exécutez ces commandes et partagez les sorties :

```bash
./docker/docker.sh ps

./docker/docker.sh logs --tail 200 prometheus cadvisor traefik grafana backend frontend

./docker/docker.sh logs --tail 200 postgres redis mailhog
```

Vérifiez aussi :

- Que `/etc/hosts` contient les entrées pour `*.localhost`.
- Que les certificats existent dans `traefik/certs/`.
- Que le fichier `traefik/.htpasswd` existe.
- Que `docker/.env` existe et contient `PROJECT=cloudnative`.

## Documentation additionnelle

Le cahier des charges et la documentation de projet sont disponibles dans le dossier `docs/`. Le fichier `docs/project-spec.md` contient le détail des exigences et le plan de travail attendu.

