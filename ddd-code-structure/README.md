# DDD代码结构

## DDD架构

### DDD分层架构

传统的DDD分层架构如下：

![ddd-layered](../ddd-assets/img/ddd-layered.jpeg)

分层包括：
- UI Layer
- Application Layer
- Domain Layer
- Infrastructure Layer

### 六边形架构

六边形架构（也称端口/适配器架构）如下：

![ddd-hexagonal](../ddd-assets/img/ddd-hexagonal.jpeg)

分层包括：
- Inbound Adaptor
- Outbound Adaptors
- Application Service
- Domain Model

### DDD代码结构

融合DDD分层架构与六边形架构，定义DDD代码结构如下：
- `interfaces` - Inbound Adaptor
- `applicaiton` - Application Service / Application Layer
- `domain` - Domain Model / Domain Layer
- `infrastructure` - Outbound Adaptors / Infrastructure Layer



## DDD单体应用的代码结构

Bounded Context作为单体应用的一个Module。

代码结构:
```bash
├── module
│   ├── application
│   │   ├── internal
│   │   │   ├── commands
│   │   │   ├── events
│   │   │   └── queries
│   │   ├── saga
│   │   └── transform
│   ├── domain
│   │   ├── aggregates
│   │   └── model
│   │       ├── entities
│   │       └── valueobjects
│   ├── infrastructure
│   │   ├── events
│   │   ├── messaging
│   │   └── persistence
│   └── interfaces
│       ├── file
│       ├── rest
│       ├── socket
│       └── web
└── shared
    └── infrastructure
        └── events
```

生成代码结构命令：
```bash
cd monolith
bash init_module_structure.sh
```

## DDD微服务应用的代码结构

Bounded Context为一个单独的Microservice。

代码结构:
```bash
├── application
│   └── internal
│       ├── commandservices
│       ├── outboundservices
│       └── queryservices
├── domain
│   └── model
│       ├── aggregates
│       ├── commands
│       ├── entities
│       ├── events
│       └── valueobjects
├── infrastructure
│   ├── brokers
│   ├── configuration
│   └── repositories
└── interfaces
    ├── eventhandlers
    ├── rest
    └── transform
```

生成代码结构命令：
```bash
cd microservices
bash bash init_microservice_structure.sh
```

## References

- [DDD, Hexagonal, Onion, Clean, CQRS, … How I put it all together](https://herbertograca.com/2017/11/16/explicit-architecture-01-ddd-hexagonal-onion-clean-cqrs-how-i-put-it-all-together/)