# Infraestrutura local com Claude pago

Este procedimento executa o MoneyPrinterTurbo no Windows 11 com Docker Desktop e usa o Claude Code autenticado pela assinatura Claude. Ele nao utiliza Ollama nem uma chave da API Anthropic.

## Componentes desta etapa

- MoneyPrinterTurbo WebUI em `http://127.0.0.1:8501`
- MoneyPrinterTurbo API em `http://127.0.0.1:8080/docs`
- Claude Code dentro dos containers para gerar roteiro, palavras-chave e metadados
- Edge TTS para narracao sem chave paga
- armazenamento persistente em `./storage`

n8n e Postiz serao adicionados depois que a geracao local estiver validada. Isso separa problemas de producao de video dos problemas de OAuth/publicacao das redes sociais.

## Pre-requisitos

1. Windows 11 com WSL2 habilitado.
2. Docker Desktop em execucao, usando containers Linux.
3. Git.
4. Claude Code instalado e autenticado em uma assinatura compativel.
5. Uma chave gratuita do Pexels, Pixabay ou Coverr para buscar os materiais do video.

## Clonar o fork

No PowerShell:

```powershell
git clone https://github.com/pwr43nd37/MoneyPrinterTurbo.git
cd MoneyPrinterTurbo
```

Ou, se o repositorio ja estiver clonado:

```powershell
git pull
```

## Autenticar o Claude

Gere um token de assinatura com o cliente oficial:

```powershell
claude setup-token
```

Defina o token apenas no terminal atual. Nao coloque o valor em arquivos versionados:

```powershell
$env:CLAUDE_CODE_OAUTH_TOKEN = "cole-o-token-aqui"
```

No WSL/bash, use:

```bash
export CLAUDE_CODE_OAUTH_TOKEN='cole-o-token-aqui'
```

## Iniciar

PowerShell:

```powershell
.\scripts\local\start-claude.ps1
```

WSL/bash:

```bash
bash scripts/local/start-claude.sh
```

Na primeira execucao, o script:

1. valida o Docker;
2. cria `config.toml` a partir do exemplo, caso ainda nao exista;
3. seleciona `claude_code` como provider;
4. constroi a imagem com o Claude Code;
5. inicia WebUI e API somente em `127.0.0.1`.

## Configurar materiais gratuitos

Abra `http://127.0.0.1:8501` e, nas configuracoes basicas:

1. confirme `Claude Code (Claude subscription)` como LLM provider;
2. selecione Pexels, Pixabay ou Coverr;
3. informe a chave gratuita do provedor escolhido;
4. use `Azure TTS V1 / Edge TTS` para a narracao;
5. use formato `9:16`;
6. mantenha publicacao automatica desabilitada nesta primeira validacao.

## Primeiro teste

Use um assunto simples e original, por exemplo:

```text
Tres sinais de que um e-mail pode ser phishing
```

Confirme que o fluxo consegue:

- gerar o roteiro com Claude;
- obter os materiais;
- gerar narracao e legendas;
- produzir um MP4 vertical em `storage`;
- concluir sem solicitar chave da API Anthropic.

## Diagnostico

```powershell
docker compose -f docker-compose.claude.yml ps
docker compose -f docker-compose.claude.yml logs --tail=200 api
docker compose -f docker-compose.claude.yml logs --tail=200 webui
```

No WSL, os mesmos comandos funcionam sem alteracao.

## Parar

PowerShell:

```powershell
.\scripts\local\stop-claude.ps1
```

WSL/bash:

```bash
bash scripts/local/stop-claude.sh
```

O comando remove os containers e a rede, mas preserva `config.toml` e `storage`.

## Seguranca

- `.env` e `config.toml` ja estao ignorados pelo Git.
- nunca envie `CLAUDE_CODE_OAUTH_TOKEN` para o GitHub;
- as portas ficam vinculadas a `127.0.0.1`, sem exposicao direta na rede;
- nao publique a API por Cloudflare Tunnel antes de adicionarmos autenticacao propria.
