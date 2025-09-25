FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar todas las dependencias necesarias para EarnApp
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    nano \
    ttyd \
    sudo \
    coreutils \
    findutils \
    procps \
    net-tools \
    iproute2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Trabajamos como root directamente
USER root
WORKDIR /root

# Variables de entorno
ENV PORT=8080
ENV EARNAPP_UUID=""

# Crear directorios necesarios para EarnApp
RUN mkdir -p /etc/earnapp /var/log/earnapp /tmp

# Descargar e instalar EarnApp automáticamente
RUN ARCH=$(uname -m) && \
    VERSION="1.570.397" && \
    case "$ARCH" in \
        "x86_64"|"amd64") FILE="earnapp-x64-$VERSION" ;; \
        "aarch64"|"arm64") FILE="earnapp-aarch64-$VERSION" ;; \
        "armv7l"|"armv6l") FILE="earnapp-arm7l-$VERSION" ;; \
        *) FILE="earnapp-arm7l-$VERSION" ;; \
    esac && \
    echo "Descargando $FILE para arquitectura $ARCH" && \
    wget -q "https://cdn-earnapp.b-cdn.net/static/$FILE" -O /usr/bin/earnapp && \
    chmod +x /usr/bin/earnapp && \
    echo "$VERSION" > /etc/earnapp/ver && \
    echo "docker-$(date +%s)" > /etc/earnapp/uuid && \
    touch /etc/earnapp/status && \
    chmod 755 /etc/earnapp && \
    chmod 644 /etc/earnapp/*

# Crear script de inicio que maneja ambos servicios
RUN echo '#!/bin/bash\n\
echo "=== Iniciando EarnApp Docker Container ==="\n\
echo "Arquitectura: $(uname -m)"\n\
echo "Version EarnApp: $(cat /etc/earnapp/ver 2>/dev/null || echo "unknown")"\n\
echo "UUID: $(cat /etc/earnapp/uuid 2>/dev/null || echo "not-set")"\n\
echo ""\n\
# Configurar UUID si se proporciona\n\
if [ ! -z "$EARNAPP_UUID" ]; then\n\
    echo "$EARNAPP_UUID" > /etc/earnapp/uuid\n\
    echo "UUID configurado: $EARNAPP_UUID"\n\
fi\n\
echo ""\n\
echo "Iniciando EarnApp en segundo plano..."\n\
nohup /usr/bin/earnapp > /var/log/earnapp/earnapp.log 2>&1 &\n\
EARNAPP_PID=$!\n\
echo "EarnApp iniciado con PID: $EARNAPP_PID"\n\
sleep 3\n\
echo ""\n\
echo "Verificando estado de EarnApp..."\n\
if ps -p $EARNAPP_PID > /dev/null; then\n\
    echo "✓ EarnApp está ejecutándose correctamente"\n\
else\n\
    echo "⚠ EarnApp puede haber fallado al iniciar"\n\
    echo "Últimas líneas del log:"\n\
    tail -10 /var/log/earnapp/earnapp.log 2>/dev/null || echo "No hay logs disponibles"\n\
fi\n\
echo ""\n\
echo "Iniciando terminal web en puerto $PORT..."\n\
echo "Accede a http://localhost:$PORT para usar la terminal web"\n\
echo ""\n\
exec ttyd -p $PORT -i 0.0.0.0 --writable bash' > /usr/local/bin/start-services.sh && \
    chmod +x /usr/local/bin/start-services.sh

# Exponer puerto para ttyd
EXPOSE 8080

# Comando de inicio
CMD ["/usr/local/bin/start-services.sh"]
