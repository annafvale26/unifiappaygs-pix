#!/bin/bash

# Script de Limpeza - Remove todos os recursos do Kubernetes
# UniFIAP Pay - Sistema PIX SPB
# RM554379 - Anna Vale

set -e

echo "======================================"
echo "  UniFIAP Pay - Cleanup Resources    "
echo "======================================"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Confirmação
echo -e "${YELLOW}[AVISO]${NC} Este script irá deletar todos os recursos do namespace 'unifiapay'"
read -p "Deseja continuar? (s/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada."
    exit 0
fi

echo ""
echo -e "${RED}[INFO]${NC} Deletando namespace 'unifiapay' e todos os recursos..."
kubectl delete namespace unifiapay --ignore-not-found=true

echo ""
echo -e "${GREEN}======================================"
echo "  Cleanup concluído! ✓"
echo "======================================${NC}"
echo ""
echo "Para fazer novo deploy, execute: ./scripts/deploy.sh"
