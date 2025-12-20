# 🏗️ Tech Challenge - Infraestrutura Kubernetes (EKS)

Este repositório contém a infraestrutura como código (IaC) para o projeto [Tech Challenge](https://github.com/PosTechFiapGrupo/tech-challenge), uma API REST para gerenciamento de ordens de serviço de oficina mecânica.

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Topologia da VPC](#-topologia-da-vpc)
- [Módulos Terraform](#-módulos-terraform)
- [Pré-requisitos](#-pré-requisitos)
- [Configuração Inicial](#-configuração-inicial)
- [Deploy da Infraestrutura](#-deploy-da-infraestrutura)
- [Configuração do kubeconfig](#-configuração-do-kubeconfig)
- [Arquivos Kubernetes](#-arquivos-kubernetes)
- [Outputs do Terraform](#-outputs-do-terraform)
- [Troubleshooting](#-troubleshooting)
- [Contribuição](#-contribuição)

---

## 🎯 Visão Geral

Esta infraestrutura provisiona todos os recursos AWS necessários para executar a aplicação Tech Challenge em produção, incluindo:

- **VPC** com subnets públicas e privadas em múltiplas Availability Zones
- **EKS (Elastic Kubernetes Service)** para orquestração de containers
- **Security Groups** configurados com princípio de menor privilégio
- **IAM Roles** com suporte a IRSA (IAM Roles for Service Accounts)
- **Backend Remoto** para estado do Terraform (S3 + DynamoDB)

---

## 🏛️ Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    AWS Cloud                                      │
│  ┌────────────────────────────────────────────────────────────────────────────┐  │
│  │                              VPC (10.0.0.0/16)                             │  │
│  │                                                                            │  │
│  │  ┌──────────────────────────┐    ┌──────────────────────────────────────┐ │  │
│  │  │    Public Subnets        │    │         Private Subnets              │ │  │
│  │  │                          │    │                                      │ │  │
│  │  │  ┌────────────────────┐  │    │  ┌────────────────────────────────┐  │ │  │
│  │  │  │ AZ-a: 10.0.101.0/24│  │    │  │    AZ-a: 10.0.1.0/24           │  │ │  │
│  │  │  │  ┌──────────────┐  │  │    │  │  ┌────────────────────────┐    │  │ │  │
│  │  │  │  │ NAT Gateway  │  │  │    │  │  │   EKS Worker Nodes     │    │  │ │  │
│  │  │  │  └──────────────┘  │  │    │  │  │   (Node Group)         │    │  │ │  │
│  │  │  └────────────────────┘  │    │  │  └────────────────────────┘    │  │ │  │
│  │  │                          │    │  └────────────────────────────────┘  │ │  │
│  │  │  ┌────────────────────┐  │    │                                      │ │  │
│  │  │  │ AZ-b: 10.0.102.0/24│  │    │  ┌────────────────────────────────┐  │ │  │
│  │  │  │  ┌──────────────┐  │  │    │  │    AZ-b: 10.0.2.0/24           │  │ │  │
│  │  │  │  │     ALB      │  │  │    │  │  ┌────────────────────────┐    │  │ │  │
│  │  │  │  └──────────────┘  │  │    │  │  │   EKS Worker Nodes     │    │  │ │  │
│  │  │  └────────────────────┘  │    │  │  │   (Node Group)         │    │  │ │  │
│  │  │                          │    │  │  └────────────────────────┘    │  │ │  │
│  │  │  ┌────────────────────┐  │    │  └────────────────────────────────┘  │ │  │
│  │  │  │ AZ-c: 10.0.103.0/24│  │    │                                      │ │  │
│  │  │  └────────────────────┘  │    │  ┌────────────────────────────────┐  │ │  │
│  │  │                          │    │  │    AZ-c: 10.0.3.0/24           │  │ │  │
│  │  └──────────────────────────┘    │  │  ┌────────────────────────┐    │  │ │  │
│  │                                  │  │  │      RDS MySQL         │    │  │ │  │
│  │  ┌──────────────────────────┐    │  │  │    (Multi-AZ)          │    │  │ │  │
│  │  │    Internet Gateway      │    │  │  └────────────────────────┘    │  │ │  │
│  │  └──────────────────────────┘    │  └────────────────────────────────┘  │ │  │
│  │                                  └──────────────────────────────────────┘ │  │
│  │                                                                            │  │
│  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                      EKS Control Plane (Managed)                     │  │  │
│  │  └─────────────────────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🌐 Topologia da VPC

### Estrutura de Rede

| Componente | CIDR | Descrição |
|------------|------|-----------|
| **VPC** | `10.0.0.0/16` | VPC principal com 65.536 IPs disponíveis |
| **Private Subnet AZ-a** | `10.0.1.0/24` | Subnet privada para workers EKS e RDS |
| **Private Subnet AZ-b** | `10.0.2.0/24` | Subnet privada para workers EKS e RDS |
| **Private Subnet AZ-c** | `10.0.3.0/24` | Subnet privada para workers EKS e RDS |
| **Public Subnet AZ-a** | `10.0.101.0/24` | Subnet pública para NAT Gateway |
| **Public Subnet AZ-b** | `10.0.102.0/24` | Subnet pública para ALB |
| **Public Subnet AZ-c** | `10.0.103.0/24` | Subnet pública para ALB |

### Fluxo de Rede

```
Internet
    │
    ▼
┌──────────────────┐
│ Internet Gateway │
└────────┬─────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐  ┌─────┐
│  ALB  │  │ NAT │
│(Public)│ │ GW  │
└───┬───┘  └──┬──┘
    │         │
    ▼         ▼
┌─────────────────────────────┐
│      Private Subnets        │
│  ┌─────────┐  ┌──────────┐  │
│  │   EKS   │  │   RDS    │  │
│  │ Workers │──│  MySQL   │  │
│  └─────────┘  └──────────┘  │
└─────────────────────────────┘
```

### Security Groups

| Security Group | Portas | Origem | Destino |
|----------------|--------|--------|---------|
| **eks-cluster-sg** | 443 | EKS Nodes | Control Plane |
| **eks-nodes-sg** | All | Self, Control Plane | Tudo |
| **rds-mysql-sg** | 3306 | EKS Nodes, Lambda | RDS |
| **lambda-sg** | All Egress | Lambda | VPC/Internet |
| **alb-sg** | 80, 443 | Internet | EKS Nodes |

---

## 📦 Módulos Terraform

### 1. Módulo VPC (`terraform/modules/vpc/`)

Responsável por criar toda a infraestrutura de rede:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name         = "tech-challenge"
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
```

**Recursos criados:**
- VPC com DNS habilitado
- Subnets públicas e privadas em 3 AZs
- Internet Gateway
- NAT Gateway (com opção de single ou multi-AZ)
- Route Tables
- VPC Flow Logs

### 2. Módulo Security Groups (`terraform/modules/security-groups/`)

Define todas as regras de segurança de rede:

```hcl
module "security_groups" {
  source = "./modules/security-groups"
  
  project_name = "tech-challenge"
  environment  = "dev"
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = "10.0.0.0/16"
}
```

**Security Groups criados:**
- `eks-cluster-sg`: Control Plane do EKS
- `eks-nodes-sg`: Worker Nodes do EKS
- `rds-mysql-sg`: RDS MySQL (porta 3306 apenas para EKS e Lambda)
- `lambda-sg`: Lambda functions
- `alb-sg`: Application Load Balancer

### 3. Módulo EKS (`terraform/modules/eks/`)

Provisiona o cluster Kubernetes gerenciado:

```hcl
module "eks" {
  source = "./modules/eks"
  
  project_name          = "tech-challenge"
  environment           = "dev"
  cluster_version       = "1.29"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_subnet_ids     = module.vpc.public_subnet_ids
  eks_security_group_id = module.security_groups.eks_cluster_sg_id
  node_instance_types   = ["t3.medium"]
  node_desired_size     = 2
  node_min_size         = 1
  node_max_size         = 4
}
```

**Recursos criados:**
- EKS Cluster com logs habilitados
- Node Group com Auto Scaling
- IAM Roles para cluster e nodes
- OIDC Provider para IRSA
- KMS Key para encryption
- EKS Addons (VPC CNI, CoreDNS, kube-proxy, EBS CSI)

---

## ✅ Pré-requisitos

1. **AWS CLI** configurado com credenciais válidas
   ```bash
   aws configure
   ```

2. **Terraform** >= 1.5.0
   ```bash
   terraform --version
   ```

3. **kubectl** instalado
   ```bash
   kubectl version --client
   ```

4. **Permissões AWS** necessárias:
   - IAM Full Access (para criar roles)
   - VPC Full Access
   - EKS Full Access
   - S3 Full Access (para backend)
   - DynamoDB Full Access (para locks)

---

## 🚀 Configuração Inicial

### 1. Clone o repositório

```bash
git clone https://github.com/PosTechFiapGrupo/k8s-infra.git
cd k8s-infra
```

### 2. Configure as variáveis

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` conforme necessário:

```hcl
project_name = "tech-challenge"
environment  = "dev"
aws_region   = "us-east-1"

# Ajuste o tamanho dos nodes conforme necessidade
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 2
eks_node_min_size       = 1
eks_node_max_size       = 4
```

### 3. Crie o Backend Remoto (primeira vez)

```bash
cd terraform/bootstrap
terraform init
terraform apply -var-file=../terraform.tfvars
terraform output -raw state_bucket_name
```

---

## 📦 Deploy da Infraestrutura

### Deploy Completo

```bash
cd ../

BUCKET="$(cd bootstrap && terraform output -raw terraform_state_bucket)"
REGION="us-east-1"
NS="grupo19"   # use um namespace diferente por pessoa (ex: rian, emerson, grupo19)

# Inicializar
terraform init -reconfigure \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="key=infra/${NS}/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"


# Visualizar mudanças
terraform plan -var-file=terraform.tfvars

# Aplicar infraestrutura
terraform apply -var-file=terraform.tfvars
```

### Deploy por Módulo

```bash
# Apenas VPC
terraform apply -target=module.vpc

# Apenas Security Groups
terraform apply -target=module.security_groups

# Apenas EKS
terraform apply -target=module.eks
```

### Destruir Infraestrutura

```bash
# Visualizar o que será destruído
terraform plan -destroy -var-file=terraform.tfvars

# Destruir tudo
terraform destroy -var-file=terraform.tfvars
```

---

## ⚙️ Configuração do kubeconfig

Após o deploy do EKS, configure o acesso ao cluster:

### Método 1: Usando AWS CLI (Recomendado)

```bash
# Obter o nome do cluster do output do Terraform
terraform output eks_cluster_name

# Configurar kubeconfig
aws eks update-kubeconfig \
  --name tech-challenge-dev-eks \
  --region us-east-1
```

### Método 2: Usando o output do Terraform

```bash
# O comando completo está disponível no output
terraform output kubeconfig_command

# Execute o comando retornado
$(terraform output -raw kubeconfig_command)
```

### Verificar Conexão

```bash
# Verificar contexto atual
kubectl config current-context

# Listar nodes
kubectl get nodes

# Verificar pods do sistema
kubectl get pods -n kube-system
```

### Múltiplos Clusters

Se você trabalha com múltiplos clusters:

```bash

# Pega o contexto diretamente do Terraform (sem precisar do eks_cluster_name)
EKS_CONTEXT="$(terraform output -raw kubectl_config_context)"

# Listar contextos
kubectl config get-contexts

# Alternar contexto
kubectl config use-context "${EKS_CONTEXT}"

# Criar alias automático
alias k-dev="kubectl --context=${EKS_CONTEXT}"

echo "Contexto configurado: ${EKS_CONTEXT}"

---

## 📂 Arquivos Kubernetes

Os manifestos base estão em `k8s/base/`:

| Arquivo | Descrição |
|---------|-----------|
| `namespace.yaml` | Namespace `tech-challenge` |
| `deployment.yaml` | Deployment da API com HPA e PDB |
| `service.yaml` | Services (LoadBalancer, ClusterIP, Headless) |
| `configmap.yaml` | Configurações não-sensíveis |
| `secret.yaml` | Template para secrets (vazio) |
| `serviceaccount.yaml` | ServiceAccount com IRSA |
| `ingress.yaml` | Ingress com AWS ALB Controller |

### Aplicar Manifestos

```bash
# Aplicar todos os manifestos
kubectl apply -f k8s/base/

# Ou individualmente
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secret.yaml
kubectl apply -f k8s/base/deployment.yaml
kubectl apply -f k8s/base/service.yaml
```

### Configurar Secrets

```bash
# Criar secret com valores reais
kubectl create secret generic tech-challenge-secrets \
  --namespace=tech-challenge \
  --from-literal=DB_USER=tech_user \
  --from-literal=DB_PASSWORD=sua_senha_segura \
  --from-literal=SECRET_KEY=seu_jwt_secret

# Ou editar o arquivo e aplicar
kubectl apply -f k8s/base/secret.yaml
```

---

## 📊 Outputs do Terraform

Após o `terraform apply`, os seguintes outputs estarão disponíveis:

```bash
# Ver todos os outputs
terraform output

# Outputs específicos
terraform output vpc_id
terraform output private_subnet_ids
terraform output eks_security_group_id
terraform output rds_allowed_sg_id
terraform output eks_cluster_endpoint
terraform output kubeconfig_command
```

### Outputs Principais

| Output | Descrição |
|--------|-----------|
| `vpc_id` | ID da VPC criada |
| `private_subnet_ids` | IDs das subnets privadas |
| `public_subnet_ids` | IDs das subnets públicas |
| `eks_security_group_id` | SG do cluster EKS |
| `rds_allowed_sg_id` | SG permitido para RDS |
| `eks_cluster_endpoint` | Endpoint da API do EKS |
| `eks_oidc_provider_arn` | ARN do OIDC para IRSA |
| `kubeconfig_command` | Comando para configurar kubectl |

---

## 🔧 Troubleshooting

### Erro: "Cluster not found"

```bash
# Verificar se o cluster existe
aws eks list-clusters --region us-east-1

# Verificar credenciais AWS
aws sts get-caller-identity
```

### Erro: "Unauthorized"

```bash
# Verificar se o usuário/role tem permissão
aws eks describe-cluster --name tech-challenge-dev-eks

# Atualizar aws-auth ConfigMap se necessário
kubectl edit configmap aws-auth -n kube-system
```

### Nodes não ficam Ready

```bash
# Verificar status dos nodes
kubectl describe nodes

# Verificar logs do kubelet (via SSM)
aws ssm start-session --target <instance-id>
```

### Pods em Pending

```bash
# Verificar eventos
kubectl describe pod <pod-name> -n tech-challenge

# Verificar recursos disponíveis
kubectl top nodes
```

## 🔄 CI/CD – Pipelines de Infraestrutura

Este repositório utiliza **GitHub Actions** para gerenciar o ciclo de vida da infraestrutura AWS/EKS com **Terraform**, garantindo segurança, previsibilidade e controle, especialmente em produção.

---

## Pipeline: Terraform PR

### Objetivo
Validar mudanças de infraestrutura antes do merge, garantindo **qualidade, padronização e previsibilidade**.

### Gatilho
- `pull_request` para as branches:
  - `main`
  - `develop`

### O que a pipeline faz
- Executa `terraform fmt` para validar formatação
- Inicializa backend remoto no S3 (cria o bucket se necessário)
- Valida a configuração (`terraform validate`)
- Gera o plano de execução (`terraform plan`) sem aplicar mudanças

### Benefícios
- Evita erros em produção
- Padroniza o código Terraform
- Dá visibilidade clara das mudanças propostas no PR

---

## Pipeline: Deploy Production

### Objetivo
Realizar o **deploy completo da infraestrutura e da aplicação em produção**, de forma manual e controlada.

### Gatilho
- `workflow_dispatch`
- Requer confirmação explícita: `deploy_prod = true`
- Executa no environment protegido `production`

### O que a pipeline faz
- Executa um *safety check* para evitar deploy acidental
- Resolve automaticamente o arquivo `tfvars`
- Garante e inicializa o backend remoto no S3
- Aplica a infraestrutura com `terraform apply`
- Configura o `kubectl` usando outputs do Terraform
- Aplica os manifests Kubernetes:
  - Addons (`k8s/addons`)
  - Aplicação (`k8s/base`)

### Benefícios
- Deploy auditável e reproduzível
- Infraestrutura e aplicação versionadas
- Nenhum acesso manual ao cluster
- Redução de erro humano

---

## Pipeline: Destroy Production

### Objetivo
Executar a **destruição completa da infraestrutura de produção** de forma **segura e consciente**.

### Gatilho
- `workflow_dispatch`
- Exige confirmação textual: `destroy-prod`
- Executa no environment protegido `production`

### Proteções implementadas
- Confirmação manual obrigatória
- Validação de que o ambiente é `prod` ou `production`
- Verificação da existência do backend remoto
- Execução isolada da pipeline (sem reaproveitar jobs)

### O que a pipeline faz
- Valida a confirmação de destruição
- Seleciona o `terraform.tfvars.prod`
- Inicializa o backend remoto existente
- Executa `terraform destroy` com `-auto-approve`

### Benefícios
- Evita destruições acidentais
- Processo explícito e auditável
- Total controle sobre ações destrutivas

---

## 🧠 Visão Geral

| Pipeline | Função |
|--------|-------|
| **Terraform PR** | Validação e planejamento das mudanças |
| **Deploy Production** | Provisionamento e deploy da infra + app |
| **Destroy Production** | Remoção completa da infra de produção |

---

## Boas práticas adotadas
- Backend remoto com S3 e lock
- Separação clara entre validação, deploy e destroy
- Uso de environments protegidos
- Confirmações explícitas para ações críticas
- Infraestrutura como código versionada

---

## 🤝 Contribuição

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Crie um Pull Request

---

## 📝 Licença

Este projeto é parte do Tech Challenge FIAP e está licenciado sob a [MIT License](LICENSE).

---

## 👥 Time

**FIAP - Grupo 19**

- Tech Challenge - Pós-graduação em Arquitetura de Software
