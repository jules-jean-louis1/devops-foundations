.PHONY: install start remove stop auth_traefik trust-certs help

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
	docker run --rm -it -v "$(CURDIR)/traefik":/data -w /data httpd:alpine htpasswd -B -C 12 -c .htpasswd admin password

install: env certs trust-certs auth_traefik # Installe les dépendances, génère les certificats et configure Traefik
	./docker/docker.sh up -d --build

build: # Reconstruit les images Docker sans démarrer les conteneurs
	./docker/docker.sh build

status: # Affiche l'état des conteneurs Docker
	./docker/docker.sh ps

start-build: # Reconstruit les images Docker et démarre les conteneurs
	./docker/docker.sh up -d --build

start: # Démarre les conteneurs Docker sans reconstruire les images
	./docker/docker.sh up -d

stop: # Arrête les conteneurs Docker sans les supprimer
	./docker/docker.sh stop

remove: # Arrête et supprime les conteneurs Docker, ainsi que les volumes associés
	./docker/docker.sh down -v

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