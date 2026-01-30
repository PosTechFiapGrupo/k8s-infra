SHELL := /usr/bin/bash
.SHELLFLAGS := -euo pipefail -c

# ===========================
# Defaults (override via: make TFVARS=... NS=... )
# ===========================
TFVARS ?= terraform/terraform.tfvars.prod
NS ?= grupo19
STATE_PREFIX ?= state
REPO := infra-k8s

TF_DIR := terraform
BOOTSTRAP_DIR := terraform/bootstrap

# ===========================
# Helpers
# ===========================
define read_tfvar
awk -F'=' -v k="$(1)" ' \
  $$1 ~ "^[[:space:]]*"k"[[:space:]]*$$" { \
    gsub(/#.*/, "", $$2); \
    gsub(/[[:space:]]|"/, "", $$2); \
    print $$2; exit \
  }' "$(TFVARS)"
endef

# Lidos do tfvars (path no repo, fora do -chdir)
AWS_REGION := $(shell $(call read_tfvar,aws_region))
ENVIRONMENT := $(shell $(call read_tfvar,environment))
PROJECT_NAME := $(shell $(call read_tfvar,project_name))

ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)

# State key padrão solicitado
STATE_KEY := $(STATE_PREFIX)/$(REPO)/$(ENVIRONMENT)/$(NS)/terraform.tfstate

# Para terraform -chdir=$(TF_DIR), o -var-file deve ser relativo ao diretório terraform/
TFVARS_IN_TF_DIR := $(notdir $(TFVARS))

# ===== Bootstrap outputs (workspace + fallback) =====
# Observação: estes $(shell ...) rodam quando o Makefile é avaliado.
# Se quiser ainda mais "limpo", dá para mover para runtime dentro do target.
BUCKET := $(shell \
  terraform -chdir=$(BOOTSTRAP_DIR) init -input=false -no-color >/dev/null 2>&1 || true; \
  terraform -chdir=$(BOOTSTRAP_DIR) workspace select $(ENVIRONMENT) >/dev/null 2>&1 || true; \
  terraform -chdir=$(BOOTSTRAP_DIR) output -raw state_bucket_name 2>/dev/null || true \
)

LOCK_TABLE_FROM_OUTPUT := $(shell \
  terraform -chdir=$(BOOTSTRAP_DIR) init -input=false -no-color >/dev/null 2>&1 || true; \
  terraform -chdir=$(BOOTSTRAP_DIR) workspace select $(ENVIRONMENT) >/dev/null 2>&1 || true; \
  terraform -chdir=$(BOOTSTRAP_DIR) output -raw dynamodb_table_name 2>/dev/null || true \
)

# fallback se output não existir
LOCK_TABLE := $(if $(strip $(LOCK_TABLE_FROM_OUTPUT)),$(LOCK_TABLE_FROM_OUTPUT),$(PROJECT_NAME)-terraform-locks-$(ACCOUNT_ID)-$(AWS_REGION)-$(ENVIRONMENT))

# ===========================
# Main targets
# ===========================
.PHONY: init-k8s
init-k8s:
	@echo "TFVARS=$(TFVARS)"
	@echo "TFVARS_IN_TF_DIR=$(TFVARS_IN_TF_DIR)"
	@echo "PROJECT_NAME=$(PROJECT_NAME)"
	@echo "AWS_REGION=$(AWS_REGION)"
	@echo "ENVIRONMENT=$(ENVIRONMENT)"
	@echo "ACCOUNT_ID=$(ACCOUNT_ID)"
	@echo "NS=$(NS)"
	@echo "REPO=$(REPO)"
	@echo "BUCKET=$(BUCKET)"
	@echo "LOCK_TABLE=$(LOCK_TABLE)"
	@echo "STATE_KEY=$(STATE_KEY)"
	@test -n "$(BUCKET)" || (echo "ERRO: BUCKET vazio. Rode o bootstrap primeiro: make bootstrap-apply" && exit 1)

	terraform -chdir=$(TF_DIR) init -reconfigure \
	  -backend-config="bucket=$(BUCKET)" \
	  -backend-config="key=$(STATE_KEY)" \
	  -backend-config="region=$(AWS_REGION)" \
	  -backend-config="dynamodb_table=$(LOCK_TABLE)" \
	  -backend-config="encrypt=true" \
	  -backend-config="use_lockfile=true"

.PHONY: plan
plan:
	terraform -chdir=$(TF_DIR) plan -var-file=$(TFVARS_IN_TF_DIR)

.PHONY: apply
apply:
	terraform -chdir=$(TF_DIR) apply -var-file=$(TFVARS_IN_TF_DIR)

.PHONY: destroy
destroy:
	terraform -chdir=$(TF_DIR) destroy -var-file=$(TFVARS_IN_TF_DIR)

.PHONY: kubeconfig
kubeconfig:
	aws eks update-kubeconfig \
	  --name "$$(terraform -chdir=$(TF_DIR) output -raw eks_cluster_name)" \
	  --region $(AWS_REGION)

# ===========================
# (Optional) Bootstrap targets
# ===========================
BOOTSTRAP_TFVARS := ../terraform.tfvars.$(ENVIRONMENT)

.PHONY: bootstrap-init
bootstrap-init:
	terraform -chdir=$(BOOTSTRAP_DIR) init
	terraform -chdir=$(BOOTSTRAP_DIR) workspace new $(ENVIRONMENT) || terraform -chdir=$(BOOTSTRAP_DIR) workspace select $(ENVIRONMENT)

.PHONY: bootstrap-apply
bootstrap-apply: bootstrap-init
	@echo "BOOTSTRAP_TFVARS=$(BOOTSTRAP_TFVARS)"
	terraform -chdir=$(BOOTSTRAP_DIR) apply -var-file=$(BOOTSTRAP_TFVARS)
