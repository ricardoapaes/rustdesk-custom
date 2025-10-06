# Exemplos de Uso - Gerador de Instalador RustDesk

Este arquivo contém exemplos práticos de como usar o gerador de instaladores RustDesk.

## 🔧 Configuração Inicial

### Método Recomendado: Arquivo .env

```bash
# 1. Copie o arquivo de exemplo
cp .env.example .env

# 2. Edite com suas configurações
nano .env  # ou use seu editor preferido

# 3. Execute
docker-compose up --build
```

## 🚀 Uso Rápido

### 1. Instalador Personalizado (modo interativo)

```bash
./generate.sh --custom
```

### 2. Instalador via Linha de Comando

```bash
./generate.sh \
  --server "relay.suaempresa.com" \
  --key "sua_chave_super_secreta" \
  --name "RustDesk - Sua Empresa" \
  --publisher "Sua Empresa Ltda"
```

### 3. Usando Docker Compose (Recomendado)o Docker Compose (Recomendado)

```bash
# Método 1: Usando arquivo .env (recomendado)
cp .env.example .env
# Edite o arquivo .env com suas configurações
docker-compose up --build

# Método 2: Editando docker-compose.yml diretamente
# Edite docker-compose.yml com suas configurações
docker-compose up --build
```de Instalador RustDesk

Este arquivo contém exemplos práticos de como usar o gerador de instaladores RustDesk.

## 🚀 Uso Rápido

### 1. Instalador Personalizado (modo interativo)

```bash
./generate.sh --custom
```

### 2. Instalador Completo via Linha de Comando

```bash
./generate.sh \
  --server "relay.suaempresa.com" \
  --key "sua_chave_super_secreta" \
  --name "RustDesk - Sua Empresa" \
  --publisher "Sua Empresa Ltda"
```

### 4. Usando Docker Compose (Recomendado)

```bash
# Edite docker-compose.yml com suas configurações
docker-compose up --build
```

## 🛠️ Configuração do Servidor RustDesk

Antes de usar, você precisará ter:

1. **Servidor RustDesk funcionando** (com ID/Relay server)
2. **Chave de criptografia** configurada no servidor
3. **Acesso ao servidor** para obter esses dados

### Onde encontrar essas informações

- **Servidor ID/Relay**: IP ou domínio do seu servidor RustDesk
- **Chave**: Gerada durante a configuração do servidor
- Consulte: <https://rustdesk.com/docs/en/self-host/>

## 📋 Exemplos por Cenário

### Cenário 1: Empresa Pequena

```bash
./generate.sh \
  --server "192.168.1.100" \
  --key "abcd1234efgh5678" \
  --name "RustDesk - MinhaEmpresa" \
  --publisher "MinhaEmpresa Ltda"
```

### Cenário 2: Empresa com Domínio Próprio

```bash
./generate.sh \
  --server "remotoaccess.minhaempresa.com" \
  --key "chave_super_segura_aqui" \
  --name "Acesso Remoto Corporativo" \
  --publisher "MinhaEmpresa S.A."
```

### Cenário 3: Instalador para Cliente

```bash
./generate.sh \
  --server "acesso.provedor.com" \
  --key "cliente123_chave_especifica" \
  --name "RustDesk - Cliente ABC" \
  --publisher "Provedor de TI Ltda"
```

### Cenário 4: Instalação em Lote (Várias Configurações)

```bash
# Para cliente A
./generate.sh --server "relay.servidor.com" --key "clienteA_key" --name "RustDesk ClienteA"

# Para cliente B  
./generate.sh --server "relay.servidor.com" --key "clienteB_key" --name "RustDesk ClienteB"

# Para cliente C
./generate.sh --server "relay.servidor.com" --key "clienteC_key" --name "RustDesk ClienteC"
```

## 🔧 Configuração Avançada com Docker Compose

Edite `docker-compose.yml`:

```yaml
version: '3.8'
services:
  # Para cliente específico
  cliente-abc:
    build: .
    environment:
      - ID_SERVER_HOST=relay.servidor.com
      - ENCRYPTION_KEY=chave_cliente_abc
      - APP_NAME=RustDesk - Cliente ABC
      - APP_PUBLISHER=Sua Empresa TI
    volumes:
      - ./output/cliente-abc:/build/Output

  # Para instalação corporativa
  corporativo:
    build: .
    environment:
      - ID_SERVER_HOST=acesso.empresa.com
      - ENCRYPTION_KEY=chave_corporativa_2024
      - APP_NAME=Acesso Remoto Corporativo
      - APP_PUBLISHER=Departamento de TI
    volumes:
      - ./output/corporativo:/build/Output
```

Execute:

```bash
docker-compose up --build cliente-abc
# ou
docker-compose up --build corporativo
```

## 📦 O que você receberá

Após a execução, você encontrará na pasta `output/`:

```text
output/
├── RustDesk_Instalador_Customizado_v1.2.3.exe
└── (logs de compilação se houver)
```

## 🚀 Distribuição do Instalador

### Para Instalação Silenciosa (IT/Automação)

```cmd
RustDesk_Instalador_Customizado_v1.2.3.exe /SILENT
```

### Para Instalação Manual (Usuário Final)

```cmd
RustDesk_Instalador_Customizado_v1.2.3.exe
```

### Para Instalação Via GPO (Active Directory)

```cmd
msiexec /i "RustDesk_Instalador_Customizado_v1.2.3.exe" /quiet /norestart
```

## 🛡️ Segurança

⚠️ **IMPORTANTE**:

- Nunca inclua chaves reais em arquivos versionados
- Use variáveis de ambiente para dados sensíveis
- Teste sempre em ambiente controlado primeiro
- Mantenha backups das configurações

## 🔄 Atualizações

Para atualizar para nova versão do RustDesk:

1. Execute novamente qualquer comando
2. O script baixará automaticamente a versão mais recente
3. Gere novos instaladores com as mesmas configurações

## 📞 Solução de Problemas

### Erro: "Não foi possível encontrar o arquivo MSI x64"

- Verifique conexão com internet
- GitHub pode estar temporariamente indisponível

### Erro: "Falha na compilação"

- Verifique se Docker está rodando
- Confirme que todas as variáveis estão corretas
- Execute em modo debug: `docker run -it rustdesk-installer-builder bash`

### Instalador não configura automaticamente

- Confirme se ID_SERVER_HOST e ENCRYPTION_KEY estão corretos
- Teste conectividade com o servidor manualmente
- Verifique logs do RustDesk após instalação
