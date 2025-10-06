# Gerador de Instalador RustDesk Personalizado

[![Docker Build](https://github.com/ricardoapaes/rustdesk-custom/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ricardoapaes/rustdesk-custom/actions/workflows/docker-build.yml)
[![CI](https://github.com/ricardoapaes/rustdesk-custom/actions/workflows/ci.yml/badge.svg)](https://github.com/ricardoapaes/rustdesk-custom/actions/workflows/ci.yml)
[![Container Registry](https://img.shields.io/badge/container-ghcr.io-blue)](https://github.com/ricardoapaes/rustdesk-custom/pkgs/container/rustdesk-custom)

Este projeto automatiza a criação de instaladores personalizados do RustDesk usando Docker e Inno Setup. O sistema baixa automaticamente a última versão MSI x64 do repositório oficial do RustDesk e gera um instalador customizado com suas configurações.

## 🚀 Características

- ✅ Download automático da última versão do RustDesk
- ✅ Geração de instalador personalizado com Inno Setup  
- ✅ Configuração automática de servidor ID/Relay
- ✅ Instalação silenciosa como serviço do Windows
- ✅ Container Docker isolado para build
- ✅ Suporte a configurações personalizadas
- ✅ Imagens Docker pré-construídas no GitHub Container Registry
- ✅ CI/CD automatizado com GitHub Actions

## 📦 Imagens Docker

As imagens são automaticamente construídas e publicadas no GitHub Container Registry:

- **Registry:** `ghcr.io/ricardoapaes/rustdesk-custom`
- **Tags:** `latest`, `develop`, versões específicas (ex: `v1.0.0`)
- **Documentação completa:** [DOCKER_REGISTRY.md](DOCKER_REGISTRY.md)

## 📋 Pré-requisitos

- Docker instalado e funcionando
- Acesso à internet para download do RustDesk

## 🔧 Como Usar

### 1. Usando imagem pré-construída (Recomendado)

```bash
# Usar imagem do GitHub Container Registry
docker run --rm \
  -e ID_SERVER_HOST="seu.servidor.com" \
  -e ENCRYPTION_KEY="sua_chave_de_criptografia" \
  -e APP_NAME="RustDesk - Sua Empresa" \
  -e APP_PUBLISHER="Sua Empresa Ltda" \
  -v $(pwd)/output:/build/Output \
  ghcr.io/ricardoapaes/rustdesk-custom:latest
```

### 2. Build local da imagem Docker

```bash
docker build -t rustdesk-installer-builder .
```

### 3. Gerar instalador com configuração automática

```bash
docker run --rm \
  -e ID_SERVER_HOST="seu.servidor.com" \
  -e ENCRYPTION_KEY="sua_chave_de_criptografia" \
  -e APP_NAME="RustDesk - Sua Empresa" \
  -e APP_PUBLISHER="Sua Empresa Ltda" \
  -v $(pwd)/output:/build/Output \
  rustdesk-installer-builder
```

### 4. Usando docker-compose (recomendado)

```bash
# 1. Configure suas variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com suas configurações

# 2. Execute o build
docker-compose up --build
```

### 4. Configuração manual via docker-compose.yml

Se preferir não usar arquivo `.env`, crie um arquivo `docker-compose.yml`:

```yaml
version: '3.8'
services:
  rustdesk-builder:
    build: .
    environment:
      - ID_SERVER_HOST=seu.servidor.com
      - ENCRYPTION_KEY=sua_chave_aqui
      - APP_NAME=RustDesk - Sua Empresa
      - APP_PUBLISHER=Sua Empresa Ltda
    volumes:
      - ./output:/build/Output
```

Execute:

```bash
docker-compose up --build
```

## ⚙️ Variáveis de Ambiente

| Variável | Descrição | Obrigatório | Exemplo |
|----------|-----------|-------------|---------|
| `ID_SERVER_HOST` | Servidor ID/Relay do RustDesk | Não | `relay.exemplo.com` |
| `ENCRYPTION_KEY` | Chave de criptografia | Não | `chave123` |
| `APP_NAME` | Nome do aplicativo no instalador | Não | `RustDesk - Empresa` |
| `APP_VERSION` | Versão do instalador | Não | `1.0.0` |
| `APP_PUBLISHER` | Nome da empresa/publisher | Não | `Sua Empresa` |

## 📁 Estrutura de Arquivos

```text
acesso-remoto/
├── Dockerfile              # Imagem Docker principal
├── download-rustdesk.sh     # Script de download automático
├── setup.iss               # Script Inno Setup
├── build.sh                # Script principal de build
├── docker-compose.yml      # Exemplo docker-compose
├── config.toml             # Configuração opcional (se existir)
└── README.md               # Esta documentação
```

## 🎯 Funcionalidades do Instalador Gerado

O instalador final irá:

1. **Instalar o RustDesk** via MSI oficial
2. **Configurar automaticamente** o servidor (se fornecido)
3. **Instalar como serviço** para inicialização automática
4. **Criar atalhos** no desktop e menu iniciar
5. **Suportar instalação silenciosa** com `/SILENT`

## 📖 Modos de Instalação

### Instalação com Interface

```cmd
RustDesk_Instalador_Customizado_v1.2.3.exe
```

### Instalação Silenciosa

```cmd
RustDesk_Instalador_Customizado_v1.2.3.exe /SILENT
```

### Instalação Muito Silenciosa (sem prompts)

```cmd
RustDesk_Instalador_Customizado_v1.2.3.exe /VERYSILENT
```

## 🔍 Solução de Problemas

### Erro de download

- Verifique conexão com internet
- Confirme se o GitHub está acessível

### Erro de compilação

- Verifique logs do container: `docker logs <container_id>`
- Confirme se todas as variáveis estão corretas

### Problema com MSI

- O script sempre baixa a versão mais recente
- Verifique se existe versão MSI x64 disponível

## 🛡️ Segurança

- **Chaves de criptografia**: Nunca commite chaves reais no repositório
- **Variáveis de ambiente**: Use sempre variáveis de ambiente para dados sensíveis
- **Verification**: O script verifica a integridade dos downloads

## 📝 Logs e Debug

Para debug detalhado, execute o container interativamente:

```bash
docker run -it --rm \
  -e ID_SERVER_HOST="seu.servidor.com" \
  -v $(pwd)/output:/build/Output \
  rustdesk-installer-builder bash
```

Então execute manualmente:

```bash
./download-rustdesk.sh
./build.sh
```

## 🔄 Atualizações

O sistema sempre baixa a **última versão disponível** do RustDesk. Para forçar uma nova verificação, simplesmente execute o build novamente.

## 📞 Suporte

- Para problemas com o RustDesk: [GitHub RustDesk](https://github.com/rustdesk/rustdesk)
- Para problemas com este instalador: Abra uma issue neste repositório

## 📄 Licença

Este projeto segue a mesma licença do RustDesk original. Verifique os termos antes do uso comercial.
