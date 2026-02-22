# contenedores-aws
Este repositorio contiene un proyecto simple para desplegar un contenedor minimo en aws ECS

###  Comandos a seguir:
Construir imagen
```
podman build -t ecs-demo:1.0 .
```
o correr el script build.sh
```
chmod +x build.sh
./build.sh
```
también se puede correr con una version
```
./build.sh 1.1
```
Para correr localmente:
```
podman run -p 8080:80 ecs-demo:1.0
```
o correr el script run.sh
```
chmod +x run.sh
./run.sh
```
o con version
```
./run.sh 1.1
```
Debe correr en http://localhost:8080

### ECR + ECS
- podman build
- podman tag
- podman push a ECR
- ECS Task Definition
- ECS Service (Fargate)
- Abrir IP pública
```
export AWS_REGION="us-east-1" # se puede ajustar
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export ECR_REPO="ecs-demo-static"
export IMAGE_TAG="1.0"
```
Crear repositorio de ECR, en comando o en la consola (solo 1 vez)
```
aws ecr create-repository \
  --repository-name "$ECR_REPO" \
  --region "$AWS_REGION"
  ```

Login en ECR
```
aws ecr get-login-password --region "$AWS_REGION" \
| podman login \
  --username AWS \
  --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
```
Tag y Push
```
podman tag ecs-demo:1.0 "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG"
podman push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG"
```
o usar el script push.sh
```
chmod +x push.sh
./push.sh
```
y con versión
```
./push.sh 1.1
```
ECS (En consola)

Argumentos:
Task Definition (Fargate)
Image: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/ecs-demo:1.0 # reemplazar con la imagen que subieron
Container port: 80
Environment variables:
APP_ENV=prod
APP_VERSION=1.0.0

Service - Argumentos:
Fargate
Desired tasks: 1
Public IP: Enabled 
Security Group inbound:
TCP 80 desde 0.0.0.0/0 # Abres la Public IP del task en el navegador para observar

