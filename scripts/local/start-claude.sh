#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker nao encontrado. Instale/inicie o Docker Desktop com integracao WSL2." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker Desktop nao esta em execucao ou nao esta integrado a esta distro WSL." >&2
  exit 1
fi

if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
  cat >&2 <<'EOF'
CLAUDE_CODE_OAUTH_TOKEN nao esta definido.

1. Instale e autentique o Claude Code.
2. Gere o token com: claude setup-token
3. No mesmo terminal, defina:
   export CLAUDE_CODE_OAUTH_TOKEN='cole-o-token-aqui'
4. Execute este script novamente.
EOF
  exit 1
fi

if [[ ! -f config.toml ]]; then
  cp config.example.toml config.toml
  sed -i 's/^llm_provider = "moonshot"$/llm_provider = "claude_code"/' config.toml
  echo "config.toml criado com llm_provider=claude_code."
fi

docker compose -f docker-compose.claude.yml up -d --build
docker compose -f docker-compose.claude.yml ps

cat <<'EOF'

MoneyPrinterTurbo iniciado:
  WebUI: http://127.0.0.1:8501
  API:   http://127.0.0.1:8080/docs

O token existe somente neste processo/terminal e nao e gravado no repositorio.
EOF
