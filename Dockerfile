FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    nano \
    ttyd \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Trabajamos como root directamente
USER root
WORKDIR /root

ENV PORT=8080
CMD ["ttyd", "-p", "8080", "bash"]
