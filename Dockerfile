# Base Ubuntu 22.04
FROM ubuntu:22.04

# Evitar prompts durante instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar paquetes necesarios y dependencias
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    nano \
    ttyd \
    wget \
    git \
    build-essential \
    cmake \
    libjson-c-dev \
    libwebsockets-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Trabajamos como root directamente
USER root
WORKDIR /root

# Instalar EarnApp automáticamente
RUN wget -qO- https://brightdata.com/static/earnapp/install.sh > /tmp/earnapp.sh \
    && bash /tmp/earnapp.sh \
    && rm -f /tmp/earnapp.sh

# Puerto para ttyd
ENV PORT=8080

# Comando para iniciar ttyd
CMD ["ttyd", "-p", "8080", "bash"]
