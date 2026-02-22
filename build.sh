#!/bin/bash

set -e

IMAGE_NAME="ecs-demo"
IMAGE_VERSION="${1:-1.0}"

echo "Construyendo imagen..."
echo "Nombre: $IMAGE_NAME"
echo "Versión: $IMAGE_VERSION"

podman build -t $IMAGE_NAME:$IMAGE_VERSION .

echo ""
echo "Imagen construida correctamente:"
echo "$IMAGE_NAME:$IMAGE_VERSION"