# Dockerfile para gerar instalador RustDesk personalizado
FROM docker.io/amake/innosetup:latest

# Configurar usuário root temporariamente para instalações
USER root

# Instalar dependências necessárias
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório de trabalho
WORKDIR /build

# Copiar scripts e arquivos de configuração
COPY download-rustdesk.sh /build/
COPY setup.iss /build/
COPY build.sh /build/

# Tornar scripts executáveis
RUN chmod +x /build/download-rustdesk.sh /build/build.sh

# Criar diretório para output
RUN mkdir -p /build/Output

# Variáveis de ambiente para configuração do RustDesk
ENV ID_SERVER_HOST=""
ENV ENCRYPTION_KEY=""
ENV APP_NAME="RustDesk - Acesso Remoto"
ENV APP_VERSION="1.0.0"
ENV APP_PUBLISHER="Sua Empresa"

# Volume para output dos instaladores gerados
VOLUME ["/build/Output"]

# Script de entrada que executa todo o processo
ENTRYPOINT ["/build/build.sh"]