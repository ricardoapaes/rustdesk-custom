#!/bin/bash
# Script para baixar a última versão MSI x64 do RustDesk

set -e

echo "🔍 Buscando a última versão do RustDesk..."

# URL da API do GitHub para obter a última release
API_URL="https://api.github.com/repos/rustdesk/rustdesk/releases/latest"

# Obter informações da última release
RELEASE_DATA=$(curl -s "$API_URL")

# Extrair a tag da versão
VERSION=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
echo "📦 Versão encontrada: $VERSION"

# Procurar pelo arquivo MSI x64
MSI_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | test(".*x86_64.*\\.msi$")) | .browser_download_url' | head -1)

if [ -z "$MSI_URL" ] || [ "$MSI_URL" = "null" ]; then
    echo "❌ Erro: Não foi possível encontrar o arquivo MSI x64"
    echo "🔍 Arquivos disponíveis:"
    echo "$RELEASE_DATA" | jq -r '.assets[].name'
    exit 1
fi

# Nome do arquivo MSI
MSI_FILENAME=$(basename "$MSI_URL")
echo "📁 Arquivo: $MSI_FILENAME"
echo "🔗 URL: $MSI_URL"

# Verificar se o arquivo já existe
if [ -f "/build/$MSI_FILENAME" ]; then
    echo "✅ Arquivo já existe: $MSI_FILENAME"
    echo "MSI_FILE=$MSI_FILENAME" > /build/rustdesk.env
    echo "RUSTDESK_VERSION=$VERSION" >> /build/rustdesk.env
    exit 0
fi

# Baixar o arquivo MSI
echo "⬇️  Baixando $MSI_FILENAME..."
curl -L -o "/build/$MSI_FILENAME" "$MSI_URL"

# Verificar se o download foi bem-sucedido
if [ -f "/build/$MSI_FILENAME" ]; then
    echo "✅ Download concluído: $MSI_FILENAME"
    echo "📊 Tamanho: $(du -h "/build/$MSI_FILENAME" | cut -f1)"
    
    # Salvar informações em arquivo de ambiente
    echo "MSI_FILE=$MSI_FILENAME" > /build/rustdesk.env
    echo "RUSTDESK_VERSION=$VERSION" >> /build/rustdesk.env
    
    echo "✅ Script de download concluído com sucesso!"
else
    echo "❌ Erro: Falha no download do arquivo"
    exit 1
fi