#!/bin/bash
# Script de exemplo para demonstrar o uso do arquivo .env

set -e

echo "🔧 Demonstração de uso com arquivo .env"
echo "======================================"

# Verificar se arquivo .env existe
if [ -f ".env" ]; then
    echo "✅ Arquivo .env encontrado"
    echo ""
    
    echo "📋 Configurações atuais no .env:"
    echo "--------------------------------"
    
    # Mostrar configurações (mascarando dados sensíveis)
    if grep -q "^ID_SERVER_HOST=" .env; then
        SERVER=$(grep "^ID_SERVER_HOST=" .env | cut -d'=' -f2)
        echo "🌐 Servidor: $SERVER"
    fi
    
    if grep -q "^ENCRYPTION_KEY=" .env; then
        KEY=$(grep "^ENCRYPTION_KEY=" .env | cut -d'=' -f2)
        if [ ${#KEY} -gt 8 ]; then
            MASKED_KEY="${KEY:0:4}***${KEY: -4}"
        else
            MASKED_KEY="***"
        fi
        echo "🔐 Chave: $MASKED_KEY"
    fi
    
    if grep -q "^APP_NAME=" .env; then
        APP_NAME=$(grep "^APP_NAME=" .env | cut -d'=' -f2)
        echo "📱 Nome do App: $APP_NAME"
    fi
    
    if grep -q "^APP_PUBLISHER=" .env; then
        PUBLISHER=$(grep "^APP_PUBLISHER=" .env | cut -d'=' -f2)
        echo "🏢 Publisher: $PUBLISHER"
    fi
    
    echo ""
    echo "▶️  Para gerar o instalador, execute:"
    echo "   docker-compose up --build"
    
else
    echo "❌ Arquivo .env não encontrado"
    echo ""
    echo "📝 Para criar o arquivo de configuração:"
    echo "   1. Copie o exemplo: cp .env.example .env"
    echo "   2. Edite suas configurações: nano .env"
    echo "   3. Execute: docker-compose up --build"
    echo ""
    echo "💡 Ou use o modo interativo:"
    echo "   ./generate.sh --custom"
fi

echo ""
echo "📖 Para mais exemplos, consulte:"
echo "   - README.md"
echo "   - EXAMPLES.md"