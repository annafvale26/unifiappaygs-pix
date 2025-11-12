# 🚀 Quick Start Guide - UniFIAP Pay Sistema PIX

**RM554379 - Anna Vale**

Este é um guia rápido para executar o projeto do zero.

## ⚡ Setup Rápido (1 comando)

Se você já tem Docker, kubectl e KIND instalados:

```bash
./scripts/setup-completo.sh
```

Este script executará automaticamente:
1. Verificação de pré-requisitos
2. Criação do cluster KIND
3. Build das imagens Docker
4. Push para Docker Hub
5. Deploy no Kubernetes

---

## 📝 Setup Passo a Passo

### 1. Pré-requisitos

```bash
# Verificar Docker
docker --version

# Verificar kubectl
kubectl version --client

# Instalar KIND (se necessário)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### 2. Criar Cluster

```bash
kind create cluster --name unifiapay-cluster
```

### 3. Build + Push + Deploy

```bash
# Build das imagens
./scripts/build.sh

# Login no Docker Hub
docker login -u annafvale

# Push das imagens
./scripts/push.sh

# Deploy no Kubernetes
./scripts/deploy.sh
```

### 4. Acessar a API

```bash
# Em um terminal separado
kubectl port-forward -n unifiapay deployment/api-pagamentos 3000:3000
```

### 5. Testar

```bash
# PIX aprovado
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{"id_transacao": "TXN001", "valor": 150.50}'

# Resultado: {"status":"PIX Aceito",...}
```

---

## 📊 Verificar Status

```bash
# Ver todos os recursos
kubectl get all -n unifiapay

# Ver logs da API
kubectl logs -n unifiapay -l app=api-pagamentos -f

# Ver livro-razão
kubectl exec -n unifiapay $(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}') -- cat /var/logs/api/instrucoes.log
```

---

## 🧪 Executar Auditoria Manualmente

```bash
kubectl create job -n unifiapay auditoria-manual --from=cronjob/auditoria-service

# Ver logs
kubectl logs -n unifiapay job/auditoria-manual
```

---

## 🧹 Limpeza

```bash
# Deletar recursos Kubernetes
./scripts/cleanup.sh

# Ou deletar o cluster inteiro
kind delete cluster --name unifiapay-cluster
```

---

## 📚 Documentação Completa

- **README.md** - Documentação principal do projeto
- **TESTES.md** - Guia completo de testes
- **EVIDENCIAS.md** - Lista de evidências necessárias
- **assets/** - Screenshots e evidências

---

## 🆘 Troubleshooting Rápido

### Pods não iniciam
```bash
kubectl describe pod -n unifiapay <pod-name>
```

### API não responde
```bash
kubectl logs -n unifiapay -l app=api-pagamentos
```

### Reimplantar após mudanças
```bash
kubectl rollout restart deployment api-pagamentos -n unifiapay
```

---

## ✅ Checklist do Desafio

- [ ] Cluster KIND criado
- [ ] Imagens buildadas com tag `v1.RM554379`
- [ ] Imagens publicadas no Docker Hub (annafvale)
- [ ] ConfigMap e Secret criados
- [ ] PVC montado e compartilhado
- [ ] API rodando com 2 réplicas
- [ ] CronJob configurado para 6h
- [ ] SecurityContext com runAsNonRoot
- [ ] Resource limits configurados
- [ ] Testes executados com sucesso
- [ ] Screenshots capturados na pasta assets/
- [ ] README.md completo
- [ ] Código commitado no GitHub

---

## 🔗 Links Importantes

- **Repositório GitHub:** https://github.com/annafvale26/unifiappaygs-pix
- **Docker Hub API:** https://hub.docker.com/r/annafvale/api-pagamentos-spb
- **Docker Hub Auditoria:** https://hub.docker.com/r/annafvale/auditoria-service-spb

---

**Tempo estimado de setup:** 15-20 minutos

**Dúvidas?** Consulte o README.md completo ou o arquivo TESTES.md
