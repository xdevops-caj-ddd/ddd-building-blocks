# Cargo Tracker应用

## 微服务架构

Cargo Tracker的微服务架构如下：
![cargo-tracker-ms](../../ddd-assets/img/cargo-tracker-ms.jpeg)

上下文包括：
- Booking上下文
- Tracking上下文
- Routing上下文
- Handling上下文


### Booking上下文
Booking上下文：
- 提供的接口包括：
    - Book Cargo (Command)
    - Assign Route to Cargo (Command)
    - Cargo Details (Query)
- 调用其他上下文提供的接口：
    - Routing上下文提供的Get ltinerary for Route (Query)
- 发布的事件包括：
    - Cargo Booked
    - Cargo Routed
- 订阅的事件包括：
    - Cargo Handled

### Tracking上下文
Tracking上下文：
- 提供的接口包括：
    - Assign Tracker to Cargo (Command)
    - Track Cargo (Query)
- 订阅的事件包括：
    - Cargo Routed
    - Cargo Handled

### Routing上下文
Routing上下文：
- 提供的接口包括：
    - Maintain Voyages (Command)
    - Get ltinerary for Route (Query)
- 订阅的事件包括：
    - Cargo Routed
    - Cargo Handled

### Handling上下文
Handling上下文：
- 提供的接口包括：
    - Register Handling Activity (Command)
    - Handling History Details (Query)
- 发布的事件包括：
    - Cargo Handled

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

## 上下文包结构

以Booking上下文为例，包结构如下：
```bash
├── BookingmsApplication.java # Spring Boot应用程序入口
├── application # 应用层
├── domain # 领域层
├── infrastructure # 基础设施层，出站适配器
└── interfaces # 接口，入站适配器
```

### 接口

接口的职责包括：
- 包含该上下文的所有**入站接口**，这些接口按照通信协议分类，比如`rest`表示REST API
- 订阅和处理其他上下文发布的事件，比如`events`或`eventhandlers`表示订阅和处理事件
- 接口数据转换，比如`dto`表示DTO对象，而`transform`表示数据转换类

Booking上下文接口的包结构如下：
```bash
interfaces # 接口 / 入站适配器
└── rest # REST API
    ├── CargoBookingController.java # 定义REST API的Spring Boot RestController
    ├── dto
    │   └── BookCargoResource.java # REST API的API Resource
    └── transform
        └── BookCargoCommandDTOAssembler.java # 接口数据转换类
```

#### REST API
以Booking上下文为例，该上下文提供的REST API包括：
- 命令接口（改变状态的请求）
    - Book Cargo Command
    - Assign Route to Cargo Command
- 查询接口（获取状态的请求）
    - Retrieve Cargo Booking Details
    - List all Cargos

这些REST API定义在`interfaces/rest/CargoBookingController.java`类中。
该Controller类中使用了`CargoBookingCommandService`类和`CargoBookingQueryService`类，分别对应命令操作和查询操作。

#### 接口数据转换

参见上面Booking上下文接口的包结构。

在`interfaces/dto`包下，定义REST API的API Resources （就是一个普通的Data Transfer Object）。

在`interfaces/transform`包下，定义数据转换类，将REST API的API Resource或Event Data转换成Command/Query Service所需要的模型。

