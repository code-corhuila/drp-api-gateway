#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_FILE="${ENV_FILE:-env/dev.env.example}"
compose=(docker compose --env-file "$ENV_FILE" -f deploy/compose.yml)

"${compose[@]}" up -d --wait

cleanup() { "${compose[@]}" down --remove-orphans >/dev/null 2>&1 || true; }
trap cleanup EXIT

port="$(grep -E '^GATEWAY_PORT=' "$ENV_FILE" | cut -d= -f2)"
base="http://127.0.0.1:${port}"

code="$(curl -sS -o /tmp/gw-health.json -w '%{http_code}' "$base/health")"
test "$code" = "200"
grep -q '"status":"ok"' /tmp/gw-health.json

code="$(curl -sS -o /tmp/gw-401.json -w '%{http_code}' "$base/api/v1/spaces/available")"
test "$code" = "401"
grep -q '"error":"UNAUTHORIZED"' /tmp/gw-401.json

# Public login must not be blocked for missing Bearer (upstream may 502).
code="$(curl -sS -o /dev/null -w '%{http_code}' -X POST "$base/api/v1/auth/login" \
  -H 'Content-Type: application/json' -d '{}')"
test "$code" != "401"
