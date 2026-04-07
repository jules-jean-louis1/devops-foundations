.PHONY: install-dev install-prod start-dev start-prod remove stop clean auth_traefik trust-certs help

help: # Affiche les commandes disponibles
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

env: # Crée le fichier .env à partir de l'exemple s'il n'existe pas déjà
	@if [ ! -f "docker/.env" ]; then \
			cp docker/.env.example docker/.env; \
			echo "Created docker/.env from example"; \
	else \
			echo "docker/.env already exists"; \
	fi

certs: # Génère les certificats SSL pour les domaines locaux en utilisant mkcert dans un conteneur Docker
	@docker run --rm -v "$(CURDIR)/traefik:/workspace" -w /workspace debian:bookworm-slim sh -c 'apt-get update >/dev/null && apt-get install -y --no-install-recommends mkcert ca-certificates >/dev/null && mkdir -p certs && mkcert -cert-file certs/local.crt -key-file certs/local.key localhost "*.localhost" app.localhost api.localhost db.localhost mail.localhost traefik.localhost monitor.localhost prometheus.localhost 127.0.0.1 ::1' && echo "Certificats générés"

trust-certs: # Installe l'autorité de certification locale de mkcert dans le trust store du système/navigateur
	@command -v mkcert >/dev/null 2>&1 || (echo "mkcert n'est pas installé localement. Installe-le puis relance 'make trust-certs'." && exit 1)
	@mkcert -install && echo "Autorité locale mkcert installée dans le trust store système/navigateur"

auth_traefik: # Génère un fichier .htpasswd pour l'authentification de base de Traefik en utilisant htpasswd dans un conteneur Docker
	docker run --rm -v "$(CURDIR)/traefik":/data -w /data httpd:alpine htpasswd -b -B -c .htpasswd admin password

install-dev: env certs trust-certs auth_traefik # Recommandé : Construit et démarre l'infrastructure en mode DEVELOPPEMENT
	./docker/docker.sh up -d --build

install-prod: env certs trust-certs auth_traefik # Recommandé (CTO Demo) : Construit et démarre en mode PRODUCTION (Replicas etc.)
	COMPOSE_FILE=docker/docker-compose.yml:docker/docker-compose.prod.yml ./docker/docker.sh up -d --build

clean: remove # NETTOYAGE TOTAL : Supprime les conteneurs, certificats, .env et base de données !
	rm -f docker/.env
	rm -f traefik/.htpasswd
	rm -f traefik/certs/local.crt traefik/certs/local.key
	@echo "L'environnement a été remis à zéro avec succès."

build: # Reconstruit les images Docker sans démarrer les conteneurs (ex: make build s=frontend)
	./docker/docker.sh build $(s)

rebuild-dev: # Reconstruit et redémarre un service en DEV (ex: make rebuild-dev s=frontend)
	./docker/docker.sh up -d --build $(s)

rebuild-prod: # Reconstruit et redémarre un service en PROD (ex: make rebuild-prod s=frontend)
	COMPOSE_FILE=docker/docker-compose.yml:docker/docker-compose.prod.yml ./docker/docker.sh up -d --build $(s)

status: # Affiche l'état des conteneurs Docker
	./docker/docker.sh ps

logs: # Affiche les logs d'un conteneur en temps réel (ex: make logs s=frontend)
	./docker/docker.sh logs -f $(s)

start-dev: # Démarre les conteneurs en DEVELOPPEMENT sans reconstruire les images
	./docker/docker.sh up -d

start-prod: # Démarre les conteneurs en PRODUCTION sans reconstruire les images
	COMPOSE_FILE=docker/docker-compose.yml:docker/docker-compose.prod.yml ./docker/docker.sh up -d

stop: # Arrête les conteneurs Docker sans les supprimer
	./docker/docker.sh stop

remove: # Arrête et supprime les conteneurs Docker, ainsi que les volumes associés
	./docker/docker.sh down -v || true
	COMPOSE_FILE=docker/docker-compose.yml:docker/docker-compose.prod.yml ./docker/docker.sh down -v || true

docker: # Exécute une commande Docker Compose personnalisée, par exemple 'make docker logs' pour voir les logs
	./docker/docker.sh $(filter-out $@,$(MAKECMDGOALS))

%:
	@:

scan-security:
	@if ! -f ~/.cache/trivy/trivy.db; then \
		echo "Trivy database not found. Downloading..."; \
		docker run --rm -v ~/.cache/trivy:/root/.cache/trivy aquasec/trivy --download-db-only; \
	fi
	mkdir -p ~/.cache/trivy
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ~/.cache/trivy:/root/.cache/trivy aquasec/trivy image --severity HIGH,CRITICAL --no-progress --exit-code 1 --format table $(shell ./docker/docker.sh images -q)