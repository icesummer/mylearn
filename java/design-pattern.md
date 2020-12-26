# 设计模式

## 七大原则

> 单一职责

> 接口隔离原则

- 依赖的接口的实现不应该有不需要的接口及实现方法

> 依赖倒转原则

* 中心思想是面向接口编程
* 高层模块不应该依赖底层模块，都应依赖其抽象
* 抽象不应依赖细节，细节应原来抽象
* 抽象和接口类的目的是定义好规范，不涉及具体的操作

```javascript
/**接口定义*/
interface IOpenAndClose{
    public void open(ITV tv);
} 
interface ITV{
    public void play();
}

// ITV一个具体实现：
class SmartTV implements ITV{
    public void play(){
        sout("打开智能电视观看新闻联播！");
    }
}
```



```java
/*通过接口依赖实现传递*/
class OpenAndClose implements IOpenAndClose{
    public void open(ITV tv){
        tv.play();
    }
}
public class testType {
    public static void main(String[] args){
        ITV tv = new SmartTV();
        IOpenAndCLose openAndClose = new OpenAndClose();
        openAndClose.open(tv);
    }
}
```

```java
/*通过构造方法实现传递*/
class OpenAndClose implements IOpenAndClose{
    ITV tv;
    public OpenAndClose(ITV tv){
        this.tv = tv;
    }
    public void open(){
        tv.play();
    }
}
public class testType {
    public static void main(String[] args){
        ITV tv = new SmartTV();
        IOpenAndCLose openAndClose = new OpenAndClose(tv);
        openAndClose.open();
    }
}
```


```java
/*通过setter方法实现传递*/
class OpenAndClose implements IOpenAndClose{
    ITV tv;
    public void setTv(ITV tv){
        this.tv = tv;
    }
    public void open(){
        tv.play();
    }
}

public class testType {
    public static void main(String[] args){
        ITV tv = new SmartTV();
        IOpenAndCLose openAndClose = new OpenAndClose();
        openAndClose.setTv(tv);
        openAndClose.open();
    }
}
```



> 里氏替换原则

- 如何正确的使用继承？：子类尽量不去重写父类已实现的方法

> 开闭原则

- 多扩展开放，对修改(使用方)关闭（当有新功能是进行扩展实现，但不是通过修改已有的代码实现）

```java
/*范例*/
public class Ocp{
    public static void main(String[] args){
        GraphicEditor ge = new GraphicEditor();
        ge.draw(new Rectangle());// 绘制矩形
        ge.draw(new Triangle());// 绘制三角形
        // 新增其它图形类不用修改现有代码 如
        ge.draw(new Circle());// 绘制圆形
        
    }
}

class GraphicEditor{
    public void draw(Shape shape){
        sout("开始绘图");
        shape.draw();
        sout("结束绘图");
    }
    
}
abstract class Shape{
    int m_type;
    abstract void draw();
}
class Rectangle extends Shape{
    Rectangle(){
        super.m_type=1;
    }
    public void draw(){
        sout(" 绘制矩形 类型编号："+m_type);
    }
}
class Triangle extends Shape{
    Triangle(){
        super.m_type=3;
    }
    public void draw(){
        sout(" 绘制三角形 类型编号："+m_type);
    }
}

```



> 迪米特法则

- 一个对象应对依赖的其它对象有最少的了解- （松耦合）
- 依赖类的实现尽量内部化，对外提供统一的public

> 合成复用原则

## 1.单例模式

> 什么是单例



##  2.策略模式

> 策略模式封装了针对同一种动作有多个不同的策略实现
>
> 如：比较大小：可以按照重量，体积，高度等不同的策略比较；
>
> 编写思路：先用接口抽象策略方法，具体实现类定义不同的策略

* 优点是**便于扩展**：可以基于接口扩展新的多种策略，同时不影响之前的代码





## 3.0简单工厂

> 任何可以产生对象的方法或类，都可以称之为工厂
>
> 所以单例也是一种工厂

* 1.简单工厂就是把new对象交给工厂来实现，new对象的权限只提供给工厂类；
* 2.同时可以在工厂创建对象前后加上权限等控制处理

> 为什么还需要工厂(有了new了)
>
> * 灵活控制成产过程；权限，修饰，日志处理

```java
/**
 * 简单工厂工厂类
 */
public class SimpleVehicleFactory {
    // 生产轿车
    static Car createCar(){
        sout("日志操作...");
        return new Car();
    }
    // 生产飞机
    static AirPlane createAirPlane(){
        sout("日志操作...");
        return new AirPlane();
    }
}
```

```java
public class Car implements Vehicle{
    public void go (){
        System.out.println("go wuwuwwuwuwuwu... ");
    }
}
```

