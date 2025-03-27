#!/bin/bash

echo "☑️ Baixando a imagem do Nginx..."
docker pull nginx

echo "☑️ Iniciando o contêiner..."
docker run -d --name meu-servidor nginx

echo "☑️ Listando contêineres em execução..."
docker ps

echo "☑️ Parando o contêiner..."
docker stop meu-servidor

echo "☑️ Removendo o contêiner..."
docker rm meu-servidor

echo "☑️ Listando todos os contêineres..."
docker ps -a

echo "✅ Finalizado!"


