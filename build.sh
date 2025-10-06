#!/bin/bash
# Script principal para automatizar todo o processo de build

set -e

echo "🚀 Iniciando processo de build do instalador RustDesk personalizado..."
echo "=================================================="

# Verificar se as variáveis de ambiente estão definidas
if [ -z "$ID_SERVER_HOST" ] || [ -z "$ENCRYPTION_KEY" ]; then
    echo "❌ ERRO: Variáveis ID_SERVER_HOST e ENCRYPTION_KEY são obrigatórias!"
    echo ""
    echo "   Um instalador RustDesk sem servidor configurado não é útil."
    echo "   Para configurar, defina as variáveis de ambiente:"
    echo "   -e ID_SERVER_HOST=seu.servidor.com"
    echo "   -e ENCRYPTION_KEY=sua_chave_aqui"
    echo ""
    echo "Exemplo de uso:"
    echo "docker run --rm \\"
    echo "  -e ID_SERVER_HOST=\"meu.servidor.com\" \\"
    echo "  -e ENCRYPTION_KEY=\"minha_chave\" \\"
    echo "  -v \$(pwd)/output:/build/Output \\"
    echo "  rustdesk-installer-builder"
    echo ""
    exit 1
fi

# Etapa 1: Baixar a última versão do RustDesk
echo "📦 Etapa 1: Baixando a última versão do RustDesk..."
/build/download-rustdesk.sh

# Carregar informações do arquivo de ambiente
if [ -f "/build/rustdesk.env" ]; then
    source /build/rustdesk.env
    echo "✅ Informações carregadas:"
    echo "   📁 Arquivo MSI: $MSI_FILE"
    echo "   🏷️  Versão: $RUSTDESK_VERSION"
else
    echo "❌ Erro: Arquivo de ambiente não encontrado"
    exit 1
fi

# Definir variáveis de ambiente para o Inno Setup
export MSI_FILE
export RUSTDESK_VERSION

# Definir valores padrão se não fornecidos
export APP_NAME="${APP_NAME:-RustDesk - Acesso Remoto Customizado}"
export APP_VERSION="${APP_VERSION:-$RUSTDESK_VERSION}"
export APP_PUBLISHER="${APP_PUBLISHER:-Instalador Automático}"

echo ""
echo "🔧 Etapa 2: Configuração do instalador..."
echo "   📱 Nome do App: $APP_NAME"
echo "   🏷️  Versão: $APP_VERSION" 
echo "   🏢 Publisher: $APP_PUBLISHER"

if [ -n "$ID_SERVER_HOST" ]; then
    echo "   🌐 Servidor ID: $ID_SERVER_HOST"
fi

if [ -n "$ENCRYPTION_KEY" ]; then
    echo "   🔐 Chave: [DEFINIDA]"
fi

echo ""
echo "🔨 Etapa 3: Compilando o instalador com Inno Setup..."

# Compilar o instalador usando Inno Setup
wine ~/.wine/drive_c/InnoSetup6/ISCC.exe /build/setup.iss

# Verificar se a compilação foi bem-sucedida
OUTPUT_FILE="/build/Output/RustDesk_Instalador_Customizado_${RUSTDESK_VERSION}.exe"

if [ -f "$OUTPUT_FILE" ]; then
    echo ""
    echo "✅ Build concluído com sucesso!"
    echo "=================================================="
    echo "📁 Arquivo gerado: $(basename "$OUTPUT_FILE")"
    echo "📊 Tamanho: $(du -h "$OUTPUT_FILE" | cut -f1)"
    echo "📂 Localização: /build/Output/"
    echo ""
    echo "🔧 Para usar o instalador:"
    echo "   • Instalação silenciosa: ./instalador.exe /SILENT"
    echo "   • Instalação com interface: ./instalador.exe"
    echo ""
    
    # Listar todos os arquivos de output
    echo "📋 Arquivos gerados:"
    ls -la /build/Output/
    
else
    echo "❌ Erro: Falha na compilação do instalador"
    echo "Verificando arquivos de log..."
    
    # Mostrar arquivos gerados para debug
    echo "📂 Conteúdo do diretório Output:"
    ls -la /build/Output/ || echo "Diretório Output não encontrado"
    
    exit 1
fi

echo ""
echo "🎉 Processo concluído! O instalador está pronto para uso."