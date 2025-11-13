#!/bin/bash

# Script para fazer login no GitHub e push do código
# UniFIAP Pay - RM554379

echo "======================================"
echo "  GitHub Authentication & Push       "
echo "======================================"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Cole seu GitHub Personal Access Token:${NC}"
read -s GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}[ERRO]${NC} Token não pode estar vazio!"
    exit 1
fi

echo -e "${YELLOW}[INFO]${NC} Fazendo login no GitHub..."
echo "$GITHUB_TOKEN" | gh auth login --with-token

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Login realizado com sucesso!"
    echo ""
    
    # Verificar status
    echo -e "${YELLOW}[INFO]${NC} Verificando autenticação..."
    gh auth status
    echo ""
    
    # Fazer push
    echo -e "${YELLOW}[INFO]${NC} Fazendo push para o GitHub..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}======================================"
        echo "  Push concluído com sucesso! ✓"
        echo "======================================${NC}"
        echo ""
        echo "Repositório: https://github.com/annafvale26/unifiappaygs-pix"
    else
        echo -e "${RED}[ERRO]${NC} Falha ao fazer push!"
        exit 1
    fi
else
    echo -e "${RED}[ERRO]${NC} Falha na autenticação!"
    exit 1
fi
