#!/bin/bash
# Script para baixar a última versão EXE x64 do RustDesk

set -e

echo "🔍 Buscando a última versão do RustDesk..."

# URL da API do GitHub para obter a última release
API_URL="https://api.github.com/repos/rustdesk/rustdesk/releases/latest"

# Obter informações da última release
RELEASE_DATA=$(curl -s "$API_URL")

# Extrair a tag da versão
VERSION=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
echo "📦 Versão encontrada: $VERSION"

# Procurar pelo arquivo EXE x64
EXE_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | test(".*x86_64.*\\.exe$")) | .browser_download_url' | head -1)

if [ -z "$EXE_URL" ] || [ "$EXE_URL" = "null" ]; then
    echo "❌ Erro: Não foi possível encontrar o arquivo EXE x64"
    echo "🔍 Arquivos disponíveis:"
    echo "$RELEASE_DATA" | jq -r '.assets[].name'
    exit 1
fi

# Nome do arquivo EXE
EXE_FILENAME=$(basename "$EXE_URL")
echo "📁 Arquivo: $EXE_FILENAME"
echo "🔗 URL: $EXE_URL"

# Verificar se o arquivo já existe
if [ -f "/build/$EXE_FILENAME" ]; then
    echo "✅ Arquivo já existe: $EXE_FILENAME"
    echo "EXE_FILE=$EXE_FILENAME" > /build/rustdesk.env
    echo "RUSTDESK_VERSION=$VERSION" >> /build/rustdesk.env
    exit 0
fi

# Baixar o arquivo EXE
echo "⬇️  Baixando $EXE_FILENAME..."
curl -L -o "/build/$EXE_FILENAME" "$EXE_URL"

# Verificar se o download foi bem-sucedido
if [ -f "/build/$EXE_FILENAME" ]; then
    echo "✅ Download concluído: $EXE_FILENAME"
    echo "📊 Tamanho: $(du -h "/build/$EXE_FILENAME" | cut -f1)"
    
    # Salvar informações em arquivo de ambiente
    echo "EXE_FILE=$EXE_FILENAME" > /build/rustdesk.env
    echo "RUSTDESK_VERSION=$VERSION" >> /build/rustdesk.env
    
    echo "✅ Script de download concluído com sucesso!"
else
    echo "❌ Erro: Falha no download do arquivo"
    exit 1
fi