> 数据转换也可以使用专门的[Java Mapping Frameworks](https://stackoverflow.com/questions/1432764/any-tool-for-java-object-to-object-mapping)，而不需要为每个每个类都写一个数据转换类。


#### 事件处理

另外`interfaces/events`下的EventHandler类用来订阅和处理相应的Domain Event。

以Tracking上下文为例，Tracking上下文订阅了`CargoRouted`的Domain Event，因此`interfaces/events/CargoRoutedEventHandler.java`类用来订阅和处理`CargoRoutedEvent`。

Tracking上下文的接口的包结构：
```bash
interfaces
└── events
    └── CargoRoutedEventHandler.java
```

### 应用层

应用层的职责包括：
- 调度命令（改变状态）应用服务
- 调度查询（获取状态）应用服务
- 为领域模型提供公共切面功能，比如日志、安全、指标
- 标注其他上下文 ？

Booking上下文的应用层的包结构如下：
```bash
application # 应用层 / 应用服务
└── internal
    ├── commandservices # 命令（改变状态）的应用服务，被REST API的Controller类调用
    │   └── CargoBookingCommandService.java
    ├── outboundservices # 出站服务
    │   ├── CargoEventPublisherService.java # 发布事件
    │   └── acl
    │       └── ExternalCargoRoutingService.java
    └── queryservices # 查询（获取状态）的应用服务，被REST API的Controller类调用
        └── CargoBookingQueryService.java
```

### 领域层

领域层主要包括：
- 领域模型
  - 聚合
    - 聚合标识符
    - 聚合根
  - 实体
  - 值对象
- 领域模型操作
  - 命令（改变状态）
  - 查询（获取状态）
  - 事件


Booking上下文的领域层的包结构如下：
```bash
domain # 领域层
└── model # 领域模型
    ├── aggregates # 聚合
    │   ├── BookingId.java # 聚合标识符
    │   └── Cargo.java # 聚合根（Aggregate Root / Root Entity）
    ├── commands # 领域模型操作-命令
    │   ├── BookCargoCommand.java
    │   └── RouteCargoCommand.java
    ├── entities # 实体
    │   └── Location.java
    └── valueobjects # 值对象
        ├── BookingAmount.java
        ├── CargoHandlingActivity.java
        ├── CargoItinerary.java
        ├── Delivery.java
        ├── LastCargoHandledEvent.java
        ├── Leg.java
        ├── RouteSpecification.java
        ├── RoutingStatus.java
        ├── TransportStatus.java
        └── Voyage.java
```

### 基础设施层

基础设施层的主要职责：
- 改变状态或获取状态：写入数据到数据库，或从数据库中读取数据
- 传输状态变化：发布事件到消息代理（Message Broker）
- 应用程序的特定配置

Booking上下文的领域层的包结构如下：

```bash
infrastructure # 基础设施层 / 出站适配器
├── brokers # 发布事件到消息代理
│   └── rabbitmq # 以RabbitMQ为例
│       └── CargoEventSource.java
└── repositories # 负责数据库读写的存储库（Repository）
    └── CargoRepository.java
```


## 控制流

上下文的控制流：
- 应用程序入口：`BookingmsApplication.java`
- 提供的命令（改变状态）的接口：
  ```bash
  # REST API -> 命令应用服务 -> 数据库存储库
  CargoBookingController -> CargoBookingCommandService -> CargoRepository
  ```
- 提供的查询（获取状态）的接口：
  ```bash
  # REST API -> 查询应用服务 -> 数据库存储库
  CargoBookingController -> CargoBookingQueryService -> CargoRepository
  ```
- 事件订阅与处理流程：
  TBC
- 事件发布流程：
  ```bash
  CargoBookingController -> CargoBookingCommandService -> TBC
  ```

## 领域模型实现

领域模型包括：
- 聚合
- 实体
- 值对象

### 聚合实现

聚合包括：
- 聚合根
- 聚合标识符


#### 聚合根

以Booking上下文的Cargo聚合根类为例。

```java
package com.practicalddd.cargotracker.bookingms.domain.model.aggregates;
import javax.persistence.*;
@Entity //JPA Entity Marker
public class Cargo {

}
```

> 示例代码中将Cargo类和直接和JPA Entity注解绑定起来。
> 关于“将领域对象类和JPA Entity注解绑定，还是应该分离”存在争议，参见：https://stackoverflow.com/questions/46227697/should-jpa-entities-and-ddd-entities-be-the-same-classes
> 绑定的好处：不用专门定义JPA Entity类，也不需要Java bean mapping；绑定的坏处：会将业务数据、业务逻辑、表实体都放在同一个类中，持久化的注解会污染领域对象类。
> 分离的好处：将表实体放在专门的JPA Entity类中，领域对象类只需要关注业务数据和业务逻辑；分离的坏处：需要专门定义对应的JPA Entity类，并且需要作Java Bean Mapping。
> 个人建议分离，以获得更好的代码可读性。

#### 聚合标识符

以BookingId类为例：

```java
package com.practicalddd.cargotracker.bookingms.domain.model.aggregates;
import javax.persistence.*;
import java.io.Serializable;
/**
* Business Key Identifier for the Cargo Aggregate
*/
@Embeddable
public class BookingId implements Serializable {
    @Column(name="booking_id")
    private String bookingId;
    public BookingId(){}
    public BookingId(String bookingId){this.bookingId = bookingId;}
    public String getBookingId(){return this.bookingId;}
}
```

> 示例代码中将BookingId类和直接和JPA Entity注解绑定起来。关于“绑定或分离”的争议参见上面。
> 另外是否有必要定义一个专门的聚合标识符类，取决于聚合标识符是否会参加业务逻辑判断，如果有，则有必要定一个专门的类。



## References
- https://github.com/Apress/practical-ddd-in-enterprise-java/tree/master/Chapter5

