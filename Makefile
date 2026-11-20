SHELL := /bin/bash
.DEFAULT_GOAL := help

API_DIR     := apps/api
WEB_DIR     := apps/web
MIGRATE_IMG := migrate/migrate:v4.18.3
COMPOSE     := docker compose

.PHONY: help install dev-db migrate-up migrate-down migrate-create sqlc dev-api dev-web up down logs build lint test clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

install: ## Install bun workspace deps and Go modules
	bun install
	cd $(API_DIR) && go mod download

dev-db: ## Start only PostgreSQL in docker
	$(COMPOSE) up -d --wait postgres

migrate-up: dev-db ## Apply all migrations (dockerized golang-migrate)
	$(COMPOSE) run --rm migrate up

migrate-down: dev-db ## Roll back the last migration
	$(COMPOSE) run --rm migrate down 1

migrate-create: ## Create a migration pair: make migrate-create name=add_users
	@test -n "$(name)" || (echo "usage: make migrate-create name=<name>" && exit 1)
	docker run --rm --user $$(id -u):$$(id -g) -v $(CURDIR)/$(API_DIR)/migrations:/migrations $(MIGRATE_IMG) create -ext sql -dir /migrations -seq $(name)

sqlc: ## Regenerate internal/repository from queries/ and migrations/
	cd $(API_DIR) && go tool sqlc generate

dev-api: migrate-up ## Run the Go API locally on :8080 (reads apps/api/.env)
	@test -f $(API_DIR)/.env || cp $(API_DIR)/.env.example $(API_DIR)/.env
	cd $(API_DIR) && go run ./cmd/api

dev-web: ## Run the Vite dev server on :3000 (proxies /api to :8080)
	bun --filter @monorepo/web dev

up: ## Build and start the full stack in docker (web :3000, api :8080, db :5432)
	$(COMPOSE) up -d --build

down: ## Stop the docker stack
	$(COMPOSE) down

logs: ## Follow docker logs
	$(COMPOSE) logs -f

build: ## Build web and api
	bun run build
	cd $(API_DIR) && go build -o bin/api ./cmd/api

lint: ## Lint web (biome) and api (go vet)
	bun run lint
	cd $(API_DIR) && go vet ./...

test: ## Run Go tests
	cd $(API_DIR) && go test ./...

clean: ## Stop the stack, drop the db volume and remove build output
	$(COMPOSE) down -v
	rm -rf $(API_DIR)/bin $(WEB_DIR)/dist
