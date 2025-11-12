# 📊 Evidências do Desafio - UniFIAP Pay Sistema PIX

**RM554379 - Anna Vale**  
**Disciplina:** Global Solutions - FIAP  
**Projeto:** Sistema de Pagamento PIX (SPB)

---

## 📋 Índice de Evidências

Este documento descreve as evidências que devem ser capturadas para comprovar o cumprimento dos requisitos do desafio.

### Evidência 3.1 - Imagens Publicadas no Docker Hub

**Requisito:** Publicar imagens Docker no Docker Hub com tag contendo o RM.

**Capturas necessárias:**

1. **Screenshot do Docker Hub - API Pagamentos**
   - URL: `https://hub.docker.com/r/annafvale/api-pagamentos-spb`
   - Arquivo: `assets/3.1-dockerhub-api-pagamentos.png`
   - Mostrar: Tags da imagem incluindo `v1.RM554379`

2. **Screenshot do Docker Hub - Auditoria Service**
   - URL: `https://hub.docker.com/r/annafvale/auditoria-service-spb`
   - Arquivo: `assets/3.1-dockerhub-auditoria-service.png`
   - Mostrar: Tags da imagem incluindo `v1.RM554379`

3. **Comando para verificar imagens localmente:**
```bash
docker images | grep annafvale
```
Arquivo: `assets/3.1-docker-images-local.png`

---

### Evidência 3.2 - ConfigMap e Secret

**Requisito:** Utilizar ConfigMap para reserva bancária e Secret para chave PIX.

**Capturas necessárias:**

1. **ConfigMap criado:**
```bash
kubectl get configmap api-config -n unifiapay -o yaml
```
Arquivo: `assets/3.2-configmap.png`

Deve mostrar:
```yaml
data:
  RESERVA_BANCARIA_SALDO: "1000000.00"
```

2. **Secret criado:**
```bash
kubectl get secret api-secrets -n unifiapay -o yaml
```
Arquivo: `assets/3.2-secret.png`

3. **Decodificar Secret:**
```bash
kubectl get secret api-secrets -n unifiapay -o jsonpath='{.data.pix\.key}' | base64 -d
```
Arquivo: `assets/3.2-secret-decoded.png`

Deve mostrar: `sim-key-abcdef-123456-unifiap-spb`

---

### Evidência 3.3 - PersistentVolume e Replicação

**Requisito:** 
- PersistentVolume compartilhado entre API e Auditoria
- 2 réplicas da API de Pagamentos
- CronJob para Auditoria a cada 6 horas

**Capturas necessárias:**

1. **PersistentVolumeClaim criado:**
```bash
kubectl get pvc -n unifiapay
kubectl describe pvc livro-razao-pvc -n unifiapay
```
Arquivo: `assets/3.3-pvc.png`

2. **Deployment com 2 réplicas:**
```bash
kubectl get deployment api-pagamentos -n unifiapay
kubectl get pods -n unifiapay -l app=api-pagamentos -o wide
```
Arquivo: `assets/3.3-replicas.png`

Deve mostrar: `READY 2/2`

3. **CronJob configurado:**
```bash
kubectl get cronjob -n unifiapay
kubectl describe cronjob auditoria-service -n unifiapay
```
Arquivo: `assets/3.3-cronjob.png`

Deve mostrar: `Schedule: 0 */6 * * *`

4. **Conteúdo do Livro-Razão (antes da liquidação):**
```bash
kubectl exec -n unifiapay <pod-name> -- cat /var/logs/api/instrucoes.log
```
Arquivo: `assets/3.3-livro-razao-antes.png`

Deve mostrar entradas com: `AGUARDANDO_LIQUIDACAO`

5. **Conteúdo do Livro-Razão (depois da liquidação):**
```bash
# Executar auditoria manualmente
kubectl create job -n unifiapay auditoria-manual --from=cronjob/auditoria-service

# Verificar log atualizado
kubectl exec -n unifiapay <pod-name> -- cat /var/logs/api/instrucoes.log
```
Arquivo: `assets/3.3-livro-razao-depois.png`

Deve mostrar entradas com: `LIQUIDADO`

---

### Evidência 3.4 - Requisitos de Segurança

**Requisito:** 
- Containers rodando como usuário não-root
- Limites de recursos definidos
- Imagens otimizadas (multi-stage build)

**Capturas necessárias:**

1. **SecurityContext configurado:**
```bash
kubectl get pod -n unifiapay -l app=api-pagamentos -o yaml | grep -A 10 securityContext
```
Arquivo: `assets/3.4-security-context.png`

Deve mostrar:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```

2. **Limites de recursos:**
```bash
kubectl describe deployment api-pagamentos -n unifiapay | grep -A 10 "Limits:"
```
Arquivo: `assets/3.4-resource-limits.png`

Deve mostrar:
```
Limits:
  cpu:     200m
  memory:  256Mi
Requests:
  cpu:     100m
  memory:  128Mi
