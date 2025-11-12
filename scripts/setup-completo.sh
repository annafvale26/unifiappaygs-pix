#!/bin/bash

# Script de Setup Completo - Executa todo o fluxo
# UniFIAP Pay - Sistema PIX SPB
# RM554379 - Anna Vale

set -e

echo "=============================================="
echo "  UniFIAP Pay - Setup Completo              "
echo "  Sistema de Pagamento PIX (SPB)            "
echo "=============================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar pré-requisitos
echo -e "${YELLOW}[1/6]${NC} Verificando pré-requisitos..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} Docker não está instalado!"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} kubectl não está instalado!"
    exit 1
fi

if ! command -v kind &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} KIND não está instalado!"
    echo "Instale com: curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind"
    exit 1
fi

echo -e "${GREEN}✓${NC} Todos os pré-requisitos instalados!"
echo ""

# Criar cluster KIND se não existir
echo -e "${YELLOW}[2/6]${NC} Verificando cluster KIND..."
if ! kind get clusters | grep -q "unifiapay-cluster"; then
    echo "Criando cluster KIND..."
    kind create cluster --name unifiapay-cluster
else
    echo -e "${GREEN}✓${NC} Cluster já existe!"
fi
echo ""

# Build das imagens
echo -e "${YELLOW}[3/6]${NC} Building imagens Docker..."
./scripts/build.sh
echo ""

# Push para Docker Hub
echo -e "${YELLOW}[4/6]${NC} Enviando imagens para Docker Hub..."
echo "Certifique-se de estar logado no Docker Hub (docker login -u annafvale)"
read -p "Pressione ENTER para continuar com o push..."
./scripts/push.sh
echo ""

# Deploy no Kubernetes
echo -e "${YELLOW}[5/6]${NC} Fazendo deploy no Kubernetes..."
./scripts/deploy.sh
echo ""

# Instruções finais
echo -e "${YELLOW}[6/6]${NC} Setup concluído!"
echo ""
echo -e "${GREEN}=============================================="
echo "  Setup Completo Finalizado! ✓"
echo "==============================================${NC}"
echo ""
echo -e "${BLUE}Próximos passos:${NC}"
echo ""
echo "1. Expor a API localmente:"
echo "   kubectl port-forward -n unifiapay deployment/api-pagamentos 3000:3000"
echo ""
echo "2. Testar a API:"
echo "   curl -X POST http://localhost:3000/pix \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"id_transacao\":\"TXN001\",\"valor\":150.50}'"
echo ""
echo "3. Ver logs da API:"
echo "   kubectl logs -n unifiapay -l app=api-pagamentos -f"
echo ""
echo "4. Forçar execução da auditoria:"
echo "   kubectl create job -n unifiapay auditoria-manual --from=cronjob/auditoria-service"
echo ""
echo "5. Ver evidências:"
echo "   kubectl get all -n unifiapay"
echo "   kubectl describe deployment api-pagamentos -n unifiapay"
echo ""
