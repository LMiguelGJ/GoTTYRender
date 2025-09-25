FROM golang:1.20-alpine

# Instalar dependencias
RUN apk add --no-cache bash git

# Instalar GoTTY (fork actualizado)
RUN go install github.com/sorenisanerd/gotty@latest

# Crear usuario no root
RUN adduser -D webterm
USER webterm
WORKDIR /home/webterm

# Render inyecta $PORT, así que usamos esa variable
ENV PORT=8080

# Lanzar GoTTY con credenciales
CMD ["gotty", "-w", "--port", "${PORT}", "--credential", "admin:1234", "bash"]