```java
public static void main(String[] args) {
    Vehicle car = SimpleVehicleFactory.createCar();
    Vehicle airplane = SimpleVehicleFactory.createAirPlane();
}
```



## 3.工厂方法

> 简单工厂的扩展性不好，将简单工厂优化，具体的类对象有自己的工厂类
>
> 即一个工厂只生产一种产品
>
> * 产品维度上扩展方便

```java
public class CarFactory {
    public Vehicle create(){
        sout("日志操作...");
        return new Car();
    }
}
```

```java
public static void main(String[] args) {
    Vehicle car = new CarFactory().create();
    Vehicle air = new AirPlaneFactory().create();
}
```



## 4.抽象工厂

> 将每个产品对应一个工厂是工厂方法，
>
> 当有一族产品时就需要**对工厂进行抽象**<对应抽象产品>，
>
> ​	抽象工厂中定义能创建那些抽象产品
>
> 并每个族都建立抽象工厂实现类<对应具体产品>，
>
> * 产品族上扩展方便

```java
/**抽象工厂（一年四季的吃穿住行抽象工厂）*/
public abstract class AbstractFactory {
    abstract Food createFood();
    abstract Clothes createClothes();
    abstract House createHouse();
}
```

```java
/**具体工厂实现类1 单季具体工厂*/
public class SummerFactory extends AbstractFactory{
    @Override
    Food createFood() {
        return new SummerFood();
    }
    @Override
    Clothes createClothes() {
        return new SummerClothes();
    }

    @Override
    House createHouse() {
        return null;
    }
}
/**具体工厂实现类2冬季工厂*/
public class WinterFactory extends AbstractFactory{
    @Override
    Food createFood() {
        return new WinterFood();
    }

    @Override
    Clothes createClothes() {
        return new WinterClothes();
    }

    @Override
    House createHouse() {
        return null;
    }
}
```

```java
// 冬季相关bean，Food是抽象类<名词用抽象，动词用接口>
public class WinterFood extends Food{
    public void eatFood(){
        System.out.println("冬天吃温热的食物");
    }
}
public class WinterClothes extends Clothes {
    @Override
    public void warmBody() {
        System.out.println("冬装保暖");
    }
}
```

```java
// 夏季相关bean
public class SummerFood extends Food{
    public void eatFood(){
        System.out.println("夏天吃清凉的食物");
    }
}
public class SummerClothes extends Clothes {
    @Override
    public void warmBody() {
        System.out.println("夏装凉爽");
    }
}
```

* 测试

```java
public static void main(String[] args) {
    /**抽象工厂*/
    System.out.println("-------夏天工厂--------");
    AbstractFactory factory = new SummerFactory();
    Clothes clothes = factory.createClothes();
    clothes.warmBody();
    Food food = factory.createFood();
    food.eatFood();

    System.out.println("-------冬天工厂--------");
    factory = new WinterFactory();
    clothes = factory.createClothes();
    clothes.warmBody();
    food = factory.createFood();
    food.eatFood();
}
```

### Bean工厂



### Spring IOC与AOP



## (5+6)门面与调停者模式

## 5.门面facade

> 将内部复杂的调用关系封装在一起**统一提供对外的API**

## 6.调停者Mediator

>**负责协调内部调用关系的管家**  
>
>**消息中间件就是调停者模式啊**





## 7.装饰器模式

动态地将责任附加到对象上。若要扩展功能，装饰者提供了比继承更有弹性的替代方案

* 装饰类和被装饰类可以独立发展，而不会相互耦合；换句话说，Component类无需知道Decorator类，Decorator类是从外部来扩展Component类的功能，而Decorator也不用知道具体的构件

* 装饰器模式是继承关系的一个替代方案。我们看装饰类Decorator，不管装饰多少层，返回的对象还是Component(因为Decorator本身就是继承自Component的)，实现的还是is-a的关系。
* 装饰模式可以动态地扩展一个实现类的功能，比如在I/O系统中，我们直接给BufferedInputStream的构造器直接传一个InputStream就可以轻松构件一个带缓冲的输入流，如果需要扩展，我们继续“装饰”即可。

> 但是也有其自身的缺点：

　　多层的装饰是比较复杂的。这点从我使用Java I/O的类库就深有感受，我只需要单一结果的流，结果却往往需要创建多个对象，一层套一层，对于初学者来说容易让人迷惑。

> 经典：Java I/O的类库



## 8.责任链模式



## 10 Composite组合模式

### 树状模式

> ```java
> Node
>     --->Leaf
>     	---方法[print()]
>     --->Branch
>     	---List<Node> list
>     	---方法[print();addNode()]
> ```

9