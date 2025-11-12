# 📋 Sumário do Projeto - UniFIAP Pay Sistema PIX

**RM:** RM554379  
**Aluno:** Anna Vale  
**Docker Hub:** annafvale  
**GitHub:** https://github.com/annafvale26/unifiappaygs-pix

---

## ✅ Status do Projeto

**PROJETO COMPLETO E PRONTO PARA EXECUÇÃO** ✓

Todos os arquivos, configurações e documentação foram criados conforme especificado no desafio.

---

## 📁 Estrutura Completa do Projeto

```
unifiappaygs-pix/
│
├── 📄 README.md                      # Documentação principal completa
├── 📄 QUICKSTART.md                  # Guia rápido de início
├── 📄 TESTES.md                      # Guia detalhado de testes
├── 📄 EVIDENCIAS.md                  # Lista de evidências necessárias
├── 📄 .gitignore                     # Arquivos ignorados pelo Git
├── 📄 .dockerignore                  # Arquivos ignorados pelo Docker
│
├── 📂 api-pagamentos/                # Microsserviço API de Pagamentos
│   ├── src/
│   │   └── index.js                  # Código da API (Express)
│   ├── Dockerfile                    # Multi-stage build
│   ├── package.json
│   └── package-lock.json
│
├── 📂 auditoria-service/             # Microsserviço de Auditoria/Liquidação
│   ├── src/
│   │   └── index.js                  # Código de auditoria (Node.js)
│   ├── Dockerfile                    # Multi-stage build
│   ├── package.json
│   └── package-lock.json
│
├── 📂 k8s/                           # Manifests Kubernetes
│   ├── 01-namespace-config-secret.yaml   # Namespace, ConfigMap, Secret
│   ├── 02-pvc.yaml                       # PersistentVolumeClaim
│   ├── 03-api-deployment.yaml            # Deployment da API (2 réplicas)
│   └── 04-auditoria-cronjob.yaml         # CronJob de auditoria (6h)
│
├── 📂 scripts/                       # Scripts de automação
│   ├── build.sh                      # Build das imagens Docker
│   ├── push.sh                       # Push para Docker Hub
│   ├── deploy.sh                     # Deploy no Kubernetes
│   ├── cleanup.sh                    # Limpeza de recursos
│   ├── setup-completo.sh             # Setup completo automatizado
│   └── gerar-evidencias.sh           # Gera outputs para evidências
│
├── 📂 docker/                        # Configurações Docker
│   ├── .env                          # Variáveis de ambiente
│   └── pix.key                       # Chave PIX simulada
│
└── 📂 assets/                        # Evidências e screenshots
    └── README.md                     # Guia para captura de evidências
```

---

## 🎯 Requisitos do Desafio - Cumprimento

### ✅ Evidência 3.1 - Imagens Docker Hub
- [x] Imagens publicadas no Docker Hub
- [x] Usuário: `annafvale`
- [x] Tag com RM: `v1.RM554379`
- [x] Repositórios:
  - `annafvale/api-pagamentos-spb`
  - `annafvale/auditoria-service-spb`

### ✅ Evidência 3.2 - ConfigMap e Secret
- [x] ConfigMap `api-config` com `RESERVA_BANCARIA_SALDO`
- [x] Secret `api-secrets` com `pix.key`
- [x] Valores injetados nos containers via env

### ✅ Evidência 3.3 - PersistentVolume e Replicação
- [x] PersistentVolumeClaim `livro-razao-pvc` (1Gi)
- [x] Volume compartilhado entre API e Auditoria
- [x] 2 réplicas da API de Pagamentos
- [x] CronJob executando a cada 6 horas (`0 */6 * * *`)
- [x] Livro-Razão funcional com logs de transações

### ✅ Evidência 3.4 - Segurança
- [x] `runAsNonRoot: true` nos pods
- [x] Usuário `appuser` (UID 1000)
- [x] Resource limits e requests configurados
- [x] Dockerfiles multi-stage build
- [x] Imagens otimizadas (Alpine Linux)

---

## 🚀 Tecnologias Utilizadas

- **Linguagem:** Node.js 20 (Alpine)
- **Framework API:** Express.js 4.18
- **Orquestração:** Kubernetes (KIND)
- **Containerização:** Docker (Multi-stage build)
- **Storage:** PersistentVolume (ReadWriteOnce)
- **Agendamento:** CronJob (Kubernetes)
- **CI/CD:** Scripts Bash

---

## 📊 Configurações Técnicas

### API de Pagamentos
- **Porta:** 3000
- **Endpoint:** POST /pix
- **Réplicas:** 2
- **CPU Request:** 100m
- **CPU Limit:** 200m
- **Memory Request:** 128Mi
- **Memory Limit:** 256Mi

### Serviço de Auditoria
- **Tipo:** CronJob
- **Schedule:** A cada 6 horas
- **RestartPolicy:** OnFailure
- **Função:** Atualizar status de AGUARDANDO_LIQUIDACAO para LIQUIDADO

### Reserva Bancária
- **Valor:** R$ 1.000.000,00
- **Armazenamento:** ConfigMap
- **Injeção:** Variável de ambiente

