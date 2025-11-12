#!/bin/bash

# Script para verificar status completo do projeto
# UniFIAP Pay - Sistema PIX SPB
# RM554379 - Anna Vale

echo "=============================================="
echo "  Status do Projeto - UniFIAP Pay           "
echo "=============================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para check
check_item() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

echo -e "${BLUE}=== Pré-requisitos ===${NC}"
command -v docker &> /dev/null
check_item $? "Docker instalado"

command -v kubectl &> /dev/null
check_item $? "kubectl instalado"

command -v kind &> /dev/null
check_item $? "KIND instalado"

echo ""
echo -e "${BLUE}=== Arquivos do Projeto ===${NC}"
[ -f "README.md" ]
check_item $? "README.md"

[ -f "QUICKSTART.md" ]
check_item $? "QUICKSTART.md"

[ -f "TESTES.md" ]
check_item $? "TESTES.md"

[ -f "EVIDENCIAS.md" ]
check_item $? "EVIDENCIAS.md"

[ -f "api-pagamentos/Dockerfile" ]
check_item $? "Dockerfile da API"

[ -f "auditoria-service/Dockerfile" ]
check_item $? "Dockerfile da Auditoria"

[ -f "k8s/01-namespace-config-secret.yaml" ]
check_item $? "Manifest Kubernetes (namespace)"

[ -f "k8s/02-pvc.yaml" ]
check_item $? "Manifest Kubernetes (PVC)"

[ -f "k8s/03-api-deployment.yaml" ]
check_item $? "Manifest Kubernetes (API)"

[ -f "k8s/04-auditoria-cronjob.yaml" ]
check_item $? "Manifest Kubernetes (CronJob)"

echo ""
echo -e "${BLUE}=== Scripts ===${NC}"
[ -x "scripts/build.sh" ]
check_item $? "build.sh (executável)"

[ -x "scripts/push.sh" ]
check_item $? "push.sh (executável)"

[ -x "scripts/deploy.sh" ]
check_item $? "deploy.sh (executável)"

[ -x "scripts/cleanup.sh" ]
check_item $? "cleanup.sh (executável)"

[ -x "scripts/setup-completo.sh" ]
check_item $? "setup-completo.sh (executável)"

[ -x "scripts/gerar-evidencias.sh" ]
check_item $? "gerar-evidencias.sh (executável)"

echo ""
echo -e "${BLUE}=== Cluster Kubernetes ===${NC}"
if kind get clusters 2>/dev/null | grep -q "unifiapay-cluster"; then
    echo -e "${GREEN}✓${NC} Cluster KIND 'unifiapay-cluster' existe"
    
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✓${NC} Cluster está acessível"
    else
        echo -e "${RED}✗${NC} Cluster não está acessível"
    fi
else
    echo -e "${YELLOW}⚠${NC} Cluster KIND 'unifiapay-cluster' não existe"
    echo "  Execute: kind create cluster --name unifiapay-cluster"
fi

echo ""
echo -e "${BLUE}=== Recursos Kubernetes ===${NC}"
if kubectl get namespace unifiapay &> /dev/null; then
    echo -e "${GREEN}✓${NC} Namespace 'unifiapay' existe"
    
    # Verificar recursos
    PODS=$(kubectl get pods -n unifiapay --no-headers 2>/dev/null | wc -l)
    DEPLOYMENTS=$(kubectl get deployments -n unifiapay --no-headers 2>/dev/null | wc -l)
    CRONJOBS=$(kubectl get cronjobs -n unifiapay --no-headers 2>/dev/null | wc -l)
    PVCS=$(kubectl get pvc -n unifiapay --no-headers 2>/dev/null | wc -l)
    
    echo "  - Pods: $PODS"
    echo "  - Deployments: $DEPLOYMENTS"
    echo "  - CronJobs: $CRONJOBS"
    echo "  - PVCs: $PVCS"
    
    # Verificar réplicas da API
    REPLICAS_READY=$(kubectl get deployment api-pagamentos -n unifiapay -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    if [ "$REPLICAS_READY" == "2" ]; then
        echo -e "${GREEN}✓${NC} API com 2 réplicas rodando"
    else
        echo -e "${YELLOW}⚠${NC} API com $REPLICAS_READY réplicas (esperado: 2)"
    fi
else
    echo -e "${YELLOW}⚠${NC} Namespace 'unifiapay' não existe"
    echo "  Execute: ./scripts/deploy.sh"
fi

echo ""
echo -e "${BLUE}=== Imagens Docker ===${NC}"
if docker images | grep -q "annafvale/api-pagamentos-spb"; then
    echo -e "${GREEN}✓${NC} Imagem api-pagamentos-spb encontrada localmente"
else
    echo -e "${YELLOW}⚠${NC} Imagem api-pagamentos-spb não encontrada localmente"
fi

if docker images | grep -q "annafvale/auditoria-service-spb"; then
    echo -e "${GREEN}✓${NC} Imagem auditoria-service-spb encontrada localmente"
else
    echo -e "${YELLOW}⚠${NC} Imagem auditoria-service-spb não encontrada localmente"
fi

echo ""
echo -e "${BLUE}=== Verificação de RM ===${NC}"
if grep -r "RM554379" k8s/ &> /dev/null; then
    echo -e "${GREEN}✓${NC} RM554379 encontrado nos manifests Kubernetes"
else
    echo -e "${RED}✗${NC} RM554379 não encontrado nos manifests"
fi

if grep -r "annafvale" k8s/ &> /dev/null; then
    echo -e "${GREEN}✓${NC} Usuário annafvale encontrado nos manifests"
else
    echo -e "${RED}✗${NC} Usuário annafvale não encontrado nos manifests"
fi

echo ""
echo -e "${GREEN}=============================================="
echo "  Verificação concluída!"
echo "==============================================${NC}"
echo ""

# Próximos passos
if ! kind get clusters 2>/dev/null | grep -q "unifiapay-cluster"; then
    echo -e "${YELLOW}Próximo passo:${NC} Criar cluster KIND"
    echo "  kind create cluster --name unifiapay-cluster"
elif ! kubectl get namespace unifiapay &> /dev/null; then
    echo -e "${YELLOW}Próximo passo:${NC} Fazer deploy"
    echo "  ./scripts/deploy.sh"
else
    echo -e "${GREEN}Status:${NC} Projeto pronto para uso!"
    echo ""
    echo "Para testar a API:"
    echo "  1. kubectl port-forward -n unifiapay deployment/api-pagamentos 3000:3000"
    echo "  2. curl -X POST http://localhost:3000/pix -H 'Content-Type: application/json' -d '{\"id_transacao\":\"TXN001\",\"valor\":150.50}'"
fi
