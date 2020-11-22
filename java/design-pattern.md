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

## 单例模式

> 什么是单例



## 工厂方法模式

