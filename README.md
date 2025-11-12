# UniFIAP Pay - Sistema de Pagamento PIX (SPB)

**RM: RM554379**  
**Aluno: Anna Vale**  
**Docker Hub: annafvale**

## 📋 Sobre o Projeto

Este projeto implementa uma simulação simplificada do Sistema de Pagamentos Brasileiro (SPB) com foco em transações PIX, desenvolvido como parte do desafio da disciplina de Global Solutions da FIAP.

### 🎯 Objetivo

Simular o fluxo de pagamento PIX utilizando uma arquitetura de microsserviços com:
- **API de Pagamentos** (Banco Originador - UniFIAP Pay)
- **Serviço de Auditoria/Liquidação** (Sistema BACEN/STR)
- **Livro-Razão compartilhado** (Persistent Volume)

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster (KIND)                 │
│                                                              │
│  ┌────────────────────────────────────────────────────┐   │
│  │         Namespace: unifiapay                        │   │
│  │                                                      │   │
│  │  ┌──────────────────┐      ┌──────────────────┐  │   │
│  │  │  API Pagamentos  │      │  Auditoria       │  │   │
│  │  │  (Deployment)    │      │  (CronJob 6h)    │  │   │
│  │  │  - 2 Réplicas    │      │  - Liquidação    │  │   │
│  │  │  - Port 3000     │      │                  │  │   │
│  │  └────────┬─────────┘      └────────┬─────────┘  │   │
│  │           │                          │             │   │
│  │           └──────────┬───────────────┘             │   │
│  │                      │                              │   │
│  │           ┌──────────▼──────────┐                 │   │
│  │           │  PersistentVolume   │                 │   │
│  │           │   (Livro-Razão)     │                 │   │
│  │           │  /var/logs/api/     │                 │   │
│  │           └─────────────────────┘                 │   │
│  │                                                      │   │
│  │  ConfigMap: RESERVA_BANCARIA_SALDO = 1000000.00   │   │
│  │  Secret: pix.key = sim-key-abcdef-123456...        │   │
│  └────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Estrutura do Projeto

```
unifiappaygs-pix/
├── api-pagamentos/           # Microsserviço API de Pagamentos
│   ├── src/
│   │   └── index.js         # Lógica da API
│   ├── Dockerfile           # Multi-stage build
│   ├── package.json
│   └── package-lock.json
├── auditoria-service/        # Microsserviço de Auditoria
│   ├── src/
│   │   └── index.js         # Lógica de liquidação
│   ├── Dockerfile           # Multi-stage build
│   ├── package.json
│   └── package-lock.json
├── k8s/                      # Manifests Kubernetes
│   ├── 01-namespace-config-secret.yaml
│   ├── 02-pvc.yaml
│   ├── 03-api-deployment.yaml
│   └── 04-auditoria-cronjob.yaml
├── docker/                   # Configurações Docker
│   ├── .env
│   └── pix.key
├── assets/                   # Evidências e screenshots
├── scripts/                  # Scripts de automação
│   ├── build.sh
│   ├── push.sh
│   └── deploy.sh
└── README.md
```

## 🚀 Pré-requisitos

- **Docker** (versão 20.10+)
- **kubectl** (versão 1.25+)
- **KIND** (Kubernetes IN Docker)
- **Node.js** 20+ (para desenvolvimento local)
- **Conta no Docker Hub** (annafvale)

### Instalação do KIND no Ubuntu/WSL

```bash
# Instalar KIND
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verificar instalação
kind version
```

## 📦 Como Executar

### 1. Criar Cluster Kubernetes LOCAL (KIND)

```bash
# Criar cluster KIND
kind create cluster --name unifiapay-cluster

# Verificar cluster
kubectl cluster-info --context kind-unifiapay-cluster
kubectl get nodes
```

### 2. Build das Imagens Docker

```bash
# Build da API de Pagamentos
cd api-pagamentos
docker build -t annafvale/api-pagamentos-spb:v1.RM554379 .

# Build do Serviço de Auditoria
cd ../auditoria-service
docker build -t annafvale/auditoria-service-spb:v1.RM554379 .

# Voltar para raiz
cd ..
```

**Ou use o script de automação:**

```bash
chmod +x scripts/build.sh
./scripts/build.sh
```

### 3. Push para Docker Hub

```bash
# Login no Docker Hub
docker login -u annafvale

# Push das imagens
docker push annafvale/api-pagamentos-spb:v1.RM554379
docker push annafvale/auditoria-service-spb:v1.RM554379
```

**Ou use o script:**

```bash
chmod +x scripts/push.sh
./scripts/push.sh
```

### 4. Deploy no Kubernetes

```bash
# Aplicar todos os manifestos em ordem
kubectl apply -f k8s/01-namespace-config-secret.yaml
kubectl apply -f k8s/02-pvc.yaml
kubectl apply -f k8s/03-api-deployment.yaml
kubectl apply -f k8s/04-auditoria-cronjob.yaml

# Verificar recursos criados
kubectl get all -n unifiapay
kubectl get pvc -n unifiapay
kubectl get configmap -n unifiapay
kubectl get secret -n unifiapay
```

**Ou use o script:**

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 5. Expor a API (Port Forward)

```bash
# Port forward para acessar a API localmente
kubectl port-forward -n unifiapay deployment/api-pagamentos 3000:3000
```

A API estará disponível em: `http://localhost:3000`

## 🧪 Testes

### Testar Endpoint POST /pix

