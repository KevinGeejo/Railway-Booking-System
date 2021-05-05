# 设计报告 1: 订票系统的数据库关系模式

<h2>报告大纲</h2>

[toc]

## 描述实体联系：ER 图

分析该数据库需要囊括的信息，我们得到以下的实体-联系图：

![ER-graph-er-5.3](readme.assets/ER-graph-er-5.3.png)

该图中仍然具有一些明显的冗余部分，故而需要通过范式细化去冗余。

## 范式细化：ER 图的修正

为了尽量减少数据冗余，我们需要对形成的关系模型进行范式分析、模式分解。在本项目中，具体的目标是使实体联系满足 BCNF，为此需要检查并消除关系模型中的：

- 部分依赖
- 非键传递依赖
- 对于键属性的传递依赖

当以上 3 种依赖都消除时，该关系模型即满足 BCNF.

下面对各个主体依次进行有关范式的判断与分析。

### User

**候选键**：`IdentityNumber` , `Phone`.

**非键属性**：`Name` , `Credit` , `Username`.

**依赖关系**:

```
(1) IdentityNumber -> Name Phone Credit Username
(2) Phone -> Name IdentityNumber Credit Username
```

**范式判断**：User 满足 BCNF.

### Order

**候选键**：`Oid` , `Tid` , `IdentityNumber` .

**非键属性**：`Day` , `Time` , `TotalPrice` , `SeatType` , `OrderStatus` , `DepartureStation` , `ArrivalStation` .

**依赖关系**：

```
(1) Oid -> Tid IdentityNumber Day Time TotalPrice SeatType OrderStatus DepartureStation ArrivalStation
(2) Tid IdentityNumber -> Oid Day Time TotalPrice SeatType OrderStatus DepartureStation ArrivalStation
(3) Tid DepatureStation ArrivalStation SeatType -> TotalPrice
```

**范式判断**：依赖关系 (3) 为非键传递依赖，因此 Order 满足 2NF.

**消除依赖**：删除 TotalPrice 项，因为价格可以通过连接 TrainItem 表查找得到。

### Station

**候选键**：` Sid` , `StationName` , `City `.

**非键属性**：无。

**依赖关系**：

```
(1) Sid -> StationName City
(2) StationName City ->Sid
```

**范式判断**：Station 满足 BCNF.

此外，在分析时我们发现老师提供的车站序号 `Sid` 在真实计算过程中是多余的，于是将该属性删除。

### TrainItem

**候选键**：`Tid` , `StartStation` , `ArrivalStation`.

**非键属性**：`ArrivalTime` , `DepartureTime` , `HardSealPrice` , `SoftSeatPrice` , `HardSleeperUPrice` , `HardSleeperMprice` , `HardSleeperLPrice` , `SoftSleeperUPrice` , `SoftSleeperLPrice`.

**依赖关系**：

```
(1) Tid StartStation ArrivalStation -> ArrivalTime DepartureTime HardSealPrice SoftSeatPrice HardSleeperUPrice HardSleeperMprice HardSleeperLPrice SoftSleeperUPrice SoftSleeperLPrice
(2) Tid ArrivalStation -> ArrivalTime DepartureTime HardSealPrice SoftSeatPrice HardSleeperUPrice HardSleeperMprice HardSleeperLPrice SoftSleeperUPrice SoftSleeperLPrice
(3) Tid -> StartStation
```

**范式判断**：

- 依赖关系 (2) 是部份依赖，依赖关系 (3) 是对于键属性的函数依赖；由前者即知 TrainItem 满足 1NF.

**消除依赖**：

1. 将 Table TrainIterm 分解为 $\rm \pi_{(Tid,StartStation)}TrainItem$ 和 $\rm \pi_{(Tid, AS, AT, DT, HSP, SSP, HSUP, HSMP, HSLP, SSUP, SSLP)}Train Item$；
2. 前一个表作为一个新主体被命名为 `TrainStartStation` ，后一个表仅删除 `StartStation` 项，并保持原名 `TrainIterm` ，两表以车次的起始站相联系；
3. 这个分解为无损分解，分解后两表均满足 BCNF.

### 修正后的 ER 图

对原本的 ER 图依次进行以下操作:

1. 对关系模式进行范式细化;
2. 为了增加可读性, 微调了一些属性和联系的名称;
3. 原图缺少始发站发车时间, 在 `TrainStartStation` 实体中添加 `StartTime` 这一属性, 再度进行范式细化等判断;

得到如下的 ER 图:

![ER-graph-er-after-chk-5.3](readme.assets/ER-graph-er-after-chk-5.3.png)

## 关系模式

## 成员分工

<!-- GitHub版本不要写学号信息! 只写在GitHub公开过的信息! -->

- [Xuzhou Zheng](https://github.com/chuan-325): ER 图修订
- [Wenyi Fu](https://github.com/FuWenyi): ER 图，范式细化
- [Zixuan Lu](https://github.com/birepeople): 关系模式图
