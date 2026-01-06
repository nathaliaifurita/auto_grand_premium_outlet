# Kubernetes Manifests

Este diretório contém todos os manifests Kubernetes necessários para implantar a aplicação Auto Grand Premium Outlet em um cluster Kubernetes.

## 📋 Arquivos

- `namespace.yaml` - Namespace para isolar os recursos
- `configmap.yaml` - Configurações não sensíveis da aplicação
- `secret.yaml` - Secrets (senhas, tokens, etc.) - **ATENÇÃO: Atualize antes de usar!**
- `postgres-service.yaml` - Deployment e Service do PostgreSQL
- `app-deployment.yaml` - Deployment da aplicação Phoenix
- `app-service.yaml` - Services (ClusterIP e NodePort)
- `ingress.yaml` - Ingress para roteamento externo (opcional)

## 🚀 Deploy

### Pré-requisitos

1. Cluster Kubernetes configurado e acessível
2. `kubectl` configurado
3. Imagem Docker da aplicação disponível no registry

### Passos

1. **Atualize os Secrets** (IMPORTANTE!):
```bash
# Gere um secret key base
mix phx.gen.secret

# Edite o arquivo secret.yaml e atualize:
# - POSTGRES_PASSWORD
# - SECRET_KEY_BASE
# - DATABASE_URL (com a senha correta)
```

2. **Crie o namespace**:
```bash
kubectl apply -f k8s/namespace.yaml
```

3. **Aplique os recursos na ordem**:
```bash
# ConfigMap
kubectl apply -f k8s/configmap.yaml

# Secrets
kubectl apply -f k8s/secret.yaml

# PostgreSQL
kubectl apply -f k8s/postgres-service.yaml

# Aguarde o PostgreSQL estar pronto
kubectl wait --for=condition=ready pod -l app=postgres -n auto-grand-premium-outlet --timeout=300s

# Aplicação
kubectl apply -f k8s/app-deployment.yaml

# Services
kubectl apply -f k8s/app-service.yaml

# Ingress (opcional)
kubectl apply -f k8s/ingress.yaml
```

### Deploy Completo (Todos os recursos)

```bash
kubectl apply -f k8s/
```

## 🔍 Verificação

### Verificar Pods

```bash
kubectl get pods -n auto-grand-premium-outlet
```

### Verificar Services

```bash
kubectl get services -n auto-grand-premium-outlet
```

### Verificar Logs

```bash
# Logs da aplicação
kubectl logs -f deployment/auto-grand-premium-outlet -n auto-grand-premium-outlet

# Logs do PostgreSQL
kubectl logs -f deployment/postgres -n auto-grand-premium-outlet
```

### Acessar a Aplicação

**Via NodePort:**
```bash
# Descubra o IP do node
kubectl get nodes -o wide

# Acesse via NodePort (porta 30080)
curl http://<NODE_IP>:30080/api/vehicles/available
```

**Via Port Forward:**
```bash
kubectl port-forward -n auto-grand-premium-outlet service/auto-grand-premium-outlet-service 4000:80

# Em outro terminal
curl http://localhost:4000/api/vehicles/available
```

**Via Ingress:**
```bash
# Adicione ao /etc/hosts (ou equivalente)
# <INGRESS_IP> auto-grand-premium-outlet.local

curl http://auto-grand-premium-outlet.local/api/vehicles/available
```

## 🔧 Configuração

### Atualizar ConfigMap

```bash
kubectl edit configmap auto-grand-premium-outlet-config -n auto-grand-premium-outlet
```

### Atualizar Secrets

```bash
kubectl edit secret auto-grand-premium-outlet-secrets -n auto-grand-premium-outlet
```

### Escalar Aplicação

```bash
kubectl scale deployment auto-grand-premium-outlet --replicas=3 -n auto-grand-premium-outlet
```

## 🗑️ Remover

```bash
kubectl delete -f k8s/
```

Ou remover recursos específicos:

```bash
kubectl delete namespace auto-grand-premium-outlet
```

## 📝 Notas

- O **initContainer** executa as migrações antes de iniciar a aplicação
- O PostgreSQL usa um **PersistentVolumeClaim** para persistência
- A aplicação está configurada com **2 réplicas** por padrão
- O **NodePort** expõe a aplicação na porta 30080
- O **Ingress** é opcional e requer um Ingress Controller (ex: NGINX)

## 🔒 Segurança

⚠️ **IMPORTANTE**: Antes de fazer deploy em produção:

1. Atualize todos os valores em `secret.yaml`
2. Use secrets do Kubernetes ou um gerenciador de secrets (ex: Vault)
3. Configure TLS/SSL no Ingress
4. Revise as políticas de rede (NetworkPolicies)
5. Configure ResourceQuotas e LimitRanges
6. Use imagens de um registry privado