```

3. **Dockerfile Multi-Stage:**
Arquivo: `assets/3.4-dockerfile-multistage.png`

Capturar conteúdo do Dockerfile mostrando os estágios `builder` e `final`.

4. **Tamanho das imagens otimizadas:**
```bash
docker images | grep annafvale
```
Arquivo: `assets/3.4-image-size.png`

---

## 🧪 Evidências de Funcionamento

### Teste 1: PIX Aprovado

**Comando:**
```bash
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{"id_transacao": "TXN001", "valor": 150.50}'
```

**Captura:** `assets/teste-pix-aprovado.png`

**Resposta esperada:**
```json
{"status":"PIX Aceito","transacao":"TXN001","estado":"AGUARDANDO_LIQUIDACAO"}
```

---

### Teste 2: PIX Rejeitado

**Comando:**
```bash
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{"id_transacao": "TXN002", "valor": 2000000.00}'
```

**Captura:** `assets/teste-pix-rejeitado.png`

**Resposta esperada:**
```json
{"status":"PIX Rejeitado","motivo":"Fundos insuficientes na Reserva Bancária."}
```

---

### Teste 3: Logs da API

**Comando:**
```bash
kubectl logs -n unifiapay -l app=api-pagamentos --tail=20
```

**Captura:** `assets/teste-logs-api.png`

---

### Teste 4: Execução da Auditoria

**Comando:**
```bash
kubectl create job -n unifiapay auditoria-manual --from=cronjob/auditoria-service
kubectl logs -n unifiapay job/auditoria-manual
```

**Captura:** `assets/teste-auditoria-logs.png`

---

## 📦 Estrutura Completa de Evidências

```
assets/
├── 3.1-dockerhub-api-pagamentos.png
├── 3.1-dockerhub-auditoria-service.png
├── 3.1-docker-images-local.png
├── 3.2-configmap.png
├── 3.2-secret.png
├── 3.2-secret-decoded.png
├── 3.3-pvc.png
├── 3.3-replicas.png
├── 3.3-cronjob.png
├── 3.3-livro-razao-antes.png
├── 3.3-livro-razao-depois.png
├── 3.4-security-context.png
├── 3.4-resource-limits.png
├── 3.4-dockerfile-multistage.png
├── 3.4-image-size.png
├── teste-pix-aprovado.png
├── teste-pix-rejeitado.png
├── teste-logs-api.png
├── teste-auditoria-logs.png
├── visao-geral-recursos.png
└── arquitetura-diagrama.png (opcional)
```

---

## ✅ Checklist de Evidências

### Evidência 3.1 - Docker Hub
- [ ] Screenshot do repositório api-pagamentos-spb no Docker Hub
- [ ] Screenshot do repositório auditoria-service-spb no Docker Hub
- [ ] Screenshot das imagens locais com as tags corretas

### Evidência 3.2 - ConfigMap e Secret
- [ ] Screenshot do ConfigMap com a reserva bancária
- [ ] Screenshot do Secret (base64)
- [ ] Screenshot do Secret decodificado

### Evidência 3.3 - PersistentVolume e Replicação
- [ ] Screenshot do PVC criado e montado
- [ ] Screenshot das 2 réplicas da API rodando
- [ ] Screenshot do CronJob configurado
- [ ] Screenshot do livro-razão ANTES da liquidação
- [ ] Screenshot do livro-razão DEPOIS da liquidação

### Evidência 3.4 - Segurança
- [ ] Screenshot do securityContext (runAsNonRoot)
- [ ] Screenshot dos limites de recursos
- [ ] Screenshot do Dockerfile multi-stage
- [ ] Screenshot do tamanho otimizado das imagens

### Evidências de Funcionamento
- [ ] Screenshot de PIX aprovado
- [ ] Screenshot de PIX rejeitado
- [ ] Screenshot dos logs da API
- [ ] Screenshot da execução da auditoria
- [ ] Screenshot da visão geral dos recursos do Kubernetes

---

## 📸 Dicas para Captura de Screenshots

1. **Use terminal com fundo escuro** para melhor legibilidade
2. **Inclua o comando executado** no screenshot
3. **Destaque informações importantes** (pode usar ferramentas de anotação)
4. **Use resolução adequada** (mínimo 1280x720)
5. **Organize por seção** seguindo a numeração das evidências
6. **Inclua timestamp** quando relevante
7. **Certifique-se que o RM554379 está visível** onde aplicável

---

## 🎯 Comandos Rápidos para Captura

Execute este script para gerar todas as saídas necessárias:

```bash
#!/bin/bash
echo "=== Gerando outputs para evidências ==="

echo -e "\n[3.1] Imagens Docker:"
docker images | grep annafvale

echo -e "\n[3.2] ConfigMap:"
kubectl get configmap api-config -n unifiapay -o yaml

echo -e "\n[3.2] Secret:"
kubectl get secret api-secrets -n unifiapay -o yaml

echo -e "\n[3.3] PVC:"
kubectl get pvc -n unifiapay

echo -e "\n[3.3] Réplicas:"
kubectl get deployment api-pagamentos -n unifiapay
kubectl get pods -n unifiapay -l app=api-pagamentos

echo -e "\n[3.3] CronJob:"
kubectl get cronjob -n unifiapay

echo -e "\n[3.4] Security Context:"
kubectl get pod -n unifiapay -l app=api-pagamentos -o yaml | grep -A 10 securityContext

echo -e "\n[3.4] Resource Limits:"
kubectl describe deployment api-pagamentos -n unifiapay | grep -A 10 "Limits:"

echo -e "\n[Visão Geral] Todos os recursos:"
kubectl get all -n unifiapay
```

Salve como `scripts/gerar-evidencias.sh` e execute antes de capturar os screenshots.

---

**Desenvolvido por Anna Vale (RM554379) - FIAP 2025**
