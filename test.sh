#!/bin/bash
# Script de teste para verificar se o sistema está funcionando

set -e

echo "🧪 Teste do Sistema Gerador de Instalador RustDesk"
echo "================================================="

# Verificar se Docker está rodando
echo "🐳 Verificando Docker..."
if ! docker --version > /dev/null 2>&1; then
    echo "❌ Docker não encontrado ou não está rodando"
    exit 1
fi
echo "✅ Docker OK"

# Verificar conectividade com GitHub
echo "🌐 Verificando conectividade com GitHub..."
if ! curl -s "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" > /dev/null; then
    echo "❌ Não foi possível conectar ao GitHub"
    exit 1
fi
echo "✅ GitHub acessível"

# Verificar se arquivos necessários existem
echo "📁 Verificando arquivos do projeto..."
required_files=(
    "Dockerfile"
    "setup.iss"
    "download-rustdesk.sh"
    "build.sh"
    "generate.sh"
    "docker-compose.yml"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Arquivo não encontrado: $file"
        exit 1
    fi
done
echo "✅ Todos os arquivos necessários encontrados"

# Verificar permissões dos scripts
echo "🔧 Verificando permissões..."
if [ ! -x "generate.sh" ]; then
    echo "⚠️  Corrigindo permissões do generate.sh..."
    chmod +x generate.sh
fi

if [ ! -x "download-rustdesk.sh" ]; then
    echo "⚠️  Corrigindo permissões do download-rustdesk.sh..."
    chmod +x download-rustdesk.sh
fi

if [ ! -x "build.sh" ]; then
    echo "⚠️  Corrigindo permissões do build.sh..."
    chmod +x build.sh
fi
echo "✅ Permissões OK"

# Teste básico de sintaxe dos scripts
echo "📝 Verificando sintaxe dos scripts..."
bash -n generate.sh && echo "✅ generate.sh - sintaxe OK"
bash -n download-rustdesk.sh && echo "✅ download-rustdesk.sh - sintaxe OK"  
bash -n build.sh && echo "✅ build.sh - sintaxe OK"

# Verificar se consegue obter informações da API do GitHub
echo "📦 Testando API do GitHub..."
API_URL="https://api.github.com/repos/rustdesk/rustdesk/releases/latest"
RELEASE_DATA=$(curl -s "$API_URL")

# Verificar se a resposta contém tag_name (indicando sucesso)
if echo "$RELEASE_DATA" | grep -q '"tag_name"'; then
    VERSION=$(echo "$RELEASE_DATA" | grep '"tag_name"' | head -n1 | cut -d'"' -f4)
    echo "✅ Última versão encontrada: $VERSION"
    
    # Verificar se existe MSI x64 (busca básica)
    if echo "$RELEASE_DATA" | grep -q 'x86_64.*\.msi'; then
        echo "✅ Arquivo MSI x64 provavelmente disponível"
    else
        echo "⚠️  Nenhum arquivo MSI x64 detectado na resposta"
    fi
else
    echo "❌ Erro ao obter informações da API do GitHub"
    echo "   Primeira parte da resposta:"
    echo "$RELEASE_DATA" | head -c 200
    exit 1
fi

# Verificar se jq está disponível no container base
echo "🔍 Verificando dependências do container..."
echo "ℹ️  jq e outras dependências serão instaladas durante o build"

# Teste de build do container (sem executar)
echo "🏗️  Testando build do Dockerfile..."
if docker build -t rustdesk-installer-test . > /dev/null 2>&1; then
    echo "✅ Dockerfile build bem-sucedido"
    docker rmi rustdesk-installer-test > /dev/null 2>&1
else
    echo "❌ Erro no build do Dockerfile"
    exit 1
fi

# Criar diretório de output se não existir
echo "📂 Preparando ambiente..."
mkdir -p output
echo "✅ Diretório output criado"

echo ""
echo "🎉 Todos os testes passaram! Sistema pronto para uso."
echo ""
echo "💡 Próximos passos:"
echo "   1. Execute: ./generate.sh --help"
echo "   2. Para configuração interativa: ./generate.sh --custom"
echo "   3. Para uso direto: ./generate.sh --server SEU_SERVIDOR --key SUA_CHAVE"
echo ""
echo "📋 Para uso em produção:"
echo "   - Configure suas variáveis no docker-compose.yml"
echo "   - Execute: docker-compose up --build"
echo ""