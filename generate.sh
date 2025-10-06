#!/bin/bash
# Script auxiliar para facilitar a geração de instaladores RustDesk

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir cabeçalho
print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "   Gerador de Instalador RustDesk Personalizado  "
    echo "=================================================="
    echo -e "${NC}"
}

# Função para mostrar ajuda
show_help() {
    print_header
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  -h, --help              Mostra esta ajuda"
    echo "  -c, --custom            Gera instalador personalizado (interativo)"
    echo "  -q, --quick             Gera usando docker-compose (requer configuração)"
    echo "  --server <servidor>     Define servidor ID/Relay"
    echo "  --key <chave>          Define chave de criptografia"
    echo "  --name <nome>          Define nome do aplicativo"
    echo "  --publisher <publisher> Define publisher do aplicativo"
    echo ""
    echo "Métodos Recomendados:"
    echo "  1. Arquivo .env:        cp .env.example .env && docker-compose up --build"
    echo "  2. Modo interativo:     $0 --custom"
    echo "  3. Linha de comando:    $0 --server HOST --key KEY"
    echo ""
    echo "Exemplos:"
    echo "  $0 --custom                   # Modo interativo"
    echo "  $0 --quick                    # Usando docker-compose"
    echo "  $0 --server meu.server.com --key minhaChave --name \"RustDesk Empresa\""
    echo ""
}

# Função para instalador personalizado (interativo)
build_custom() {
    echo -e "${YELLOW}� Modo de configuração personalizada${NC}"
    echo ""
    
    # Validar que servidor e chave são obrigatórios
    echo -e "${BLUE}ℹ️  ATENÇÃO: Servidor e chave são obrigatórios para um instalador funcional${NC}"
    echo ""
    
    # Coleta informações do usuário
    read -p "🌐 Servidor ID/Relay (obrigatório): " SERVER_HOST
    read -p "🔐 Chave de criptografia (obrigatório): " ENCRYPTION_KEY
    read -p "📱 Nome do aplicativo [RustDesk - Personalizado]: " APP_NAME
    read -p "🏢 Publisher [Instalador Personalizado]: " APP_PUBLISHER
    
    # Validar campos obrigatórios
    if [ -z "$SERVER_HOST" ] || [ -z "$ENCRYPTION_KEY" ]; then
        echo -e "${RED}❌ Erro: Servidor e chave são obrigatórios!${NC}"
        exit 1
    fi
    
    # Define valores padrão
    APP_NAME=${APP_NAME:-"RustDesk - Personalizado"}
    APP_PUBLISHER=${APP_PUBLISHER:-"Instalador Personalizado"}
    
    echo ""
    echo -e "${BLUE}📋 Configurações selecionadas:${NC}"
    echo "   📱 Nome: $APP_NAME"
    echo "   🏢 Publisher: $APP_PUBLISHER"
    [ -n "$SERVER_HOST" ] && echo "   🌐 Servidor: $SERVER_HOST"
    [ -n "$ENCRYPTION_KEY" ] && echo "   🔐 Chave: [DEFINIDA]"
    echo ""
    
    read -p "Continuar? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operação cancelada."
        exit 0
    fi
    
    # Prepara comando Docker
    DOCKER_CMD="docker run --rm"
    
    [ -n "$SERVER_HOST" ] && DOCKER_CMD="$DOCKER_CMD -e ID_SERVER_HOST=\"$SERVER_HOST\""
    [ -n "$ENCRYPTION_KEY" ] && DOCKER_CMD="$DOCKER_CMD -e ENCRYPTION_KEY=\"$ENCRYPTION_KEY\""
    [ -n "$APP_NAME" ] && DOCKER_CMD="$DOCKER_CMD -e APP_NAME=\"$APP_NAME\""
    [ -n "$APP_PUBLISHER" ] && DOCKER_CMD="$DOCKER_CMD -e APP_PUBLISHER=\"$APP_PUBLISHER\""
    
    DOCKER_CMD="$DOCKER_CMD -v \"$(pwd)/output:/build/Output\" rustdesk-installer-builder"
    
    echo -e "${YELLOW}📦 Gerando instalador personalizado...${NC}"
    
    mkdir -p output
    docker build -t rustdesk-installer-builder .
    
    eval $DOCKER_CMD
    
    echo -e "${GREEN}✅ Instalador personalizado gerado com sucesso!${NC}"
    echo -e "📁 Verifique a pasta: ${BLUE}./output/${NC}"
}

