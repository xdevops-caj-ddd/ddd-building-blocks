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
bookingms # Booking上下文
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

在Spring Boot应用中，命令应用服务和查询应用服务对应Spring Boot的`@Service`注解。

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
  # REST API -> 命令应用服务 -> 聚合的命令处理程序 -> 数据库存储库操作
  CargoBookingController -> CargoBookingCommandService -> Cargo -> CargoRepository
  ```
- 提供的查询（获取状态）的接口：
  ```bash
  # REST API -> 查询应用服务 -> 聚合的查询处理程序 -> 数据库存储库操作
  CargoBookingController -> CargoBookingQueryService -> Cargo -> CargoRepository
  ```
- 事件订阅与处理流程：
  TBC
- 事件发布流程：
  ```bash
  CargoBookingController -> CargoBookingCommandService -> TBC
  ```

Booking上下文“预定货物”的时序图：
![book-cargo-sequence](../../ddd-assets/img/book-cargo-sequence.jpeg)

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

#### 领域丰富度

聚合类应该包括：
- 业务属性
- 业务方法

反模式：
- 贫血模型，领域对象类蜕变成POJO，只有业务属性，没有业务方法
- 使用技术术语，而不是业务术语

在聚合类中应该使用**业务术语**，而不是技术术语来表达。

Cargo聚合的领域模型如下：
![cargo_aggregate_model](../../ddd-assets/img/cargo_aggregate_model.jpeg)

上述领域模型中，只画出了业务属性，没有画出业务方法。

Cargo聚合中的业务概念：
- `Origin Locaiton` - 货物的源地址
- `Booking Amount` - 货物的订舱金额
- `Routing Specification` - 路线规格（源地址、目的地、到达目的地截止日期）
- `Itinerary` - 根据路线规格分配的货物行程
  - `Leg` - 行程由一个或多个航段组成
- `Delivery Progress` - 货物的交付进度
  - `Routing Status` - 路线状态
  - `Transport Status` - 运输状态
  - `Current Voyage of the cargo` - 当前航程
  - `Last Known Location of the cargo` - 获取的最后已知位置
  - `Next Expected Activity` - 下一个预期活动
  - `The Last Activity that occurred on the cargo` - 货物上发生的最后活动

Cargo聚合类如下：
```java
package com.practicalddd.cargotracker.bookingms.domain.model.aggregates;
import javax.persistence.*;
import com.practicalddd.cargotracker.bookingms.domain.model.entities.*;
import com.practicalddd.cargotracker.bookingms.domain.model.valueobjects.*;
@Entity
public class Cargo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Embedded
    private BookingId bookingId; // Aggregate Identifier
    @Embedded
    private BookingAmount bookingAmount; //Booking Amount
    @Embedded
    private Location origin; //Origin Location of the Cargo
    @Embedded
    private RouteSpecification routeSpecification; //Route Specification of
    the Cargo
    @Embedded
    private CargoItinerary itinerary; //Itinerary Assigned to the Cargo
    @Embedded
    private Delivery delivery; // Checks the delivery progress of the cargo
    against the actual Route Specification and Itinerary
}
```

可以看到Cargo聚合类，就是对Cargo聚合领域模型（UML类图）的实现。

聚合与其依赖类的生命周期：
聚合的依赖类被建模为实体对象或值对象。
- 限界上下⽂中的**实体对象**具有⾃⼰的 **⾝份**，但始终存在于根聚合中，也就是说，它们**不能独⽴存在**，并且在聚合的整个⽣命周期中它们永远**不会改变**。
- **值对象**没有⾃⼰的⾝份，并且可以在聚合的任何实例中轻松**替换**。


### 领域模型操作

领域模型操作包括：
- 内部操作：
    - 命令（改变状态）
    - 查询（获取状态）
- 外部操作
    - 事件（传播状态）


#### 命令

命令用来改变有界上下文中聚合的状态。

实现命令的步骤：
- 识别和实现命令 （Command）
- 识别和实现命令处理程序（Command Handlers）

命令的识别围绕着识别影响聚合状态的操作。
以Booking上下文为例，有以下操作会改变聚合的状态：
- Book a Cargo 预定货物
- Route a Cargo  运送货物

命令用普通的POJO类实现。
以BookCargoCommand为例：
```java
package com.practicalddd.cargotracker.bookingms.domain.model.commands;

