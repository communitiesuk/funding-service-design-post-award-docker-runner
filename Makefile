SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c


.PHONY: bootstrap
bootstrap:
	./scripts/bootstrap.sh
	if [ ! -f .env ]; then \
		cp .env.example .env; \
	fi


.PHONY: certs
certs:
	mkcert -install
	mkcert -cert-file certs/cert.pem -key-file certs/key.pem "*.levellingup.gov.localhost"


.PHONY: up
up:
	docker compose up


.PHONY: down
down:
	docker compose down

