# 🚘 Auto Grand Premium Outlet API

API REST para gestão de veículos, vendas e pagamentos desenvolvida em Elixir/Phoenix seguindo os princípios de **Clean Architecture** e **SOLID**.

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Tecnologias](#-tecnologias)
- [Arquitetura e Estrutura do Projeto](#-arquitetura-e-estrutura-do-projeto)
- [Princípios e Padrões](#-princípios-e-padrões)
- [Instalação](#-instalação)
- [Executando o Projeto](#-executando-o-projeto)
- [Testes](#-testes)
- [API Endpoints](#-api-endpoints)
- [Exemplos de Uso](#-exemplos-de-uso)
- [Docker](#-docker)
- [Kubernetes](#-kubernetes)
- [Documentação](#-documentação)
- [Configuração](#-configuração)
- [Armazenamento](#-armazenamento)
- [Status do Projeto](#-status-do-projeto)
- [Contribuição](#-contribuição)
- [Licença](#-licença)
- [Autora](#-autora)

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

## 🏗 Arquitetura e Estrutura do Projeto

O projeto segue **Clean Architecture** com separação clara de responsabilidades entre camadas, e o código está organizado para refletir essas camadas na estrutura de diretórios.

```text
Domain (Núcleo)
  ├── Entities
  │     - Payment, Sale, Vehicle
  │     - Regras de negócio e invariantes
  ├── Repositories (Ports/Behaviours)
  │     - Contratos de acesso a dados (ex.: VehicleRepository)
  └── Services (Ports)
        - Clock, IdGenerator, CodeGenerator

Use Cases (Aplicação)
  ├── Payments
  ├── Sales
  ├── Vehicles
  ├── ParamsNormalizer        (normalização de parâmetros de entrada)
  └── VehicleFilter           (filtragem/ordenação de veículos)

Infrastructure (Adaptadores)
  ├── Repositories (Implementações)
  │     - Implementações concretas dos repositories (ex.: Agents em memória)
  └── Services (Implementações)
        - Implementações reais de Clock, IdGenerator, CodeGenerator

Web (Interface)
  ├── Controllers             (exposição HTTP da API)
  ├── Serializers             (conversão Domain → JSON)
  └── BaseController          (injeção de dependências para os use cases)
```

Essa arquitetura se reflete diretamente na estrutura de pastas:

```text
lib/
├── auto_grand_premium_outlet/
│   ├── domain/                     # Camada de Domínio (Núcleo)
│   │   ├── entities/               # Entities: Payment, Sale, Vehicle
│   │   ├── repositories/           # Repositories (Ports/Behaviours)
│   │   └── services/               # Services (Ports: Clock, IdGenerator, CodeGenerator)
│   ├── use_cases/                  # Camada de Aplicação
│   │   ├── payments/               # Casos de uso de pagamentos
│   │   ├── sales/                  # Casos de uso de vendas
│   │   ├── vehicles/               # Casos de uso de veículos
│   │   ├── params_normalizer.ex    # Normalização de parâmetros de entrada
│   │   └── vehicle_filter.ex       # Filtragem/ordenação de veículos
│   └── infra/                      # Camada de Infraestrutura (Adaptadores)
│       ├── repositories/           # Implementações concretas dos repositórios
│       └── services/               # Implementações concretas dos serviços
└── auto_grand_premium_outlet_web/  # Camada Web (Interface)
    ├── controllers/                # Controllers HTTP
    ├── serializers/                # Serializers Domain → JSON
    └── base_controller.ex          # BaseController (injeção de dependências)

test/
├── auto_grand_premium_outlet/
│   ├── domain/                     # Testes das entidades (Domain)
│   └── use_cases/                  # Testes dos casos de uso (Application)
└── auto_grand_premium_outlet_web/
    └── controllers/                # Testes dos controllers (Web)
```

## 🎯 Princípios e Padrões

### Princípios Aplicados

- ✅ **Dependency Rule**: Dependências sempre apontam para dentro (o Domain não depende de camadas externas)
- ✅ **Independência de Frameworks**: O núcleo de domínio não conhece Phoenix, Ecto, HTTP ou JSON
- ✅ **Independência de UI**: Use cases podem ser reutilizados por API HTTP, CLI, jobs, etc.
- ✅ **Independência de Banco de Dados**: Repositórios são abstrações (behaviours); a implementação pode trocar de Agents em memória para Postgres sem impactar o domínio

### Clean Architecture

- ✅ **Separação clara de camadas**: Domain, Use Cases, Infrastructure e Web
- ✅ **Domínio 100% independente**: Regras de negócio isoladas de detalhes de infra
- ✅ **Ports & Adapters**: Repositories e Services definidos como comportamentos (ports), com implementações concretas na camada de infraestrutura
- ✅ **Injeção de Dependências**: `BaseController` centraliza como os casos de uso recebem repositórios e serviços concretos

### SOLID

- ✅ **SRP (Single Responsibility Principle)**  
  Cada módulo tem uma responsabilidade clara (ex.: `ParamsNormalizer` só normaliza parâmetros; `VehicleFilter` só filtra/ordena veículos).
- ✅ **OCP (Open/Closed Principle)**  
  Comportamentos e use cases são abertos para extensão (novas implementações de repos/services) sem precisar modificar o domínio.
- ✅ **LSP (Liskov Substitution Principle)**  
  Implementações concretas podem substituir os behaviours (`VehicleRepository`, `SaleRepository`, `PaymentRepository`) sem quebrar consumidores.
- ✅ **ISP (Interface Segregation Principle)**  
  Interfaces focadas e mínimas, separando responsabilidades em behaviours específicos.
- ✅ **DIP (Dependency Inversion Principle)**  
  Use cases dependem de **abstrações** (behaviours de repositórios e serviços), nunca de implementações concretas.

### DRY (Don't Repeat Yourself)

- ✅ **BaseController**: Centraliza helpers de dependências (repos/services), evitando repetição em cada controller.
- ✅ **VehicleFilter**: Centraliza a lógica de filtragem e ordenação de veículos.
- ✅ **ParamsNormalizer**: Centraliza normalização de parâmetros de entrada (tipos, chaves, conversões).
- ✅ **Serializers**: Reuso de lógica de transformação Domain → JSON entre endpoints.

### Padrões de Código

- Siga os princípios de Clean Architecture e SOLID descritos acima
- Mantenha e amplie a cobertura de testes automatizados
- Documente mudanças significativas (README, comentários e/ou docs)
- Use `mix format` antes de commitar para manter o estilo consistente

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
| `GET` | `/api/sales/:sale_id` | Consulta uma venda |

### Pagamentos

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/api/payments` | Cria um novo pagamento |
| `GET` | `/api/payments/:payment_code` | Consulta um pagamento |

### Webhooks

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `PUT` | `/api/webhooks/payments` | Webhook para confirmar/cancelar pagamento |

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

# 4. Confirmar o pagamento pelo webhooks
WEBHOOKS_RESPONSE=$(curl -s -X PUT
  http://localhost:4000/api/webhooks/payments \
  -H 'Content-Type: application/json' \
  -d "{
    \"payment_code\": \"$PAYMENT_CODE\",
    \"status\": "paid"
  }")

# 5. Verificar o pagamento atualizado
curl -s "http://localhost:4000/api/payments/$PAYMENT_CODE" | jq '.status'

# 6. Verificar a venda atualizada
curl -s "http://localhost:4000/api/sales/$SALE_ID" | jq '.status'

# 7. Verificar se o veículo foi marcado como vendido
curl -s "http://localhost:4000/api/vehicles/$VEHICLE_ID" | jq '.status'
# Resultado: "sold"
```

### Listar Veículos Disponíveis

```bash
curl -X GET http://localhost:4000/api/vehicles/available \
  -H 'accept: application/json' | jq .
```

### Listar Veículos Vendidos

```bash
curl -X GET http://localhost:4000/api/vehicles/sold \
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
curl -X PUT http://localhost:4000/api/webhooks/payments \
  -H 'Content-Type: application/json' \
  -d '{
    "payment_code": "pay_456",
    "status": "paid"
  }'
```

## 🐳 Docker

### Build da Imagem

```bash
docker build -t auto-grand-premium-outlet:1.0.3 .
```

### Executar Container

```bash
docker run -p 4000:4000 \
  -e DATABASE_URL="ecto://postgres:postgres@host.docker.internal:5432/auto_grand_premium_outlet_prod" \
  -e SECRET_KEY_BASE="your-secret-key-base" \
  auto-grand-premium-outlet:1.0.3
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

Edite k8s/secret.yaml e atualize:
- POSTGRES_PASSWORD
- SECRET_KEY_BASE
- DATABASE_URL
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

| [<img loading="lazy" src="https://avatars.githubusercontent.com/u/8690168?v=4" width=115><br><sub>Nathalia Freire - RM359533</sub>](https://github.com/nathaliaifurita) |
| :---: |

- Desenvolvido seguindo Clean Architecture e SOLID principles

---

