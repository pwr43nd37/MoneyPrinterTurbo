$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
Set-Location $repoRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker nao encontrado. Instale/inicie o Docker Desktop com WSL2."
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Docker Desktop nao esta em execucao."
}

if ([string]::IsNullOrWhiteSpace($env:CLAUDE_CODE_OAUTH_TOKEN)) {
    throw @"
CLAUDE_CODE_OAUTH_TOKEN nao esta definido.

1. Instale e autentique o Claude Code.
2. Gere o token com: claude setup-token
3. No mesmo PowerShell, defina:
   `$env:CLAUDE_CODE_OAUTH_TOKEN = "cole-o-token-aqui"
4. Execute este script novamente.
"@
}

if (-not (Test-Path "config.toml")) {
    Copy-Item "config.example.toml" "config.toml"
    $config = Get-Content "config.toml" -Raw
    $config = $config.Replace('llm_provider = "moonshot"', 'llm_provider = "claude_code"')
    Set-Content "config.toml" $config -Encoding utf8
    Write-Host "config.toml criado com llm_provider=claude_code."
}

docker compose -f docker-compose.claude.yml up -d --build
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao iniciar a stack local."
}

docker compose -f docker-compose.claude.yml ps

Write-Host ""
Write-Host "MoneyPrinterTurbo iniciado:"
Write-Host "  WebUI: http://127.0.0.1:8501"
Write-Host "  API:   http://127.0.0.1:8080/docs"
Write-Host ""
Write-Host "O token existe somente neste processo/terminal e nao e gravado no repositorio."
