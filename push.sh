#!/bin/bash

set -e

# Configuración
IMAGE_NAME="ecs-demo-static"
IMAGE_VERSION="${1:-1.0}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Obtener Account ID automáticamente
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

ECR_REPO="$IMAGE_NAME"
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_VERSION"

echo "Preparando push a ECR..."
echo "Imagen local: $IMAGE_NAME:$IMAGE_VERSION"
echo "Destino ECR: $ECR_URI"
echo ""

# Crear repositorio si no existe (no falla si ya existe)
aws ecr create-repository \
  --repository-name "$ECR_REPO" \
  --region "$AWS_REGION" 2>/dev/null || true

# Login a ECR
echo "Haciendo login en ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
| podman login \
  --username AWS \
  --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Tag
echo "Etiquetando imagen..."
podman tag "$IMAGE_NAME:$IMAGE_VERSION" "$ECR_URI"

# Push
echo "Subiendo imagen a ECR..."
podman push "$ECR_URI"

echo ""
echo "Imagen subida correctamente a:"
echo "$ECR_URI"