# Função para build usando docker-compose
build_quick() {
    echo -e "${YELLOW}⚡ Usando docker-compose para build rápido...${NC}"
    
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "${RED}❌ Arquivo docker-compose.yml não encontrado!${NC}"
        echo "   Execute este script do diretório do projeto."
        exit 1
    fi
    
    echo -e "${BLUE}💡 Dica: Edite docker-compose.yml para definir suas configurações${NC}"
    echo ""
    
    mkdir -p output
    docker-compose up --build rustdesk-builder
    
    echo -e "${GREEN}✅ Build concluído via docker-compose!${NC}"
    echo -e "📁 Verifique a pasta: ${BLUE}./output/${NC}"
}

# Função para build com parâmetros
build_with_params() {
    echo -e "${YELLOW}📦 Gerando instalador com parâmetros fornecidos...${NC}"
    
    # Validar que servidor e chave são obrigatórios
    if [ -z "$SERVER_HOST" ] || [ -z "$ENCRYPTION_KEY" ]; then
        echo -e "${RED}❌ Erro: Servidor (--server) e chave (--key) são obrigatórios!${NC}"
        echo "   Use: $0 --server seu.servidor.com --key sua_chave"
        exit 1
    fi
    
    DOCKER_CMD="docker run --rm"
    
    [ -n "$SERVER_HOST" ] && DOCKER_CMD="$DOCKER_CMD -e ID_SERVER_HOST=\"$SERVER_HOST\""
    [ -n "$ENCRYPTION_KEY" ] && DOCKER_CMD="$DOCKER_CMD -e ENCRYPTION_KEY=\"$ENCRYPTION_KEY\""
    [ -n "$APP_NAME" ] && DOCKER_CMD="$DOCKER_CMD -e APP_NAME=\"$APP_NAME\""
    [ -n "$APP_PUBLISHER" ] && DOCKER_CMD="$DOCKER_CMD -e APP_PUBLISHER=\"$APP_PUBLISHER\""
    
    DOCKER_CMD="$DOCKER_CMD -v \"$(pwd)/output:/build/Output\" rustdesk-installer-builder"
    
    mkdir -p output
    docker build -t rustdesk-installer-builder .
    
    eval $DOCKER_CMD
    
    echo -e "${GREEN}✅ Instalador gerado com sucesso!${NC}"
    echo -e "📁 Verifique a pasta: ${BLUE}./output/${NC}"
}

# Parse dos argumentos
SERVER_HOST=""
ENCRYPTION_KEY=""
APP_NAME=""
APP_PUBLISHER=""
ACTION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--custom)
            ACTION="custom"
            shift
            ;;
        -q|--quick)
            ACTION="quick"
            shift
            ;;
        --server)
            SERVER_HOST="$2"
            shift 2
            ;;
        --key)
            ENCRYPTION_KEY="$2"
            shift 2
            ;;
        --name)
            APP_NAME="$2"
            shift 2
            ;;
        --publisher)
            APP_PUBLISHER="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}❌ Opção desconhecida: $1${NC}"
            echo "Use -h ou --help para ver as opções disponíveis."
            exit 1
            ;;
    esac
done

# Se parâmetros foram fornecidos mas nenhuma ação, usar build com parâmetros
if [ -z "$ACTION" ] && [ -n "$SERVER_HOST$ENCRYPTION_KEY$APP_NAME$APP_PUBLISHER" ]; then
    ACTION="params"
fi

# Se nenhuma ação foi especificada, mostrar ajuda
if [ -z "$ACTION" ]; then
    show_help
    exit 0
fi

# Executar ação selecionada
print_header

case $ACTION in
    custom)
        build_custom
        ;;
    quick)
        build_quick
        ;;
    params)
        build_with_params
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Processo concluído! Instalador pronto para distribuição.${NC}"