# Dockerfile para gerar instalador RustDesk personalizado
FROM docker.io/amake/innosetup:latest

# Instalar dependências como root primeiro
USER root
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    wget \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Verificar e corrigir permissões do Wine
RUN if [ -d /home/xclient/.wine ]; then \
        chown -R xclient /home/xclient/.wine; \
    fi

# Permitir que xclient use sudo sem senha para chown
RUN echo "xclient ALL=(ALL) NOPASSWD: /bin/chown, /bin/mkdir, /bin/cp, /bin/chmod" >> /etc/sudoers

# Voltar ao usuário xclient para usar o Wine configurado
USER xclient

WORKDIR /build

COPY download-rustdesk.sh /build/
COPY setup.iss /build/
COPY build.sh /build/

# Ajustar permissões dos scripts como root
USER root
RUN chmod +x /build/download-rustdesk.sh /build/build.sh && \
    chown -R xclient /build && \
    mkdir -p /build/Output && \
    chmod 777 /build/Output

# Voltar ao usuário xclient
USER xclient

ENV ID_SERVER_HOST=""
ENV ENCRYPTION_KEY=""
ENV APP_NAME="Acesso Remoto"
ENV APP_VERSION="1.0.0"
ENV APP_PUBLISHER="Sua Empresa"

VOLUME ["/build/Output"]

ENTRYPOINT ["/build/build.sh"]