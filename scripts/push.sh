#!/bin/bash

# Script de Push das Imagens Docker para Docker Hub
# UniFIAP Pay - Sistema PIX SPB
# RM554379 - Anna Vale

set -e

echo "======================================"
echo "  UniFIAP Pay - Push Docker Images   "
echo "======================================"
echo ""

# Variáveis
RM="RM554379"
DOCKER_USER="annafvale"
VERSION="v1.${RM}"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar se está logado no Docker Hub
echo -e "${YELLOW}[INFO]${NC} Verificando login no Docker Hub..."
if ! docker info | grep -q "Username: ${DOCKER_USER}"; then
    echo -e "${RED}[ERRO]${NC} Você não está logado no Docker Hub como ${DOCKER_USER}"
    echo "Execute: docker login -u ${DOCKER_USER}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Login verificado!"
echo ""

# Push API de Pagamentos
echo -e "${GREEN}[1/2]${NC} Pushing api-pagamentos-spb..."
docker push ${DOCKER_USER}/api-pagamentos-spb:${VERSION}
docker push ${DOCKER_USER}/api-pagamentos-spb:latest
echo -e "${GREEN}✓${NC} API Pagamentos enviado!"
echo ""

# Push Serviço de Auditoria
echo -e "${GREEN}[2/2]${NC} Pushing auditoria-service-spb..."
docker push ${DOCKER_USER}/auditoria-service-spb:${VERSION}
docker push ${DOCKER_USER}/auditoria-service-spb:latest
echo -e "${GREEN}✓${NC} Auditoria Service enviado!"
echo ""

echo -e "${GREEN}======================================"
echo "  Push concluído com sucesso! ✓"
echo "======================================${NC}"
echo ""
echo "Links Docker Hub:"
echo "- https://hub.docker.com/r/${DOCKER_USER}/api-pagamentos-spb"
echo "- https://hub.docker.com/r/${DOCKER_USER}/auditoria-service-spb"
echo ""
echo "Próximo passo: Execute ./scripts/deploy.sh para deploy no Kubernetes"
