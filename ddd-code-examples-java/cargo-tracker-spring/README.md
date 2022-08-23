# Cargo Tracker应用

## 微服务架构

Cargo Tracker的微服务架构如下：
![cargo-tracker-ms](../../../ddd-assets/img/cargo-tracker-ms.jpeg)

## 微服务列表

微服务包括：
- `bookingms` - 对应Booking上下文
- `handlingms` - 对应Handling上下文
- `routingms` - 对应Routing上下文
- `trackingms` - 对应Tracking上下文

每个微服务为一个Spring Boot应用，包含的依赖有：
- spring-boot-starter-web
- spring-boot-starter-data-jpa
- spring-cloud-starter-stream-rabbit

分布式事务处理：
Implement **Distributed Transactions using event choreography** with a custom implementation utilizing Spring Boot and Spring Cloud Stream

## 代码结构

### 上下文包结构

Booking上下文的包结构如下：
```bash
├── BookingmsApplication.java # Spring Boot应用程序入口
├── application # 应用层
├── domain # 领域层
├── infrastructure # 基础设施层，出站适配器
└── interfaces # 接口，入站适配器
```

### 接口

Booking上下文的的REST API包括：
- 命令接口（改变状态的请求）
    - Book Cargo Command
    - Assign Route to Cargo Command
- 查询接口（获取状态的请求）
    - Retrieve Cargo Booking Details
    - List all Cargos

这些REST API定义在`rest/CargoBookingController.java`类中。该Controller类中使用了`CargoBookingCommandService`类和`CargoBookingQueryService`类，分别对应命令操作和查询操作。

Booking上下文接口的包结构如下：
```bash
interfaces
└── rest # REST API
    ├── CargoBookingController.java # Spring Boot RestController
    ├── dto
    │   └── BookCargoResource.java
    └── transform
        └── BookCargoCommandDTOAssembler.java
```

