#!/bin/bash

set -e

# Nome do volume e container
VOLUME_NAME="nginx_logs"
CONTAINER_NAME="container_1"
CONTAINER_NAME_2="container_2"

echo "📦 Criando volume compartilhado..."
docker volume create $VOLUME_NAME

echo "🐳 Subindo container com Ubuntu e Nginx..."
docker run -d --name $CONTAINER_NAME -v $VOLUME_NAME:/var/log/nginx -p 8080:8080 ubuntu:20.04 tail -f /dev/null

echo "🔧 Instalando Nginx no container..."
docker exec -it $CONTAINER_NAME bash -c "
    echo 'America/Sao_Paulo' > /etc/timezone &&
    DEBIAN_FRONTEND=noninteractive apt-get update &&
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata nginx curl &&
    dpkg-reconfigure -f noninteractive tzdata"


echo "⚙️ Configurando Nginx para responder na porta 8080..."
docker exec -it $CONTAINER_NAME bash -c "cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 8080;
    location / {
        return 200 'OK - Teste de log\n';
        access_log /var/log/nginx/access.log;
    }
}
EOF"

echo "🚀 Iniciando o Nginx..."
docker exec -it $CONTAINER_NAME service nginx restart

echo "📡 Testando requisição curl para http://localhost:8080"
curl -s http://localhost:8080
curl -s http://localhost:8080
curl -s http://localhost:8080
curl -s http://localhost:8080

echo "📜 Logs de acesso do Nginx:"
docker exec -it $CONTAINER_NAME cat /var/log/nginx/access.log

echo "⚰️ Derrubando o primeiro container..."
docker rm -f $CONTAINER_NAME

echo "🐳 Subindo o segundo container com Nginx..."
docker run -d --name $CONTAINER_NAME_2 -v $VOLUME_NAME:/var/log/nginx -p 8081:8080 ubuntu:20.04 tail -f /dev/null

echo "🔧 Instalando Nginx no segundo container..."
docker exec -it $CONTAINER_NAME_2 bash -c "
    echo 'America/Sao_Paulo' > /etc/timezone &&
    DEBIAN_FRONTEND=noninteractive apt-get update &&
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata nginx curl &&
    dpkg-reconfigure -f noninteractive tzdata"

echo "⚙️ Configurando Nginx no segundo container para responder na porta 8080..."
docker exec -it $CONTAINER_NAME_2 bash -c "cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 8080;
    location / {
        return 200 'OK - Teste de log no segundo container\n';
        access_log /var/log/nginx/access.log;
    }
}
EOF"

echo "🚀 Iniciando o Nginx no segundo container..."
docker exec -it $CONTAINER_NAME_2 service nginx restart

docker exec -it $CONTAINER_NAME_2 cat /var/log/nginx/access.log