# Auto Grand Premium Outlet API

API REST para gestão de veículos, vendas e pagamentos desenvolvida em Elixir/Phoenix seguindo os princípios de **Clean Architecture** e **SOLID**.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias](#tecnologias)
- [Arquitetura](#arquitetura)
- [Instalação](#instalação)
- [Executando o Projeto](#executando-o-projeto)
- [Testes](#testes)
- [API Endpoints](#api-endpoints)
- [Exemplos de Uso](#exemplos-de-uso)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Princípios e Padrões](#princípios-e-padrões)
- [Documentação](#documentação)
- [Contribuição](#contribuição)

## 🚀 Sobre o Projeto

Sistema de gestão para uma concessionária de veículos premium que permite:
- Cadastro e gerenciamento de veículos
- Criação e acompanhamento de vendas
- Processamento de pagamentos
- Webhooks para integração com sistemas externos

O projeto foi desenvolvido seguindo rigorosamente os princípios de **Clean Architecture** e **SOLID**, garantindo código limpo, testável e manutenível.

## 🛠 Tecnologias

- **Elixir** ~> 1.12
- **Phoenix** ~> 1.6.16
- **Ecto** ~> 3.6
- **PostgreSQL** (opcional, usando in-memory storage por padrão)
- **Phoenix Swagger** para documentação da API
- **OpenAPI 3.0** para especificação da API

## 🏗 Arquitetura

O projeto segue **Clean Architecture** com separação clara de responsabilidades:

```
Domain (Núcleo)
  ├── Entities (Payment, Sale, Vehicle)
  ├── Repositories (Ports/Behaviours)
  └── Services (Ports: Clock, IdGenerator, CodeGenerator)

Use Cases (Aplicação)
  ├── Payments
  ├── Sales
  ├── Vehicles
  ├── ParamsNormalizer
  └── VehicleFilter

Infrastructure (Adaptadores)
  ├── Repositories (Implementações)
  └── Services (Implementações)

Web (Interface)
  ├── Controllers
  ├── Serializers
  └── BaseController
```

### Princípios Aplicados

- ✅ **Dependency Rule**: Dependências apontam para dentro (Domain é independente)
- ✅ **Independência de Frameworks**: Domain não conhece Phoenix, Ecto, etc.
- ✅ **Independência de UI**: Use cases podem ser usados por CLI, API, etc.
- ✅ **Independência de Banco de Dados**: Repositórios são abstrações

## 📦 Instalação

### Pré-requisitos

- Elixir ~> 1.12
- Erlang/OTP 24+
- PostgreSQL (opcional, usando in-memory storage por padrão)

### Passos

1. Clone o repositório:
```bash
git clone <repository-url>
cd auto_grand_premium_outlet-1
```

2. Instale as dependências:
```bash
mix deps.get
```

3. Configure o banco de dados (opcional):
```bash
mix ecto.create
mix ecto.migrate
```

## ▶️ Executando o Projeto

### Docker Compose (Recomendado)

A forma mais simples de executar o projeto localmente:

```bash
# Copie o arquivo de exemplo de variáveis de ambiente
cp .env.example .env

# Edite o .env e configure SECRET_KEY_BASE (gere com: mix phx.gen.secret)

# Inicie todos os serviços
docker compose up
```

O servidor estará disponível em `http://localhost:4000`

Para executar em background:
```bash
docker compose up -d
```

Para parar:
```bash
docker compose down
```

### Desenvolvimento Local

```bash
# Inicie o servidor Phoenix
mix phx.server
```

O servidor estará disponível em `http://localhost:4000`

### Swagger UI

Acesse a documentação interativa da API em:
```
http://localhost:4000/swaggerui
```

### Dashboard

Em ambiente de desenvolvimento, acesse o LiveDashboard em:
```
http://localhost:4000/dashboard
```

## 🧪 Testes

Execute todos os testes:

```bash
mix test
```

Execute testes de um módulo específico:

```bash
mix test test/auto_grand_premium_outlet/domain/payment_test.exs
```

## 📡 API Endpoints

### Veículos

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/vehicles/available` | Lista veículos disponíveis ordenados por preço |
| `GET` | `/api/vehicles/sold` | Lista veículos vendidos ordenados por preço |
| `GET` | `/api/vehicles/:id` | Busca um veículo por ID |
| `POST` | `/api/vehicles` | Cria um novo veículo |
| `PUT` | `/api/vehicles/:id` | Atualiza um veículo |

### Vendas

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/api/sales` | Cria uma nova venda |
| `PUT` | `/api/sales/:sale_id/complete` | Completa uma venda |
| `PUT` | `/api/sales/:sale_id/cancel` | Cancela uma venda |

### Pagamentos

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/api/payments` | Cria um novo pagamento |
| `PUT` | `/api/payments/:payment_code/confirm` | Confirma um pagamento |
| `PUT` | `/api/payments/:payment_code/cancel` | Cancela um pagamento |

### Webhooks

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `PUT` | `/api/webhooks/payments/confirm` | Webhook para confirmar pagamento |
| `PUT` | `/api/webhooks/payments/cancel` | Webhook para cancelar pagamento |

## 💡 Exemplos de Uso

### Fluxo Completo: Criar Veículo → Vender → Pagar

```bash
# 1. Criar um veículo
VEHICLE_ID=$(curl -s -X POST http://localhost:4000/api/vehicles \
  -H 'Content-Type: application/json' \
  -d '{
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2022,
    "color": "Preto",
    "price": 120000,
    "license_plate": "ABC1D23"
  }' | jq -r '.id')

echo "Vehicle ID: $VEHICLE_ID"

# 2. Criar uma venda
SALE_ID=$(curl -s -X POST http://localhost:4000/api/sales \
  -H 'Content-Type: application/json' \
  -d "{
    \"vehicle_id\": \"$VEHICLE_ID\",
    \"buyer_cpf\": \"12345678901\"
  }" | jq -r '.id')

echo "Sale ID: $SALE_ID"

# 3. Criar um pagamento
PAYMENT_RESPONSE=$(curl -s -X POST http://localhost:4000/api/payments \
  -H 'Content-Type: application/json' \
  -d "{
    \"sale_id\": \"$SALE_ID\",
    \"amount\": 120000
  }")

PAYMENT_CODE=$(echo $PAYMENT_RESPONSE | jq -r '.payment_code')
echo "Payment Code: $PAYMENT_CODE"

# 4. Confirmar o pagamento (marca o veículo como vendido)
curl -X PUT "http://localhost:4000/api/payments/$PAYMENT_CODE/confirm" \
  -H 'Content-Type: application/json'

# 5. Verificar se o veículo foi marcado como vendido
curl -s "http://localhost:4000/api/vehicles/$VEHICLE_ID" | jq '.status'
# Resultado: "sold"
```

### Listar Veículos Disponíveis

```bash
curl -X GET http://localhost:4000/api/vehicles/available \
  -H 'accept: application/json' | jq .
```

### Atualizar Veículo

```bash
curl -X PUT "http://localhost:4000/api/vehicles/$VEHICLE_ID" \
  -H 'Content-Type: application/json' \
  -d '{
    "price": 130000
  }' | jq .
```

### Webhook de Confirmação de Pagamento

```bash
curl -X PUT http://localhost:4000/api/webhooks/payments/confirm \
  -H 'Content-Type: application/json' \
  -d '{
    "payment_code": "pay_456"
  }'
```

## 📁 Estrutura do Projeto

```
lib/
├── auto_grand_premium_outlet/
│   ├── domain/                    # Camada de Domínio (Núcleo)
│   │   ├── entities/             # Entidades de negócio
│   │   ├── repositories/          # Ports (Behaviours)
│   │   └── services/             # Serviços de domínio (Ports)
│   ├── use_cases/                # Camada de Aplicação
│   │   ├── payments/
│   │   ├── sales/
│   │   ├── vehicles/
│   │   ├── params_normalizer.ex
│   │   └── vehicle_filter.ex
│   └── infra/                     # Camada de Infraestrutura
│       ├── repositories/          # Implementações dos repositórios
│       └── services/              # Implementações dos serviços
└── auto_grand_premium_outlet_web/ # Camada Web (Interface)
    ├── controllers/
    ├── serializers/
    └── base_controller.ex

test/
├── auto_grand_premium_outlet/
│   ├── domain/                   # Testes das entidades
│   └── use_cases/                # Testes dos use cases
└── auto_grand_premium_outlet_web/
    └── controllers/              # Testes dos controllers
```

## 🎯 Princípios e Padrões

### Clean Architecture

- ✅ **Domain 100% independente**: Não depende de frameworks, UI ou banco de dados
- ✅ **Dependency Inversion**: Use cases dependem de abstrações (behaviours)
- ✅ **Separação de responsabilidades**: Cada camada tem uma responsabilidade clara

### SOLID

- ✅ **SRP (Single Responsibility)**: Cada módulo tem uma única responsabilidade
- ✅ **OCP (Open/Closed)**: Aberto para extensão, fechado para modificação
- ✅ **LSP (Liskov Substitution)**: Implementações podem ser substituídas
- ✅ **ISP (Interface Segregation)**: Interfaces focadas e mínimas
- ✅ **DIP (Dependency Inversion)**: Dependências apontam para abstrações

### DRY (Don't Repeat Yourself)

- ✅ **BaseController**: Centraliza helpers de dependências
- ✅ **VehicleFilter**: Centraliza lógica de filtragem
- ✅ **ParamsNormalizer**: Centraliza normalização de parâmetros

## 🐳 Docker

### Build da Imagem

```bash
docker build -t auto-grand-premium-outlet:latest .
```

### Executar Container

```bash
docker run -p 4000:4000 \
  -e DATABASE_URL="ecto://postgres:postgres@host.docker.internal:5432/auto_grand_premium_outlet_prod" \
  -e SECRET_KEY_BASE="your-secret-key-base" \
  auto-grand-premium-outlet:latest
```

## ☸️ Kubernetes

O projeto inclui manifests Kubernetes completos para deploy em cluster.

### Pré-requisitos

- Cluster Kubernetes configurado
- `kubectl` instalado e configurado
- Imagem Docker disponível no registry

### Deploy

1. **Atualize os secrets** em `k8s/secret.yaml`:
```bash
# Gere um secret key base
mix phx.gen.secret

# Edite k8s/secret.yaml e atualize:
# - POSTGRES_PASSWORD
# - SECRET_KEY_BASE
# - DATABASE_URL
```

2. **Aplique os manifests**:
```bash
kubectl apply -f k8s/
```

3. **Verifique o status**:
```bash
kubectl get pods -n auto-grand-premium-outlet
kubectl get services -n auto-grand-premium-outlet
```

Para mais detalhes, consulte [k8s/README.md](./k8s/README.md)

## 📚 Documentação

### Arquitetura

Consulte o relatório completo de arquitetura:
- [ARCHITECTURE_REPORT_V2.md](./ARCHITECTURE_REPORT_V2.md)

### API

- **Swagger UI**: `http://localhost:4000/swagger/index.html`
- **OpenAPI Spec**: `priv/static/swagger/openapi.yaml`

## 🔧 Configuração

### Ambiente de Desenvolvimento

As configurações estão em `config/dev.exs`. Por padrão, o projeto usa repositórios em memória (Agents) para facilitar o desenvolvimento.

### Ambiente de Teste

As configurações estão em `config/test.exs`. Mocks são usados para testes isolados.

### Ambiente de Produção

As configurações estão em `config/prod.exs`. Configure as variáveis de ambiente conforme necessário.

## 🧩 Armazenamento

Por padrão, o projeto usa **armazenamento em memória** (Elixir Agents) para facilitar o desenvolvimento. Os repositórios são:

- `AutoGrandPremiumOutlet.Infra.Repositories.VehicleRepo`
- `AutoGrandPremiumOutlet.Infra.Repositories.SaleRepo`
- `AutoGrandPremiumOutlet.Infra.Repositories.PaymentRepo`

Para usar PostgreSQL, configure o Ecto e atualize os repositórios conforme necessário.

## ✅ Status do Projeto

- ✅ Clean Architecture: **10/10**
- ✅ SOLID Principles: **10/10**
- ✅ Testes: **99 testes passando**
- ✅ Documentação: **Completa**

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

- Siga os princípios de Clean Architecture e SOLID
- Mantenha a cobertura de testes
- Documente mudanças significativas
- Use `mix format` antes de commitar

## 📄 Licença

Este projeto está sob a licença MIT.

## 👥 Autora

- Desenvolvido seguindo Clean Architecture e SOLID principles

---

**Nota**: Este projeto foi desenvolvido como exemplo de implementação de Clean Architecture e SOLID em Elixir/Phoenix. Para mais detalhes sobre a arquitetura, consulte [ARCHITECTURE_REPORT_V2.md](./ARCHITECTURE_REPORT_V2.md).