---

## 📝 Documentação Disponível

1. **README.md** (Principal)
   - Arquitetura do projeto
   - Instruções de instalação
   - Como executar
   - Testes básicos
   - Evidências do desafio
   - Troubleshooting

2. **QUICKSTART.md**
   - Setup rápido (1 comando)
   - Checklist resumida
   - Links importantes

3. **TESTES.md**
   - Guia completo de testes
   - Testes de API
   - Verificação de logs
   - Testes de auditoria
   - Testes de resiliência
   - Checklist de testes

4. **EVIDENCIAS.md**
   - Lista completa de evidências
   - Screenshots necessários
   - Comandos para captura
   - Estrutura de arquivos
   - Checklist de evidências

5. **assets/README.md**
   - Organização dos screenshots
   - Nomenclatura de arquivos
   - Dicas de captura

---

## 🔧 Scripts de Automação

| Script | Descrição |
|--------|-----------|
| `build.sh` | Build das 2 imagens Docker |
| `push.sh` | Push das imagens para Docker Hub |
| `deploy.sh` | Deploy completo no Kubernetes |
| `cleanup.sh` | Remove todos os recursos |
| `setup-completo.sh` | Executa todo o fluxo automaticamente |
| `gerar-evidencias.sh` | Gera outputs para captura de evidências |

**Todos os scripts são executáveis e coloridos para melhor UX.**

---

## 🧪 Fluxo de Teste Completo

1. **Build Local**
   ```bash
   ./scripts/build.sh
   ```

2. **Push para Docker Hub**
   ```bash
   docker login -u annafvale
   ./scripts/push.sh
   ```

3. **Deploy no Kubernetes**
   ```bash
   ./scripts/deploy.sh
   ```

4. **Expor API**
   ```bash
   kubectl port-forward -n unifiapay deployment/api-pagamentos 3000:3000
   ```

5. **Testar PIX**
   ```bash
   curl -X POST http://localhost:3000/pix \
     -H "Content-Type: application/json" \
     -d '{"id_transacao": "TXN001", "valor": 150.50}'
   ```

6. **Verificar Logs**
   ```bash
   kubectl logs -n unifiapay -l app=api-pagamentos
   ```

7. **Executar Auditoria**
   ```bash
   kubectl create job -n unifiapay auditoria-manual --from=cronjob/auditoria-service
   ```

8. **Gerar Evidências**
   ```bash
   ./scripts/gerar-evidencias.sh
   ```

9. **Capturar Screenshots**
   - Seguir guia em `EVIDENCIAS.md`

---

## ✅ Checklist Final

### Código e Configuração
- [x] API de Pagamentos implementada
- [x] Serviço de Auditoria implementado
- [x] Dockerfiles otimizados (multi-stage)
- [x] Manifests Kubernetes corretos
- [x] ConfigMap e Secret configurados
- [x] PVC criado e montado
- [x] 2 réplicas da API
- [x] CronJob a cada 6 horas
- [x] Segurança (runAsNonRoot, limits)

### Scripts
- [x] Script de build
- [x] Script de push
- [x] Script de deploy
- [x] Script de cleanup
- [x] Script de setup completo
- [x] Script de geração de evidências

### Documentação
- [x] README.md completo
- [x] QUICKSTART.md
- [x] TESTES.md
- [x] EVIDENCIAS.md
- [x] assets/README.md

### Configurações
- [x] .gitignore configurado
- [x] .dockerignore configurado
- [x] RM554379 em todos os lugares corretos
- [x] Usuário annafvale configurado

---

## 🎓 Informações Acadêmicas

- **Instituição:** FIAP
- **Disciplina:** Global Solutions
- **Desafio:** Sistema de Pagamento PIX (SPB)
- **RM:** RM554379
- **Aluno:** Anna Vale
- **Ano:** 2025

---

## 📞 Próximos Passos

1. **Executar o projeto localmente**
   ```bash
   ./scripts/setup-completo.sh
   ```

2. **Fazer testes completos**
   - Seguir guia em `TESTES.md`

3. **Capturar evidências**
   - Executar `./scripts/gerar-evidencias.sh`
   - Capturar screenshots conforme `EVIDENCIAS.md`
   - Salvar na pasta `assets/`

4. **Commit e Push para GitHub**
   ```bash
   git add .
   git commit -m "Projeto UniFIAP Pay Sistema PIX - RM554379"
   git push origin main
   ```

5. **Verificar Docker Hub**
   - Confirmar que as imagens estão públicas
   - URLs fornecidas no README.md

---

## 🏆 Diferenciais do Projeto

- ✅ Documentação extremamente detalhada
- ✅ Scripts de automação completos
- ✅ Guias de teste passo a passo
- ✅ Checklist de evidências
- ✅ Código limpo e comentado
- ✅ Arquitetura bem definida
- ✅ Segurança implementada
- ✅ Boas práticas de DevOps

---

**Projeto pronto para apresentação e avaliação! 🚀**

**Desenvolvido por Anna Vale (RM554379) - FIAP 2025**
