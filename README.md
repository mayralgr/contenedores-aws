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

## ECS (En consola)

Resumido:

- Argumentos:
Task Definition (Fargate)
Image: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/ecs-demo:1.0 # reemplazar con la imagen que subieron
Container port: 80

- Service - Argumentos:
Fargate
Desired tasks: 1
Public IP: Enabled 
Security Group inbound:
TCP 80 desde 0.0.0.0/0 # Abres la Public IP del task en el navegador para observar

Paso a Paso:

1. Ir a ECS
- Entra a AWS Console
- Busca ECS (Elastic Container Service)
- Haz clic en Create cluster

2. Crear Cluster (Express / Simplified)
Selecciona:
- Express configuration (o similar nombre simplificado)
Luego:
- Cluster name: ecs-demo-cluster
- Infrastructure: AWS Fargate

Click en Create y espera a que termine.

3. Crear Task Definition (necesario en NO Express)
- ECS → Task definitions → Create new task definition
- name: ecs-demo-td
- Selecciona:
  - Launch type / Compatibility: Fargate
  - os architecture: Linux/X86_64
  - Configura “Task size”:
    - CPU: 0.25 vCPU
    - Memory: 0.5 GB
  - Roles:
    - Task execution role: ecsTaskExecutionRole (viene por default pero si no existe, créalo desde el wizard (debe incluir permisos para pull de ECR + logs).
    - Task role: vacío.

- Container definition (Add container):
  - Container name: ecs-demo (essential container:yes)
  - Image URI: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/ecs-demo:1.0
  -  Port mappings: 80 TCP (containerPort 80)

Desactivar Logging configuration: awslogs (si lo habilitas, verás logs en CloudWatch pero tiene costo)

Create task definition.

4. Crear Security Group - ⚠️ No usar default security group.
Ir a: EC2 → Security Groups
- Click en Create security group
  - Configura:
    - Name: ecs-demo-public-sg
    - Description: Allow HTTP access to ECS demo
    - VPC: default VPC (la misma del cluster)
    - Inbound rules
      - Agregar:

| Type	| Protocol	| Port |	Source |
| --- | --- | --- | --- |
| HTTP |	TCP	|80|	0.0.0.0/0|

Outbound rules - Dejar por default:
All traffic - 0.0.0.0/0

Click en Create security group

5. Crear Service (Directamente desde el cluster, sin ALB, solo Public IP)
Entra al cluster recién creado.ECS → Clusters → entra a ecs-demo-cluster)
Haz clic en:
- Create service
- Task definition: selecciona la que creaste (la última revision)
- Service name: ecs-demo-service
- Environment:
  - Launch type / Capacity provider: Fargate
- Deployment configuration:
  - Desired tasks: 1
  - Deseleccionar Turn on Availability Zone rebalancing
- Networking:
  - default vpc
  - default subnets
  - default security group
  - public ip: turned on
Create service y espera.


6. Validar que el Task esté “RUNNING”
- Entra al Service → pestaña Tasks
- Abre el Task → verifica estado RUNNING
Busca:
- Public IP (o “Network” → Public IP)

7. Obtener la URL
Entra al Service
- Click en el Task
Busca: Public IP
Copia esa IP y abre en el navegador:
http://PUBLIC_IP


Existe un modo express, que crea todo pero usa un ALB e infrastructura completa que es más caro de ejecutar.

Express mode:
Image URI - Del ECR creado
- Image: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/ecs-demo:1.0 # 
Container port: 80
Name: ecs-demo


### Clean up

### ECS
En clusters, ver al cluster creado (ecs-demo-cluster) y selecciona en acciones, delete cluster.

Confirma

Para eliminar las task definitions, primero entra a las revisiones, dales deregister


### SG
- Elimina el security group creado tambien

### ECR
1. Ve a ecr -> repositorio y elimina las imagenes
2. Una vez eliminadas, selecciona el repositorio en ecr -> repositorios -> delete