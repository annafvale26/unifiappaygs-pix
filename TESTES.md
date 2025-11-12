# 🧪 Guia de Testes - UniFIAP Pay Sistema PIX

**RM554379 - Anna Vale**

## Pré-requisitos para Testes

Certifique-se de que:
1. O cluster Kubernetes está rodando
2. Os deployments estão ativos
3. O port-forward está configurado

```bash
# Verificar status dos pods
kubectl get pods -n unifiapay

# Configurar port-forward
kubectl port-forward -n unifiapay deployment/api-pagamentos 3000:3000
```

## 1. Testes da API de Pagamentos

### 1.1 Teste de PIX Aprovado (Dentro da Reserva)

```bash
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{
    "id_transacao": "TXN001",
    "valor": 150.50
  }'
```

**Resposta Esperada:**
```json
{
  "status": "PIX Aceito",
  "transacao": "TXN001",
  "estado": "AGUARDANDO_LIQUIDACAO"
}
```

**Código HTTP:** `202 Accepted`

---

### 1.2 Teste de PIX Rejeitado (Acima da Reserva)

A reserva bancária configurada é de **R$ 1.000.000,00**.

```bash
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{
    "id_transacao": "TXN002",
    "valor": 2000000.00
  }'
```

**Resposta Esperada:**
```json
{
  "status": "PIX Rejeitado",
  "motivo": "Fundos insuficientes na Reserva Bancária."
}
```

**Código HTTP:** `400 Bad Request`

---

### 1.3 Teste de Validação - Campos Obrigatórios

```bash
# Teste sem valor
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{
    "id_transacao": "TXN003"
  }'
```

**Resposta Esperada:**
```json
{
  "erro": "Valor e id_transacao são obrigatórios."
}
```

**Código HTTP:** `400 Bad Request`

---

### 1.4 Múltiplas Transações

```bash
# Transação 1
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{"id_transacao": "TXN101", "valor": 100.00}'

# Transação 2
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{"id_transacao": "TXN102", "valor": 250.75}'

# Transação 3
curl -X POST http://localhost:3000/pix \
  -H "Content-Type: application/json" \
  -d '{"id_transacao": "TXN103", "valor": 500.00}'
```

---

## 2. Verificar Livro-Razão (Logs)

### 2.1 Listar Pods da API

```bash
kubectl get pods -n unifiapay -l app=api-pagamentos
```

### 2.2 Acessar o Pod e Ver o Log

```bash
# Substituir <pod-name> pelo nome real do pod
kubectl exec -it -n unifiapay <pod-name> -- sh

# Dentro do pod, visualizar o livro-razão
cat /var/logs/api/instrucoes.log

# Sair do pod
exit
```

**Exemplo de conteúdo do log:**
```
2025-11-12T15:30:25.123Z | TXN001 | 150.50 | AGUARDANDO_LIQUIDACAO
2025-11-12T15:31:10.456Z | TXN101 | 100.00 | AGUARDANDO_LIQUIDACAO
2025-11-12T15:31:15.789Z | TXN102 | 250.75 | AGUARDANDO_LIQUIDACAO
2025-11-12T15:31:20.012Z | TXN103 | 500.00 | AGUARDANDO_LIQUIDACAO
```

### 2.3 Ver Logs da API em Tempo Real

```bash
kubectl logs -n unifiapay -l app=api-pagamentos --tail=50 -f
```

---

## 3. Teste do Serviço de Auditoria/Liquidação

### 3.1 Verificar CronJob Configurado

```bash
kubectl get cronjob -n unifiapay
```

**Saída esperada:**
```
NAME                  SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
auditoria-service     0 */6 * * *   False     0        <none>          5m
```

O CronJob está configurado para rodar **a cada 6 horas**.

### 3.2 Executar Auditoria Manualmente (Teste)

```bash
# Criar um Job manual a partir do CronJob
kubectl create job -n unifiapay auditoria-manual --from=cronjob/auditoria-service

# Verificar status do Job
kubectl get jobs -n unifiapay

# Ver logs da execução
kubectl logs -n unifiapay job/auditoria-manual
```

**Saída esperada nos logs:**
```
[Auditoria] Iniciando processo de liquidação...
[Auditoria] Processo de liquidação concluído. Status atualizado para LIQUIDADO.
```

### 3.3 Verificar Atualização do Status no Log

Após executar a auditoria, verifique se o status foi atualizado de `AGUARDANDO_LIQUIDACAO` para `LIQUIDADO`:

```bash
# Pegar nome de um pod da API
POD_NAME=$(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')

# Ver conteúdo atualizado do log
kubectl exec -n unifiapay $POD_NAME -- cat /var/logs/api/instrucoes.log
```

**Exemplo após liquidação:**
```
2025-11-12T15:30:25.123Z | TXN001 | 150.50 | LIQUIDADO
2025-11-12T15:31:10.456Z | TXN101 | 100.00 | LIQUIDADO
2025-11-12T15:31:15.789Z | TXN102 | 250.75 | LIQUIDADO
```

---

## 4. Testes de Evidências do Desafio

### 4.1 Evidência 3.1 - Imagens no Docker Hub

```bash
# Verificar imagens localmente
docker images | grep annafvale

# Pull das imagens do Docker Hub
docker pull annafvale/api-pagamentos-spb:v1.RM554379
docker pull annafvale/auditoria-service-spb:v1.RM554379
```

