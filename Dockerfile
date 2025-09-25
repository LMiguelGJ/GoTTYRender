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
    systemd \
    hostname \
    dbus \
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

# Crear script de inicio que ejecute EarnApp en background y ttyd en foreground
RUN echo '#!/bin/bash\n\
echo "=== Iniciando servicios ==="\n\
echo "UUID configurado: $EARNAPP_UUID"\n\
\n\
# Inicializar dbus\n\
echo "Iniciando dbus..."\n\
service dbus start\n\
\n\
# Configurar UUID si está definido\n\
if [ ! -z "$EARNAPP_UUID" ]; then\n\
    echo "Configurando UUID: $EARNAPP_UUID"\n\
    /usr/bin/earnapp register $EARNAPP_UUID\n\
fi\n\
\n\
# Limpiar procesos previos de EarnApp\n\
echo "Limpiando procesos previos..."\n\
pkill -f earnapp || true\n\
pkill -f portdetector || true\n\
sleep 2\n\
\n\
# Iniciar EarnApp en background con el comando start\n\
echo "Iniciando EarnApp..."\n\
nohup /usr/bin/earnapp start > /var/log/earnapp.log 2>&1 &\n\
\n\
# Esperar un momento para que EarnApp se inicie\n\
sleep 5\n\
\n\
# Verificar estado de EarnApp\n\
echo "Estado de EarnApp:"\n\
/usr/bin/earnapp status\n\
\n\
# Mostrar procesos activos\n\
echo "Procesos EarnApp activos:"\n\
ps aux | grep -E "(earnapp|portdetector)" | grep -v grep\n\
\n\
# Mostrar últimas líneas del log\n\
echo "Últimas líneas del log:"\n\
tail -n 5 /var/log/earnapp.log\n\
\n\
# Iniciar ttyd en foreground (puerto 8080)\n\
echo "Iniciando terminal web en puerto $PORT..."\n\
exec ttyd -p $PORT bash' > /usr/local/bin/start-services.sh && \
    chmod +x /usr/local/bin/start-services.sh

# Exponer puerto para ttyd
EXPOSE 8080

# Comando de inicio
CMD ["/usr/local/bin/start-services.sh"]
