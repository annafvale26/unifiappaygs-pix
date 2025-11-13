#!/bin/bash

# Script para gerar outputs das evidências
# UniFIAP Pay - Sistema PIX SPB
# RM554379 - Anna Vale

set -e

echo "=============================================="
echo "  Gerando Outputs para Evidências           "
echo "=============================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===== Evidência 3.1 - Docker Hub =====${NC}"
echo ""
echo "Imagens Docker locais:"
docker images | head -1
docker images | grep annafvale | grep -E "(api-pagamentos|auditoria-service)" || echo "Nenhuma imagem encontrada localmente"
echo ""

echo -e "${BLUE}===== Evidência 3.2 - ConfigMap e Secret =====${NC}"
echo ""
echo "ConfigMap:"
kubectl get configmap api-config -n unifiapay -o yaml
echo ""
echo "Secret (base64):"
kubectl get secret api-secrets -n unifiapay -o yaml
echo ""
echo "Secret decodificado:"
echo -n "pix.key: "
kubectl get secret api-secrets -n unifiapay -o jsonpath='{.data.pix\.key}' | base64 -d
echo ""
echo ""

echo -e "${BLUE}===== Evidência 3.3 - PersistentVolume e Replicação =====${NC}"
echo ""
echo "PersistentVolumeClaim:"
kubectl get pvc -n unifiapay
echo ""
echo "Deployment e Réplicas:"
kubectl get deployment api-pagamentos -n unifiapay
echo ""
echo "Pods da API:"
kubectl get pods -n unifiapay -l app=api-pagamentos -o wide
echo ""
echo "CronJob de Auditoria:"
kubectl get cronjob -n unifiapay
echo ""
echo "Detalhes do CronJob:"
kubectl describe cronjob auditoria-service -n unifiapay | grep -A 5 "Schedule:"
echo ""

echo -e "${BLUE}===== Evidência 3.4 - Segurança =====${NC}"
echo ""
echo "Security Context dos Pods:"
kubectl get pod -n unifiapay -l app=api-pagamentos -o yaml | grep -A 10 securityContext | head -15
echo ""
echo "Resource Limits:"
kubectl describe deployment api-pagamentos -n unifiapay | grep -A 10 "Limits:"
echo ""

echo -e "${BLUE}===== Visão Geral - Todos os Recursos =====${NC}"
echo ""
kubectl get all -n unifiapay
echo ""
kubectl get pvc,configmap,secret -n unifiapay
echo ""

echo -e "${GREEN}=============================================="
echo "  Outputs gerados com sucesso! ✓"
echo "==============================================${NC}"
echo ""
echo "Agora capture os screenshots dos outputs acima e salve na pasta 'assets/'"
echo "Consulte o arquivo EVIDENCIAS.md para a lista completa de capturas necessárias."
