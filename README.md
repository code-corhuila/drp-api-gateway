# drp-api-gateway

> Single entry point: authentication, routing and rate limiting

Part of the **SpaceHub (Distributed Reservation Platform)** distributed system — team `distributed-reservation-platform`, Grupo 1.
Governance and documentation live in [`drp-docs`](https://github.com/code-corhuila/drp-docs).

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `drp-docs`.

## What this repo is

NGINX on **:8080** (dev). Credential **presence** only. Each `-api` validates RS256. No Go BFF.

Public: `GET /health`, `POST /api/v1/auth/login`, `GET /api/v1/auth/jwks`.  
Everything else under `/api/v1` needs `Authorization`. Inbound `X-User-*` is stripped.

Availability routes (`/api/v1/spaces/available` and `…/availability`) are declared **before** the spaces prefix.

Start from the same Compose project as [`drp-infra-postgres`](https://github.com/code-corhuila/drp-infra-postgres) so upstream DNS names resolve. Corte 2 `drp-front` still defaults to `failover` if this process is down.

```bash
cp env/dev.env.example env/dev.env
docker compose --env-file env/dev.env -f deploy/compose.yml up -d
curl http://localhost:8080/health
```

Expected: `{"status":"ok","timestamp":"…"}`. A protected path without a header returns `{error, message, traceId}` with **401**.
