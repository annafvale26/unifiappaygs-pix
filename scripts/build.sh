#!/bin/bash

# Script de Build das Imagens Docker
# UniFIAP Pay - Sistema PIX SPB
# RM554379 - Anna Vale

set -e  # Sai se algum comando falhar

echo "======================================"
echo "  UniFIAP Pay - Build Docker Images  "
echo "======================================"
echo ""

# Variáveis
RM="RM554379"
DOCKER_USER="annafvale"
VERSION="v1.${RM}"

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO]${NC} Usuário Docker Hub: ${DOCKER_USER}"
echo -e "${YELLOW}[INFO]${NC} Versão das imagens: ${VERSION}"
echo ""

# Build API de Pagamentos
echo -e "${GREEN}[1/2]${NC} Building api-pagamentos..."
cd api-pagamentos
docker build -t ${DOCKER_USER}/api-pagamentos-spb:${VERSION} .
docker tag ${DOCKER_USER}/api-pagamentos-spb:${VERSION} ${DOCKER_USER}/api-pagamentos-spb:latest
echo -e "${GREEN}✓${NC} API Pagamentos build concluído!"
echo ""

# Build Serviço de Auditoria
echo -e "${GREEN}[2/2]${NC} Building auditoria-service..."
cd ../auditoria-service
docker build -t ${DOCKER_USER}/auditoria-service-spb:${VERSION} .
docker tag ${DOCKER_USER}/auditoria-service-spb:${VERSION} ${DOCKER_USER}/auditoria-service-spb:latest
echo -e "${GREEN}✓${NC} Auditoria Service build concluído!"
cd ..
echo ""

# Listar imagens criadas
echo -e "${GREEN}[INFO]${NC} Imagens Docker criadas:"
echo "--------------------------------------"
docker images | grep ${DOCKER_USER} | grep -E "(api-pagamentos|auditoria-service)"
echo ""

echo -e "${GREEN}======================================"
echo "  Build concluído com sucesso! ✓"
echo "======================================${NC}"
echo ""
echo "Próximo passo: Execute ./scripts/push.sh para enviar as imagens ao Docker Hub"