import java.util.Date;

/**
 * Book Cargo Command class
 */
public class BookCargoCommand {

    private String bookingId;
    private int bookingAmount;
    private String originLocation;
    private String destLocation;
    private Date destArrivalDeadline;
}
```

每个命令都对应一个命令处理程序。命令处理程序的目的是处理输入的命令，并设置聚合的状态。
命令处理程序是在领域模型中修改聚合状态的**唯一地方**。
命令处理程序通常对应聚合类的业务方法。
在Cargo聚合中：
- Book a Cargo命令对应的命令处理程序是`Cargo(BookCargoCommand bookCargoCommand)`构造方法
- Route a Cargo命令对应的命令处理程序是`assignToRoute(RouteCargoCommand routeCargoCommand)`方法

> 可以使用Lombok来简化这一类POJO的代码？

Cargo聚合的命令处理程序类图：
![cargo_cmd_handlers](../../ddd-assets/img/cargo_cmd_handlers.jpeg)


#### 查询

查询负责向外提供查询上下文中聚合的状态。

查询处理程序是聚合中的业务方法。
但是实际编码中，一般是查询应用服务直接调用对应的数据库存储库的方法来查询，因为再通过聚合的查询处理程序中转一道，好像不是很需要。

Booking上下文的根据BookingId查找Cargo的控制流：
```bash
# REST API -> 查询应用服务 -> 数据库存储库
CargoBookingController.findByBookingId() -> CargoBookingQueryService.find() -> CargoRepository.findByBookingId()
```


另外的例子：
以列表导出为例，聚合不关心导出的文件格式，而是在查询应用服务中需要关心。


### 领域事件

事件驱动架构实现的四个阶段：
- 事件发布者：
  - 注册需要从限界上下文中引发的领域事件 （在聚合的命令处理程序中）
  - 引发需要从限界上下文发布的领域事件 （在应用层的出站服务中）
  - 发布从限界上下文引发的事件 （在应用层的出站服务中）
- 事件接收者
  - 订阅已从其他限界上下文发布的事件 （在接口层的事件处理程序中）

#### 事件注册

使用Spring Data的`AbstractAggregateRoot<T>.registerEvent() `注册事件 ?

在Cargo聚合的命令处理程序业务方法的最后注册相应事件：
```java
public Cargo(BookCargoCommand bookCargoCommand){
    //other codes

    //Add this domain event which needs to be fired when the new cargo is saved
    addDomainEvent(new
            CargoBookedEvent(
                    new CargoBookedEventData(bookingId.getBookingId())));
}

public void assignToRoute(RouteCargoCommand routeCargoCommand) {
    //other codes

    //Add this domain event which needs to be fired when the new cargo is saved
    addDomainEvent(new
            CargoRoutedEvent(
            new CargoRoutedEventData(bookingId.getBookingId())));
}

public void addDomainEvent(Object event){
    registerEvent(event);
}
```

对应的领域事件类：
- CargoBookedEvent
- CargoBookedEventData
- CargoRoutedEvent
- CargoRoutedEventData


这些Event和EventData类都放在根目录下的`shareddomain/events`目录下。

```bash
shareddomain # 共享领域模型？说好的shared nothing架构呢？
└── events
    ├── CargoBookedEvent.java
    ├── CargoBookedEventData.java
    ├── CargoRoutedEvent.java
    └── CargoRoutedEventData.java
```

## 领域模型服务

领域模型服务的三种类型：
- 入站服务 （外部消费者的入口）
- 出站服务 （与外部消费者交互的入口）
- 应用服务 （充当领域模型、入站服务和出站服务的门面层）

领域模型服务示意图：
![domain-model-services](../../ddd-assets/img/domain-model-services.jpeg)

### 入站服务

入站服务的两种类型：
- 基于REST的API层（使用Spring Boot的@RestController）
- 事件处理层（基于Spring Cloud Stream）

#### REST API

REST API实现类图：
![rest-api-class](../../ddd-assets/img/rest-api-class.jpeg)

说明：
- Controller类：
- API Resource类：
- Java Bean转换器类：
- Command类：
- 命令应用服务类：



## References
- https://github.com/Apress/practical-ddd-in-enterprise-java/tree/master/Chapter5

