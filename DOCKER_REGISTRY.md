# Usando Imagens Docker do GitHub Container Registry

Este documento explica como usar as imagens Docker publicadas automaticamente no GitHub Container Registry.

## 📦 Imagens Disponíveis

As imagens são automaticamente construídas e publicadas em:
- **Registry:** `ghcr.io`
- **Repository:** `ghcr.io/ricardoapaes/rustdesk-custom`

### Tags Disponíveis

| Tag | Descrição | Quando é criada |
|-----|-----------|-----------------|
| `latest` | Última versão da branch principal | A cada push na `main` |
| `develop` | Versão de desenvolvimento | A cada push na `develop` |
| `v1.0.0` | Versão específica de release | Quando uma release é publicada |
| `1.0` | Versão major.minor | Quando uma release é publicada |
| `1` | Versão major | Quando uma release é publicada |

## 🚀 Uso Básico

### 1. Baixar a imagem

```bash
# Última versão estável
docker pull ghcr.io/ricardoapaes/rustdesk-custom:latest

# Versão específica
docker pull ghcr.io/ricardoapaes/rustdesk-custom:v1.0.0

# Versão de desenvolvimento
docker pull ghcr.io/ricardoapaes/rustdesk-custom:develop
```

### 2. Executar com variáveis de ambiente

```bash
docker run --rm \
  -e ID_SERVER_HOST="seu.servidor.com" \
  -e ENCRYPTION_KEY="sua_chave_aqui" \
  -e APP_NAME="RustDesk - Sua Empresa" \
  -e APP_PUBLISHER="Sua Empresa Ltda" \
  -v $(pwd)/output:/build/Output \
  ghcr.io/ricardoapaes/rustdesk-custom:latest
```

### 3. Usando docker-compose

Atualize seu `docker-compose.yml`:

```yaml
version: '3.8'
services:
  rustdesk-builder:
    image: ghcr.io/ricardoapaes/rustdesk-custom:latest
    environment:
      - ID_SERVER_HOST=${ID_SERVER_HOST}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - APP_NAME=${APP_NAME:-RustDesk - Instalador Personalizado}
      - APP_VERSION=${APP_VERSION:-1.0.0}
      - APP_PUBLISHER=${APP_PUBLISHER:-Instalador Automático}
    volumes:
      - ./output:/build/Output
    restart: "no"
```

Execute:

```bash
cp .env.example .env
# Edite o arquivo .env com suas configurações
docker-compose up
```

## 🔐 Autenticação

### Para repositórios públicos
Não é necessária autenticação para baixar imagens.

### Para repositórios privados
```bash
# Login com GitHub Token
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Ou usando GitHub CLI
gh auth token | docker login ghcr.io -u USERNAME --password-stdin
```

## 🏷️ Versionamento

O projeto segue [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x): Mudanças incompatíveis na API
- **MINOR** (x.1.x): Novas funcionalidades compatíveis
- **PATCH** (x.x.1): Correções de bugs compatíveis

### Exemplo de tags para release v1.2.3:
- `ghcr.io/ricardoapaes/rustdesk-custom:v1.2.3`
- `ghcr.io/ricardoapaes/rustdesk-custom:1.2`
- `ghcr.io/ricardoapaes/rustdesk-custom:1`
- `ghcr.io/ricardoapaes/rustdesk-custom:latest`

## 🔄 Builds Automáticos

### Quando as imagens são construídas:

1. **Push para `main`**: Cria tag `latest`
2. **Push para `develop`**: Cria tag `develop`
3. **Nova Release**: Cria tags versionadas (`v1.0.0`, `1.0`, `1`, `latest`)
4. **Manual**: Via workflow_dispatch com tag personalizada

### Status dos builds:
[![Docker Build](https://github.com/ricardoapaes/rustdesk-custom/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ricardoapaes/rustdesk-custom/actions/workflows/docker-build.yml)

## 🚨 Solução de Problemas

### Erro: "pull access denied"
- Verifique se o repositório é público
- Se privado, faça login: `docker login ghcr.io`

### Erro: "image not found"
- Verifique se a tag existe
- Lista de tags: https://github.com/ricardoapaes/rustdesk-custom/pkgs/container/rustdesk-custom

### Imagem desatualizada
- Force pull: `docker pull ghcr.io/ricardoapaes/rustdesk-custom:latest`
- Limpe cache: `docker system prune -a`

## 📊 Monitoramento

### Ver logs do build:
1. Acesse: https://github.com/ricardoapaes/rustdesk-custom/actions
2. Clique no workflow "Build and Push Docker Image"
3. Visualize os logs detalhados

### Verificar imagem publicada:
- https://github.com/ricardoapaes/rustdesk-custom/pkgs/container/rustdesk-custom

## 💡 Dicas de Uso

### Fixar versão em produção:
```yaml
# ✅ Bom - versão fixa
image: ghcr.io/ricardoapaes/rustdesk-custom:v1.0.0

# ⚠️ Cuidado - pode mudar
image: ghcr.io/ricardoapaes/rustdesk-custom:latest
```

### Testar nova versão:
```bash
# Comparar versões
docker run --rm ghcr.io/ricardoapaes/rustdesk-custom:v1.0.0 --version
docker run --rm ghcr.io/ricardoapaes/rustdesk-custom:latest --version
```

### Backup local:
```bash
# Salvar imagem localmente
docker save ghcr.io/ricardoapaes/rustdesk-custom:v1.0.0 > rustdesk-builder-v1.0.0.tar

# Carregar de backup
docker load < rustdesk-builder-v1.0.0.tar
```