# Usamos Ubuntu 22.04 como base
FROM ubuntu:22.04

# Evitamos interacciones y actualizamos paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalamos los paquetes necesarios
RUN apt-get update && apt-get install -y \
    bash \
    sudo \
    curl \
    nano \
    ttyd \
    && rm -rf /var/lib/apt/lists/*

# Creamos un usuario con home y bash
RUN useradd -ms /bin/bash webterm \
    && echo "webterm ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Definimos el usuario por defecto
USER webterm

# Establecemos directorio de trabajo
WORKDIR /home/webterm

# Puerto para ttyd
ENV PORT=8080

# Comando para ejecutar al iniciar el contenedor
CMD ["ttyd", "--writable", "-p", "8080", "bash"]
