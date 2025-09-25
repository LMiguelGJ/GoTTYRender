# Imagen base ligera con Go y bash
FROM golang:1.20-alpine

# Instalar dependencias y GoTTY
RUN apk add --no-cache bash git \
    && go install github.com/yudai/gotty@latest

# Crear usuario no root por seguridad
RUN adduser -D webterm
USER webterm
WORKDIR /home/webterm

# Render expone el puerto en la variable $PORT
# GoTTY usará ese puerto
ENV PORT=8080

# Ejecutar bash a través de GoTTY
# --w = permite escribir en la terminal
# --credential = usuario:contraseña
CMD ["gotty", "-w", "--port", "${PORT}", "--credential", "admin:1234", "bash"]
