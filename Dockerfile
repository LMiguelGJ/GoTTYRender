FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias para Grass
RUN apt-get update && \
    apt-get install -y wget libgtk-3-0 libwebkit2gtk-4.1-0 libappindicator3-1 xvfb && \
    rm -rf /var/lib/apt/lists/*

# Descargar e instalar Grass 5.7.1
RUN wget https://files.grass.io/file/grass-extension-upgrades/v5.7.1/Grass_5.7.1_amd64.deb -O /tmp/Grass_5.7.1_amd64.deb && \
    dpkg -i /tmp/Grass_5.7.1_amd64.deb || apt-get install -f -y && \
    rm -f /tmp/Grass_5.7.1_amd64.deb

# Directorio de trabajo
WORKDIR /root

# Exponer puerto 3000 del Webtop (si planeas usarlo desde navegador)
EXPOSE 3000

# Comando por defecto al iniciar el contenedor
CMD ["/init"]
