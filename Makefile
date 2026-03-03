.PHONY: install start remove stop auth_traefik trust-certs

env:
	@if [ ! -f "docker/.env" ]; then \
		cp docker/.env.example docker/.env; \
		echo "Created docker/.env from example"; \
	else \
		echo "docker/.env already exists"; \
	fi

certs:
	@docker run --rm -v "$(CURDIR)/traefik:/workspace" -w /workspace debian:bookworm-slim sh -c 'apt-get update >/dev/null && apt-get install -y --no-install-recommends mkcert ca-certificates >/dev/null && mkdir -p certs && mkcert -cert-file certs/local.crt -key-file certs/local.key localhost "*.localhost" app.localhost api.localhost db.localhost mail.localhost traefik.localhost monitor.localhost prometheus.localhost 127.0.0.1 ::1' && echo "Certificats générés"

trust-certs:
	@command -v mkcert >/dev/null 2>&1 || (echo "mkcert n'est pas installé localement. Installe-le puis relance 'make trust-certs'." && exit 1)
	@mkcert -install && echo "Autorité locale mkcert installée dans le trust store système/navigateur"

auth_traefik:
	docker run --rm -it -v "$(CURDIR)/traefik":/data -w /data httpd:alpine htpasswd -B -C 12 -c .htpasswd admin password

install: env certs auth_traefik
	./docker/docker.sh up -d --build

build:
	./docker/docker.sh build

status:
	./docker/docker.sh ps

start-build:
	./docker/docker.sh up -d --build

start:
	./docker/docker.sh up -d

stop:
	./docker/docker.sh stop

remove:
	./docker/docker.sh down -v

docker: 
	./docker/docker.sh $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
