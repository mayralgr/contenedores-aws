#!/bin/bash

set -e

IMAGE_NAME="ecs-demo"
IMAGE_VERSION="${1:-1.0}"
CONTAINER_NAME="ecs-demo-container"
PORT="8080"

echo "Iniciando contenedor..."

# Si ya existe, lo elimina
podman rm -f $CONTAINER_NAME 2>/dev/null || true

podman run -d \
  --name $CONTAINER_NAME \
  -p $PORT:80 \
  $IMAGE_NAME:$IMAGE_VERSION

echo ""
echo "Contenedor corriendo."
echo "Abre en tu navegador:"
echo "http://localhost:$PORT"