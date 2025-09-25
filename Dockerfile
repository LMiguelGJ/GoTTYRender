FROM alpine:latest

# Instalar bash y ttyd
RUN apk add --no-cache bash ttyd

# Crear usuario no root
RUN adduser -D webterm
USER webterm
WORKDIR /home/webterm

ENV PORT=8080

# Lanzar ttyd (terminal web en $PORT)
CMD ["ttyd", "-p", "8080", "bash"]