```bash
# PIX APROVADO - Valor dentro da reserva
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{
    "id_transacao": "TXN001",
    "valor": 150.50
  }'

# Resposta esperada:
# {"status":"PIX Aceito","transacao":"TXN001","estado":"AGUARDANDO_LIQUIDACAO"}

# PIX REJEITADO - Valor acima da reserva
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{
    "id_transacao": "TXN002",
    "valor": 2000000.00
  }'

# Resposta esperada:
# {"status":"PIX Rejeitado","motivo":"Fundos insuficientes na Reserva Bancária."}
```

### Verificar Logs do Livro-Razão

```bash
# Listar pods da API
kubectl get pods -n unifiapay -l app=api-pagamentos

# Acessar o pod (substitua <pod-name> pelo nome real)
kubectl exec -it -n unifiapay <pod-name> -- sh

# Dentro do pod, ver o arquivo de log
cat /var/logs/api/instrucoes.log

# Exemplo de saída:
# 2025-11-12T10:15:30.123Z | TXN001 | 150.50 | AGUARDANDO_LIQUIDACAO
```

### Forçar Execução da Auditoria (Teste Manual)

```bash
# Criar um Job a partir do CronJob
kubectl create job -n unifiapay auditoria-manual --from=cronjob/auditoria-service

# Verificar execução do Job
kubectl get jobs -n unifiapay
kubectl logs -n unifiapay job/auditoria-manual

# Verificar se o status foi atualizado para LIQUIDADO
kubectl exec -it -n unifiapay <pod-api> -- cat /var/logs/api/instrucoes.log
```

## 🔒 Segurança Implementada

### Evidência 3.4 - Requisitos de Segurança

1. **Imagens Multi-Stage Build**
   - Redução do tamanho das imagens
   - Apenas dependências de produção

2. **Usuário Não-Root**
   - Containers executam com `runAsNonRoot: true`
   - Usuário `appuser` (UID 1000)

3. **Limites de Recursos**
   - CPU: 100m (request) / 200m (limit)
   - Memory: 128Mi (request) / 256Mi (limit)

4. **Secrets para Dados Sensíveis**
   - Chave PIX armazenada como Secret
   - ConfigMap para configurações não-sensíveis

## 📊 Evidências do Desafio

### Evidência 3.1 - Imagens no Docker Hub

```bash
# Verificar imagens publicadas
docker search annafvale

# Pull das imagens
docker pull annafvale/api-pagamentos-spb:v1.RM554379
docker pull annafvale/auditoria-service-spb:v1.RM554379
```

**Links Docker Hub:**
- [annafvale/api-pagamentos-spb](https://hub.docker.com/r/annafvale/api-pagamentos-spb)
- [annafvale/auditoria-service-spb](https://hub.docker.com/r/annafvale/auditoria-service-spb)

### Evidência 3.2 - ConfigMap e Secret

```bash
# Visualizar ConfigMap
kubectl describe configmap api-config -n unifiapay

# Visualizar Secret (base64 encoded)
kubectl get secret api-secrets -n unifiapay -o yaml
```

### Evidência 3.3 - PersistentVolume e Replicação

```bash
# Verificar PVC
kubectl get pvc -n unifiapay

# Verificar réplicas da API
kubectl get deployment api-pagamentos -n unifiapay
# Deve mostrar: READY 2/2

# Verificar CronJob
kubectl get cronjob -n unifiapay
# Schedule: 0 */6 * * * (a cada 6 horas)
```

### Evidência 3.4 - Segurança

```bash
# Verificar configuração de segurança do pod
kubectl get pod -n unifiapay -l app=api-pagamentos -o yaml | grep -A 5 securityContext

# Verificar recursos alocados
kubectl describe deployment api-pagamentos -n unifiapay | grep -A 10 Limits
```

## 🛠️ Comandos Úteis

```bash
# Ver logs da API
kubectl logs -n unifiapay -l app=api-pagamentos --tail=50 -f

# Ver logs do CronJob de Auditoria
kubectl logs -n unifiapay -l job-name=auditoria-service-<timestamp>

# Deletar todos os recursos
kubectl delete namespace unifiapay

# Recriar deployment (após mudanças)
kubectl rollout restart deployment api-pagamentos -n unifiapay

# Deletar cluster KIND
kind delete cluster --name unifiapay-cluster
```

## 🐛 Troubleshooting

### Pods não iniciam

```bash
# Verificar eventos do pod
kubectl describe pod -n unifiapay <pod-name>

# Verificar logs de erro
kubectl logs -n unifiapay <pod-name>
```

### Imagens não encontradas no Docker Hub

```bash
# Verificar se fez push
docker images | grep annafvale

# Verificar credenciais
docker login -u annafvale
```

### PVC em Pending

```bash
# Verificar se o StorageClass existe
kubectl get storageclass

# No KIND, o StorageClass padrão deve existir automaticamente
kubectl get pvc -n unifiapay -o yaml
```

### Port Forward não funciona

```bash
# Verificar se o pod está rodando
kubectl get pods -n unifiapay

# Verificar se a porta 3000 está livre localmente
lsof -i :3000
```

## 📚 Referências

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [KIND Documentation](https://kind.sigs.k8s.io/)
- [Docker Documentation](https://docs.docker.com/)
- [Node.js Express](https://expressjs.com/)
- [Sistema de Pagamentos Brasileiro (SPB)](https://www.bcb.gov.br/estabilidadefinanceira/spb)

## 📝 Licença

Este projeto foi desenvolvido para fins educacionais como parte do desafio Global Solutions da FIAP.

---

**Desenvolvido por Anna Vale (RM554379) - FIAP 2025**