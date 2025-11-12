#!/bin/bash

# Script de Deploy no Kubernetes (KIND)
# UniFIAP Pay - Sistema PIX SPB
# RM554379 - Anna Vale

set -e

echo "======================================"
echo "  UniFIAP Pay - Deploy Kubernetes    "
echo "======================================"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verificar se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} kubectl não está instalado!"
    exit 1
fi

# Verificar se o cluster está rodando
echo -e "${YELLOW}[INFO]${NC} Verificando cluster Kubernetes..."
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} Cluster Kubernetes não está disponível!"
    echo "Execute: kind create cluster --name unifiapay-cluster"
    exit 1
fi

echo -e "${GREEN}✓${NC} Cluster disponível!"
echo ""

# Aplicar manifestos Kubernetes em ordem
echo -e "${BLUE}[1/4]${NC} Aplicando Namespace, ConfigMap e Secret..."
kubectl apply -f k8s/01-namespace-config-secret.yaml
echo ""

echo -e "${BLUE}[2/4]${NC} Criando PersistentVolumeClaim..."
kubectl apply -f k8s/02-pvc.yaml
echo ""

echo -e "${BLUE}[3/4]${NC} Deployando API de Pagamentos..."
kubectl apply -f k8s/03-api-deployment.yaml
echo ""

echo -e "${BLUE}[4/4]${NC} Criando CronJob de Auditoria..."
kubectl apply -f k8s/04-auditoria-cronjob.yaml
echo ""

# Aguardar pods ficarem prontos
echo -e "${YELLOW}[INFO]${NC} Aguardando pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app=api-pagamentos -n unifiapay --timeout=60s

echo ""
echo -e "${GREEN}======================================"
echo "  Deploy concluído com sucesso! ✓"
echo "======================================${NC}"
echo ""

# Mostrar status dos recursos
echo -e "${YELLOW}Status dos recursos:${NC}"
echo "--------------------------------------"
kubectl get all -n unifiapay
echo ""
kubectl get pvc -n unifiapay
echo ""

echo -e "${GREEN}[INFO]${NC} Para acessar a API localmente, execute:"
echo "  kubectl port-forward -n unifiapay deployment/api-pagamentos 3000:3000"
echo ""
echo -e "${GREEN}[INFO]${NC} Testar API:"
echo "  curl -X POST http://localhost:3000/pix -H 'Content-Type: application/json' -d '{\"id_transacao\":\"TXN001\",\"valor\":150.50}'"
