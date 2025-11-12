# 📸 Assets - Evidências do Projeto

Esta pasta contém todas as evidências (screenshots e capturas) do projeto UniFIAP Pay Sistema PIX.

## 📋 Estrutura de Arquivos

### Evidência 3.1 - Imagens Docker Hub
- `3.1-dockerhub-api-pagamentos.png` - Screenshot do repositório no Docker Hub
- `3.1-dockerhub-auditoria-service.png` - Screenshot do repositório no Docker Hub
- `3.1-docker-images-local.png` - Imagens locais listadas

### Evidência 3.2 - ConfigMap e Secret
- `3.2-configmap.png` - ConfigMap com reserva bancária
- `3.2-secret.png` - Secret criado (base64)
- `3.2-secret-decoded.png` - Secret decodificado

### Evidência 3.3 - PersistentVolume e Replicação
- `3.3-pvc.png` - PersistentVolumeClaim
- `3.3-replicas.png` - 2 réplicas da API rodando
- `3.3-cronjob.png` - CronJob configurado
- `3.3-livro-razao-antes.png` - Log ANTES da liquidação
- `3.3-livro-razao-depois.png` - Log DEPOIS da liquidação

### Evidência 3.4 - Segurança
- `3.4-security-context.png` - runAsNonRoot configurado
- `3.4-resource-limits.png` - Limites de CPU e memória
- `3.4-dockerfile-multistage.png` - Multi-stage build
- `3.4-image-size.png` - Tamanho otimizado das imagens

### Testes de Funcionamento
- `teste-pix-aprovado.png` - PIX aceito
- `teste-pix-rejeitado.png` - PIX rejeitado por falta de fundos
- `teste-logs-api.png` - Logs da API em execução
- `teste-auditoria-logs.png` - Logs da execução da auditoria
- `visao-geral-recursos.png` - Todos os recursos Kubernetes

### Extras (Opcional)
- `arquitetura-diagrama.png` - Diagrama da arquitetura
- `fluxo-pix.png` - Fluxo do processo PIX

## 🎯 Como Gerar as Evidências

1. Execute o script de geração de outputs:
```bash
./scripts/gerar-evidencias.sh
```

2. Capture os screenshots dos outputs no terminal

3. Para capturas do navegador (Docker Hub):
   - Acesse: https://hub.docker.com/r/annafvale/api-pagamentos-spb
   - Acesse: https://hub.docker.com/r/annafvale/auditoria-service-spb

4. Salve todos os arquivos nesta pasta seguindo a nomenclatura acima

## 📝 Dicas

- Use fundo escuro no terminal para melhor contraste
- Inclua o comando executado no screenshot
- Use resolução mínima de 1280x720
- Certifique-se que o RM554379 está visível onde aplicável

## ✅ Checklist

- [ ] Todos os screenshots da Evidência 3.1
- [ ] Todos os screenshots da Evidência 3.2
- [ ] Todos os screenshots da Evidência 3.3
- [ ] Todos os screenshots da Evidência 3.4
- [ ] Todos os screenshots de testes
- [ ] Screenshot de visão geral dos recursos

---

**RM554379 - Anna Vale**