### 4.2 Evidência 3.2 - ConfigMap e Secret

```bash
# Visualizar ConfigMap
kubectl get configmap api-config -n unifiapay -o yaml

# Verificar valor da reserva
kubectl get configmap api-config -n unifiapay -o jsonpath='{.data.RESERVA_BANCARIA_SALDO}'

# Visualizar Secret (base64)
kubectl get secret api-secrets -n unifiapay -o yaml

# Decodificar chave PIX
kubectl get secret api-secrets -n unifiapay -o jsonpath='{.data.pix\.key}' | base64 -d
```

### 4.3 Evidência 3.3 - PersistentVolume e Replicação

```bash
# Verificar PVC
kubectl get pvc -n unifiapay
kubectl describe pvc livro-razao-pvc -n unifiapay

# Verificar réplicas (devem ser 2)
kubectl get deployment api-pagamentos -n unifiapay
kubectl describe deployment api-pagamentos -n unifiapay | grep Replicas

# Listar todos os pods da API
kubectl get pods -n unifiapay -l app=api-pagamentos -o wide
```

### 4.4 Evidência 3.4 - Segurança

```bash
# Verificar configuração de segurança
kubectl get pod -n unifiapay -l app=api-pagamentos -o yaml | grep -A 10 securityContext

# Verificar limites de recursos
kubectl describe deployment api-pagamentos -n unifiapay | grep -A 8 "Limits:"

# Verificar que roda como non-root
kubectl get pod -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].spec.securityContext}'
```

---

## 5. Testes de Estresse (Opcional)

### 5.1 Múltiplas Requisições Simultâneas

```bash
# Enviar 10 requisições em paralelo
for i in {1..10}; do
  curl -X POST http://localhost:3000/pix \
    -H "Content-Type: application/json" \
    -d "{\"id_transacao\": \"TXN$i\", \"valor\": $((RANDOM % 1000 + 1))}" &
done
wait

echo "Todas as requisições foram enviadas!"
```

### 5.2 Verificar Comportamento das 2 Réplicas

```bash
# Ver distribuição de requisições entre os pods
kubectl logs -n unifiapay -l app=api-pagamentos --tail=100 | grep "PIX"
```

---

## 6. Testes de Resiliência

### 6.1 Deletar um Pod e Verificar Recuperação

```bash
# Listar pods
kubectl get pods -n unifiapay -l app=api-pagamentos

# Deletar um pod (Kubernetes irá recriar automaticamente)
kubectl delete pod -n unifiapay <pod-name>

# Verificar que um novo pod foi criado
kubectl get pods -n unifiapay -l app=api-pagamentos -w
```

### 6.2 Escalar Deployment

```bash
# Aumentar para 3 réplicas
kubectl scale deployment api-pagamentos -n unifiapay --replicas=3

# Verificar
kubectl get pods -n unifiapay -l app=api-pagamentos

# Voltar para 2 réplicas
kubectl scale deployment api-pagamentos -n unifiapay --replicas=2
```

---

## 7. Captura de Evidências (Screenshots)

Execute os seguintes comandos e capture screenshots para a pasta `assets/`:

```bash
# 1. Recursos Kubernetes
kubectl get all -n unifiapay

# 2. Detalhes do Deployment
kubectl describe deployment api-pagamentos -n unifiapay

# 3. ConfigMap e Secret
kubectl get configmap,secret -n unifiapay

# 4. PVC
kubectl get pvc -n unifiapay

# 5. CronJob
kubectl describe cronjob auditoria-service -n unifiapay

# 6. Conteúdo do Livro-Razão
kubectl exec -n unifiapay <pod-name> -- cat /var/logs/api/instrucoes.log

# 7. Imagens Docker Hub
docker images | grep annafvale
```

---

## 8. Limpeza Após Testes

```bash
# Deletar o Job manual de auditoria
kubectl delete job auditoria-manual -n unifiapay

# Ou deletar todo o namespace
kubectl delete namespace unifiapay

# Ou usar o script de limpeza
./scripts/cleanup.sh
```

---

## 9. Troubleshooting de Testes

### API não responde

```bash
# Verificar se o port-forward está ativo
lsof -i :3000

# Verificar logs de erro
kubectl logs -n unifiapay -l app=api-pagamentos --tail=50

# Verificar status dos pods
kubectl get pods -n unifiapay
```

### Log vazio ou não encontrado

```bash
# Verificar se o PVC foi montado corretamente
kubectl describe pod -n unifiapay <pod-name> | grep -A 5 Mounts

# Verificar se o diretório existe
kubectl exec -n unifiapay <pod-name> -- ls -la /var/logs/api/
```

---

## Checklist de Testes Completo

- [ ] PIX aprovado (valor < reserva)
- [ ] PIX rejeitado (valor > reserva)
- [ ] Validação de campos obrigatórios
- [ ] Múltiplas transações registradas no log
- [ ] Log contém status AGUARDANDO_LIQUIDACAO
- [ ] Auditoria executa e atualiza para LIQUIDADO
- [ ] 2 réplicas da API rodando
- [ ] CronJob configurado corretamente
- [ ] ConfigMap e Secret criados
- [ ] PVC montado corretamente
- [ ] Segurança (runAsNonRoot, recursos)
- [ ] Imagens publicadas no Docker Hub
- [ ] Screenshots capturados

---

**Boa sorte com os testes! 🚀**
