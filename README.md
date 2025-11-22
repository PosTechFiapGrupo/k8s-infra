## Pipeline CI/CD

- GitHub Actions configurado em `.github/workflows/infra.yml`.
- Fluxo:
  - **Pull Request → main**: `terraform fmt`, `terraform validate`, `terraform plan`.
  - **Push em main (homolog)**: `terraform apply` automático.
  - **Tag v*** (produção): `terraform apply` em ambiente de produção com approval via environment `prod`.
- Credenciais de AWS separadas por ambiente (secrets diferentes).

## Add-ons do EKS

Add-ons instalados via Terraform + Helm:

- `metrics-server`: métricas de CPU/memória para HPA.
- `cluster-autoscaler`: escala de nodes do EKS com base na demanda.
- `aws-load-balancer-controller`: criação de ALB a partir de objetos Ingress.
- `external-secrets-operator`: integração com AWS Secrets Manager.

Manifestos K8s criados:

- `k8s/app/ingress.yaml`: expõe a aplicação via ALB.
- `k8s/app/hpa.yaml`: configura o HorizontalPodAutoscaler.
- `k8s/app/secretstore.yaml`: aponta para o AWS Secrets Manager.
- `k8s/app/externalsecret.yaml`: gera o Secret com as credenciais do RDS MySQL.