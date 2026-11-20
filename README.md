# monorepo-template

Monorepo com frontend (React + Vite, bun workspaces) e backend (Go), orquestrado por Makefile e Docker Compose.

```
.
├── apps/
│   ├── web/                  # React + Vite + TanStack Router + Lingui (bun workspace)
│   │   ├── Dockerfile        # build do bundle -> nginx (proxy /api -> api)
│   │   └── nginx.conf
│   └── api/                  # Go
│       ├── cmd/api/          # entrypoint (HTTP server)
│       ├── internal/
│       │   ├── config/       # variáveis de ambiente (.env via godotenv/autoload)
│       │   ├── database/     # pool pgx
│       │   ├── repository/   # código gerado pelo sqlc (não editar)
│       │   └── server/       # rotas HTTP (GET /hello)
│       ├── migrations/       # golang-migrate (*.up.sql / *.down.sql)
│       ├── queries/          # queries SQL do sqlc
│       ├── sqlc.yaml
│       └── Dockerfile
├── packages/                 # workspace bun para código compartilhado (vazio)
├── docker-compose.yml        # postgres, migrate, api, web
├── Makefile
└── package.json              # workspaces: apps/*, packages/*
```

## Pré-requisitos

- [bun](https://bun.com) 1.4+
- Go 1.26+
- Docker com Compose v2
- make

## Primeiros passos

```bash
make install          # bun install + go mod download
make up               # sobe tudo em Docker: web :3000, api :8080, postgres :5432
curl localhost:8080/hello          # {"message":"hello world"}
open http://localhost:3000         # a página mostra a resposta de /api/hello
make down
```

Se alguma porta já estiver em uso no host, sobrescreva com variáveis (ou copie `.env.example` para `.env`):

```bash
API_HOST_PORT=18080 WEB_HOST_PORT=13000 POSTGRES_HOST_PORT=15432 make up
```

## Desenvolvimento local (hot reload)

```bash
make dev-api          # postgres em Docker + migrations + API Go em :8080
make dev-web          # Vite em :3000; /api é proxied para :8080
```

## Banco de dados

```bash
make migrate-create name=add_users   # cria par *.up.sql / *.down.sql
make migrate-up                      # aplica migrations (golang-migrate, em Docker)
make migrate-down                    # reverte a última
make sqlc                            # regenera apps/api/internal/repository
```

Escreva as queries em `apps/api/queries/*.sql` e rode `make sqlc`. O `sqlc.yaml` lê o schema das migrations `*.up.sql` e `*.down.sql` (o down usa `DROP TABLE IF EXISTS`, então não quebra a leitura).

## Outros comandos

```bash
make lint     # biome (web) + go vet (api)
make build    # bundle do web + binário em apps/api/bin/api
make test     # go test ./...
make help     # lista todos os targets
```
