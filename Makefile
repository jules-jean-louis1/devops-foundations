.PHONY: install start remove stop auth_traefik

env:
	@if [ ! -f "docker/.env" ]; then \
		cp docker/.env.example docker/.env; \
		echo "Created docker/.env from example"; \
	else \
		echo "docker/.env already exists"; \
	fi

certs:
	@if [ ! -f "traefik/certs/local.crt" ] || [ ! -f "traefik/certs/local.key" ]; then \
		chmod +x ./traefik/generate-certs.sh && ./traefik/generate-certs.sh; \
		echo "Certificates generated"; \
	else \
		echo "Certificates already present"; \
	fi

auth_traefik:
	docker run --rm -it -v "$(pwd)/traefik":/data -w /data httpd:alpine htpasswd -B -C 12 -c .htpasswd test1

install: env certs auth_traefik
	./docker/docker.sh up -d --build

start:
	./docker/docker.sh up -d

stop:
	./docker/docker.sh stop

remove:
	./docker/docker.sh down -v
