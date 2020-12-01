# Spring5.x

## 一、核心介绍

### 核心部分

1. **IOC(核心)**: 控制反转，把创建对象过程交给Spring管理
2. **AOP(核心)**:  面向切面，不修改源代码的情况下，进行功能的增强织入；

### 特点

1. 方便解耦，简化开发
2. 支持Aop编程
3. 方便整合其它框架
4. 方便进行事务操作
5. 降低API开发难度
6. 方便程序测试

### 官网

```sh
#https://spring.io/projects/spring-framework
#下载地址：
https://repo.spring.io/release/org/springframework/spring/
#SpringBoot下载
https://repo.spring.io/release/org/springframework/boot/spring-boot/

# Spring四个核心jar包
1. spring-beans-xx.jar
2. spring-core-xx.jar
3. spring-context-xx.jar
4. spring-expression-xx.jar
# 1个依赖jar包
5. commons-logging-1.xx.jar
```



## 二、Spring IOC容器

## 2.1 底层原理

1. IOC思想基于IOC容器完成，IOC容器就是对象工厂

   * 通过对象工厂加载配置用反射创建对象
   * 对象间调用的过程都交给Spring管理

2. Spring提供IOC容器两种实现方式

   2.1 BeanFactory 

   ​	(IOC容器的基本实现，spring内部使用的接口)

   ​	加载对象：加载配置bean文件时不创建对象，使用时创建对象

   2.2 ApplicatonContext( BeanFactory 的子接口)

   ​	面向开发者扩展使用  new ClassPathXmlApplicationContext()

   ​	加载对象：加载配置bean文件时就创建对象

   **两种方式都是通过加载配置文件 用工厂模式创建对象** 

3. ApplicatonContext实现类

   FileSystemXmlApplicationContext impl AbstractApplication

   ClassPathXmlApplicationContext impl AbstractApplication

   AnnotationConfigApplicationContext



## 2.2 IOC容器Bean管理

>  Bean管理包含：
>
> 1. Spring创建对象
> 2. Spring注入属性

>  实现方式：
>
> 1. 基于Xml的实现
> 2. 基于注解的实现



## 2.2.1 IOC操作bean管理(Xml)

### .1 基于Xml创建对象和注入属性

```xml
<!--创建对象beanId,注入属性beanId2基于DI(依赖注入)，就是注入属性-->
<!--基于set/get管理-->
<bean id="beanId" class="xxx.">
    <property name=“beanId2” ref="beanId2" | value="value11" />
</bean>
<!--或者：(需开启p命名空间约束 xmlns:p)-->
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:xsi="...."....>
    <bean id="beanId" class="xxx." p:beanId2="beanId2">
	</bean>
</beans>

<!--基于构造管理-->
<bean id="beanId" class="xxx.">
    <contructor-arg name=“prop1” value="value11" />
    <contructor-arg name=“prop2” value="value22" />
</bean>

<!--字面注入-null值注入-->
<bean id="beanId" class="xxx.">
    <property name=“address” >
        <null/>
    </property>
</bean>

<!--字面注入-转义特殊符号(<<我们是南京将>>)-->
<bean id="beanId" class="xxx.">
    <property name=“address” >
        <value>
        	<![CDATA[ <<我们是南京将>>]]
        </value>
    </property>
</bean>
<!--xml注入数组,list，set，map-->
<bean id="beanId2" class="xxx.">
    <property name=“address” >
        <array>
        	<value>我们是南京将</value>
   			<value>我是北京</value>
        </array>
    </property>
	<property name=“list” >
        <list>
        	<value>我们是南京将</value>
   			<value>我是北京</value>
        </list>
    </property>
    <property name=“sets” >
        <set>
        	<value>我们是南京将</value>
   			<value>我是北京</value>
        </set>
     </property>
	<property name=“maps” >
        <map>
            <entry key="addr" value="中国"></entry>
			<entry key="name" value="张三"></entry>
        </map>
     </property>
</bean>
```



```xml
<!--注入外部集合-->
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:util="http://www.springframework.org/schema/util"
       xmlns:xsi="...."
       xsi:schemalLocation="http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util.xsd"
       ....>
    <util:list id="bookList" >
        <value>易筋经</value>
        <value>九阳神功</value>
    </util:list>
	<bean id = "book" class="xx">
        <property name="books" ref = "bookList"></property>
    </bean>
</beans>
    
```

### .2 FactoryBean与Bean

> Spring有两种类型Bean，
>
> 1. 普通Bean
>
> 2. FactoryBean(工厂Bean)
>
>    配置文件定义Bean类型可以和返回类型不一致

* FactoryBean

```java
// 1 创建类作为工厂Bean，实现接口FactoryBean
import com.jz201.study.domain.User;
import org.springframework.beans.factory.FactoryBean;

public class MyFbean implements FactoryBean<User> {
    @Override
    public User getObject() throws Exception {
        User user = new User();
        user.setUsername("Hanmeimei");
        user.setAge(19);
        return user;
    }

    @Override
    public Class<User> getObjectType() {
        return User.class;
    }
}
/** 
<bean id = "myFbean" class="com.jz201.study.domain.MyFbean">
</bean>
*/
test(){
  ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
  User user = context.getBean("myFbean",User.class);
}
    
```



### .3 Bean的作用域(Scope)

> **Spring中设置创建Bean实例时单例还是多例**

* Spring(FactoryBean)中默认创建是单例(Singleten,)

* Scope属性设置单例或多例：

  ```xml
  <!-- Scope：
  	1. 默认singleton,单实例对象
  	2. prototype，表示多实例对象
  	3. request    创建的对象会放到request中
  	4. session    创建的对象会放到session中
  -->
  <bean id = "myFbean" class="com.jz201.study.domain.MyFbean" Scope="prototype">
  </bean>
  ```

* scope: singleton  时，加载spring配置时就创建对象，
* scope: prototype时，加载spring配置时不创建对象，在调用getBean时创建多实例对象

### .4 Bean的生命周期

> Bean创建到销毁的过程 5个步骤
>
> 1. 通过构造器创建Bean实例(无参)； 1
>
> 2. 为Bean的属性设值 和 对其它Bean的引用(调set)；2
> 3. 初始化前置调用
> 4. 调用Bean的初始化方法(自设置) 3
> 5. 初始化后置调用
> 6. 使用Bean 4
> 7. 容器关闭，调用Bean的销毁方法(自配置) 5

```xml
<!-- 
init-method 指定自定义的初始化方法
myBeanPost 实现了BeanPostProcessor 定义了初始化方法的前后置处理方法，对所有Bean都适用
destroy-method 指定自定义的注销方法
-->
<bean id = "myOrder" class="com.jz201.study.domain.MyOrder" init-method="initMethod" destroy-method="destroyMethod">
    <property name="oname" value="手机"></property>
</bean>
<!--初始化处理器对象实例bean（第3步前置处理，第5步后置通知）-->
<bean id="myBeanPost" class="com.jz201.spring.context.domain.MyBeanPost"></bean>

System.out.println("Bean生命周期开始：");
ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean2.xml");
MyOrder myOrder = context.getBean("myOrder",MyOrder.class);
System.out.println("第6步：方法调用："+ myOrder.getOname());
context.close();// 第7步：调用destroy-method方法

System.out.println("Bean生命周期结束；");

结果：
Connected to the target VM, address: '127.0.0.1:63506', transport: 'socket'
Bean生命周期开始：
第1步：通过构造器创建Bean实例(无参)
第2步：为Bean的属性设值 和 对其它Bean的引用
第3步：初始化之前置处理
第4步：初始化方法调用
第5步：初始化之后置处理
第6步：方法调用：手机
第7步：实例销毁调用destroy-method
Bean生命周期结束；
Disconnected from the target VM, address: '127.0.0.1:63506', transport: 'socket'
```

### .5 Bean自动装配

> 1. 根据name自动装配(byName)
> 2. 根据类型自动装配(byType)
>
> ```xml
> <!-- dept作为emp的属性Bean-->
> <bean id = "dept" class="com.jz201.study.domain.Dept"></bean>
> 
> <!--byName根据属性名注入：emp类的属性名和注入之bean的Id保持一致-->
> <bean id = "emp" class="com.jz201.study.domain.Emp" autowire="byName">
>     <!-- 自动装配不需要配置这个
> 		<property name="dept" value="财务"></property> 
> 	-->
> </bean>
> 
> <!--byType 根据属性类型注入：-->
> <bean id = "emp" class="com.jz201.study.domain.Emp" autowire="byType">
>     <!-- 自动装配不需要配置这个
> 		<property name="dept" value="财务"></property> 
> 	-->
> </bean>
> 
> ```
>
> 

### .6 Bean管理-外部属性文件

1）可以直接在xml中配置

```xml
<bean id = "myOrder" class="com.alibaba.druid.pool.DruidDataSource">
    <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
    <property name="url" value="jdbc:mysql///userDb"/>
    <property name="username" value="root"/>
    <property name="password" value="root"/>
</bean>
```



2）通过加载properties文件配置

```properties
jdbc.driverClass=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql///userDb
jdbc.username=root
jdbc.password=root
```

```xml
<!--1. 引入名称空间context-->
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:util="http://www.springframework.org/schema/util"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:xsi="...."
       xsi:schemalLocation="http://www.springframework.org/schema/beans 
                            http://www.springframework.org/schema/beans/spring-beans.xsd
                            http://www.springframework.org/schema/util 
                            http://www.springframework.org/schema/util/spring-util.xsd
                            http://www.springframework.org/schema/context 
                            http://www.springframework.org/schema/context/spring-context.xsd
                            "
       ....>
<!--2. 引入外部属性文件-->
<context:property-placeholder location="classpath: jdbc.properties" /> 
<!--3. 注入配置连接-->
<bean id = "myOrder" class="com.alibaba.druid.pool.DruidDataSource">
    <property name="driverClassName" value="${jdbc.driverClass}"/>
    <property name="url" value="${jdbc.url}"/>
    <property name="username" value="${jdbc.username}"/>
    <property name="password" value="${jdbc.password}"/>
</bean>
```



## 2.2.3 IOC容器bean管理(注解)

> 目的：简化xml配置

### 1. Spring类扫描注解解析器

> 1. @Component
> 2. @Service
> 3. @Controller
> 4. @Repository
>
> * 四个注解功能一样的

#### Spring类扫描注解使用：

1. 依赖jar包：

```java
spring-aop-5.3.1.jar
```

2. 开启组件扫描包：

```xml
1.引入名称空间：xmlns:content(参考前例)
2.配置扫描的包(多个逗号隔开)
<content:component-scan base-package="com.jz201.study"/>

```

3. 在配置包相关类下即可使用注解@

```java
@Component(value="userService")
// 3.1 该注解等价于 <bean id="userService" />
// 3.2 value可不写，默认为类名称首字母小写
```

#### 组件扫描包的特殊处理

1. 示例1：配置**只扫描**指定注解的类

```xml
<!-- 示例1：
	use-default-filters="false" 表示不适用默认扫描所有的过滤器
	<content:include-filter 该例指定只扫描使用了 注解为Controller的类
-->
<content:component-scan base-package="com.jz201.study" use-default-filters="false">
    <content:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
</content:component-scan>
```

2. 示例2：配置**不扫描**指定注解的类

```xml
<!-- 示例1：
	<content:exclude-filter 该例指定不扫描使用了 注解为Controller的类
-->
<content:component-scan base-package="com.jz201.study" use-default-filters="false">
    <content:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
</content:component-scan>
```

### 2. 基于注解方式的属性注入

* 依赖注入的注解解析器

#### 1）@Autowired

> 根据**属性类型**自动注入 类似 <bean xxx autowire="byType"
>
> * 适用于注入的属性有一个实现类的情况《原因参考下面@Qualifier说明》

#### 2）@Qualifier

> 根据**属性名称**自动注入 类似 <bean xxx autowire="byName"
>
> * 该注解要和@Autowired一起使用，因为@Autowired根据属性类型注入，当该属性有多个实现时无法区分用哪个注解
>
>   此时用@Qualifier("指定bean名称")
>
> ```java
> @Autowired // 根据类型注入，但UserDao有多个实现时，需要用@Qualifier配合
> @Qualifier("userDaoImpl") // 根据名称注入
> private UserDao userDao;
> ```

#### 3）@Resource

> 根据属性名称或类型名称都可以 
>
> * 不是spring内置的，时Javax扩展包的注解，@Resource在java11已废弃
> * 如果**不指定resource的name属性表示根据类型注入**
>
> ```java
> // @Resource // 默认表示根据类型注入
> // @Resourcer(name = "userDaoImpl") // 指定根据名称注入
> private UserDao userDao;
> ```

#### 4）@Value

> 注入普通类型属性
>
> ```java
> @Value(value = "abc")
> private String uname;
> ```

### 3. 完全注解开发

1）创建配置类代替xml配置文件

```java
@Configuration// 作为配置类，替代配置文件
@ComponentScan(basePackages = {"com.jz201.study"}) // 代替 <content:component-scan base-package配置
public class SpringConfiguration{
    
}
```

2）测试类

```java
public static void main(String[] args) {
    ApplicationContext context = new AnnotationConfigApplicationContext(SpringConfiguration.class);
    UserService userServicer = context.getBean("userService",UserService.class);
    System.out.println("方法调用："+ userServicer.doOname());
}
```





## 三、AOP面向切面

概念：

1）面向切面编程，是OOP的延申；不改变源代码的情况下对代码增强处理；

2）利用AOP可以对业务逻辑的各个部分进行隔离，从而实现业务逻辑各部分间耦合度降低，提高可重用性，提高开发效率

主要适用：日志记录，性能统计，安全控制，事务处理，异常处理等等

主要特点：将日志记录，性能统计，安全控制，事务处理，异常处理等代码从业务逻辑中划分出来，独立于业务逻辑之外，不影响业务逻辑的代码；



## 3.1 Spring AOP底层原理

### AOP底层使用动态代理

> 两种动态代理
>
> 1. JDK动态代理 （没有接口时情况）
>
>    创建接口的实现类代理对象，增强类方法
>
> 2. CGLIB动态代理（有接口时的情况）
>
>    创建子类的代理对象，增强类方法

### AOP（JDK动态代理）

1. JDK动态代理，使用Proxy类里面的方法创建动态代理；(参考API:)

    java.lang.reflect.Proxy中的方法：newProxyInstance

```java
Proxy.newProxyInstance(target.getClass().getClassLoader(),target.getClass().getInterfaces(),invocationHandle);
/**
第一个参数：目标对象的类加载器
第二个参数：目标对象的所有的接口，增强方法所在的类要实现的接口们
第三个参数：拦截器接口InvocationHandle，此处要实现这个接口，创建代理对象，写增强的方法
			代理对象的方法实际上是拦截器中invoke方法体中的内容
*/
```

   

```java
// 1 创建接口和实现类
public interface UserDao {
    public int add (int a,int b);
    public int sub(int a,int b);
}

public class UserDaoImpl implements UserDao {
    @Override
    public int add(int a, int b) {
        System.out.println("被代理的方法执行了...");
        return a+b;
    }
    @Override
    public int sub(int a, int b) {
        System.out.println("被代理的方法执行了...");
        return a-b;
    }
}

// 2 使用Proxy类创建接口代理对象
public class JDKProxy {
    public static void main(String[] args) {
        UserDaoImpl userDaoimpl = new UserDaoImpl();
        Class<?>[] interfaces = userDaoimpl.getClass().getInterfaces();
        UserDao userDao = (UserDao)Proxy.newProxyInstance(JDKProxy.class.getClassLoader(), interfaces, new UserDaoProxy(userDaoimpl));
        int res = userDao.add(5,5);
        System.out.println("输出执行结果："+res);
    }
}

// 3 创建代理对象的代码
class UserDaoProxy implements InvocationHandler {
    private Object obj;

    public UserDaoProxy(Object obj) {
        this.obj = obj;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        // 执行方法之前的增强代码
        System.out.println(String.format("增强方法之前执行...%s: 传递的参数：%s",method.getName(), Arrays.toString(args)));

        // 执行方法
        Object result = method.invoke(obj, args);

        // 执行方法之后的增强代码
        System.out.println(String.format("增强方法之后执行... %s: ",obj));
        //System.out.println((proxy instanceof UserDao));
        return result;
}
```


​			
​				
​		特点：代理对象和目标对象实现了共同的接口


		代理对象的方法实际上是拦截器中invoke方法体中的内容
## 3.2 AOP的概念术语

1）连接点：被代理的类中要增强的目标方法(如上例userDao的add(),sub())

2）切入点：被代理的类中**实际被增强的方法**

3）通知(增强)：实际增强的相关逻辑部分就是通知

​	通知的类型：

		1. 前置通知：在被增强方法**之前执行**
  		2. 后置通知：在被增强方法**之后执行**
    		3. 环绕通知：在被增强方法**之前后执行**
      		4. 异常通知：在被增强方法**异常时执行**
        		5. 最终通知：在被增强方法执行后**无论如何都会执行finally **

4）切面：(动作) 把相关**通知应用到切入点**的过程就是切面（织入）

## 3.3 AspectJ实现AOP介绍

#### AspectJ介绍：

> AspectJ不是Spring组成部分，是独立的AOP框架，一般通过Spring+AspectJ实现基于AOP的操作；
>
> 实现方式：
>
> 1. 基于注解的AOP实现
> 2. 基于XML的AOP实现

> 依赖的jar
>
> 五个核心包外+
>
> spring-aop-5.3.1.jar
>
> com.springsource.net.sf.cglib-2.2.0.jar
>
> com.springsource.org.aopalliance-1.0.jar
>
> com.springsource.org.aspectj.weaver-1.6.10.RELEASE.jar

#### 切入点表达式

> ```xml
> execution([权限修饰符] [返回类型] [类全路径].[方法名称]([参数列表]))
> // 权限一般省略，表示任意类型的访问权限 可取值public等
> // 返回类型 * 表示匹配任意类型的返回值
> // 方法名称：*表示所有方法
> // 参数列表：()没有任何参数；(*)只有一个参数，但是这个参数的类型可以是任意类型
>     		(*,String) 两个参数，第一个参数任意类型  第二个参数是String类型
>     		(..)  任意多个参数个数  任意类型
> execution(* cn.jz201.spring.aopxml.PersonDaoImpl.*(..))
> execution(* cn.jz201.spring.aopxml.PersonDaoImpl.add(Object,*))
> ```

## 3.3.1 AspectJ实现AOP(注解实现)

1. Spring开启注解扫描和开启生成代理对象

   ```java
   @Configuration
   @ComponentScan({"com.jz201.spring.context.aop.annotation"})
   @EnableAspectJAutoProxy //开启生成代理对象
   public class SpringScanConfiguration {
   }
   ```

2. 使用注解创建User和UserProxy的对象

   ```java
   @Component
   public class User {
       public void add (){
           System.out.println("user add ...");
       }
   }
   // 注解实现的增强类
   @Component
   @Aspect // 切面注解
   public class UserProxy {
       // 前置通知
       public void before(){
           System.out.println("UserProxy before ...");
       }
   }
   ```

3. 在增强类UserProxy增加注解@Aspect

   ```java
   @Component
   @Aspect // 切面注解
   public class UserProxy {
   ```

   

4. 配置不同的通知

   * 在增强类的通知的方法上添加通知类的注解；
   * 在注解上描写切入点表达式

   ```java
   @Component
   @Aspect // 切面注解
   @Order(1)// 多个代理同时对相同的方法声明Aop增强时，配置优先级，越小有优先
   public class UserProxy {
       // 配置切入点
       @Pointcut("@Class(com.jz201.spring.context.aop.annotation.User)")
       public void logPointCut(){
       	
       }
       // 前置通知：不管是否异常都执行
       @Before(value = "logPointCut()")
       public void before(){
           System.out.println("UserProxy before通知 ...");
       }
   
       // 后置通知：不管是否异常都执行
       @After(value = "logPointCut()")
       public void after(){
           System.out.println("UserProxy after通知 ...");
       }
       // ***可以直接写切入点表达式execution***
   	// 环绕通知：异常时只执行环绕前代码
       @Around(value = "execution(* com.jz201.spring.context.aop.annotation.User.add(..))")
       public void doAround(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
           System.out.println("UserProxy 环绕前 ...");
           // 被增强方法执行：
           proceedingJoinPoint.proceed();
           System.out.println("UserProxy 环绕后 ...");
       }
       
       /**
        * //@param 撒joinPoint 切点
        * //@param jsonResult
        */
       // 后置通知：接收有返回值，但是异常时不执行（返回通知）
       @AfterReturning(pointcut = "logPointCut()", returning = "jsonResult")
       public void doAfterReturning(Object jsonResult){
           System.out.println("UserProxy afterReturn通知 ..."+jsonResult);
   
       }
       @AfterThrowing(value = "execution(* com.jz201.spring.context.aop.annotation.User.*(..))")
       public void doAfterThrowing(){
           System.out.println("UserProxy AfterThrowing通知 ..."+1);
       }
   
   }
   ```

6. 测试

   ```java
   public static void main(String[] args) {
       ApplicationContext context = new AnnotationConfigApplicationContext(SpringScanConfiguration.class);
       User user = context.getBean("user",User.class);
       user.add(1,6);
       //System.out.println("结果："+res);
   }
   ```

   结果：
	* 正常时的通知
    ```sh
    UserProxy 环绕前 ...
    UserProxy before通知 ...
    user add ...
    UserProxy afterReturn通知 ...null
    UserProxy after通知 ...
    UserProxy 环绕后 ...
    ```
	* 异常时会执行的通知
    ```sh
    UserProxy 环绕前 ...
    UserProxy before通知 ...
    UserProxy AfterThrowing异常通知 ...1
    UserProxy after通知 ...
    Exception in thread "main" java.lang.ArithmeticException: / by zero
    ```
   
6. 当多个代理同时对一个方法增强时，设置优先级@Order

* Order的值越小优先级越高

```java
@Component
@Aspect // 切面注解
@Order(2)// 多个代理同时对相同的方法声明Aop增强时，配置优先级，越小有优先
public class PersonProxy {}
UserProxy的优先级要大于PresonProxy
    
```

## 3.3.2 AspectJ实现AOP(XML实现)

1. 创建增强类Book和被增强类BookProxy，创建buy方法

   ```java
   // 被增强类
   public class Book {
       public String buy(int c){
           String res = String.format("买了%d本书",c);
           System.out.println(res);
           return res;
       }
   }
   // 增强类
   public class BookProxy {
       public void before(JoinPoint joinPoint) throws Throwable {
           System.out.println("[xml] BookProxy before通知：参数-"+ Arrays.toString(joinPoint.getArgs()));
       }
       public void afterReturn(JoinPoint joinPoint,Object result) throws Throwable {
           System.out.println("[xml] BookProxy after-returning通知：参数-"+ Arrays.toString(joinPoint.getArgs())+",调用结果："+result);
       }
   }
   ```

2. xml引入名称空间xmlns:aop和配置aop增强

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <beans xmlns="http://www.springframework.org/schema/beans"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:aop="http://www.springframework.org/schema/aop"
          xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
                             http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd">
   
       <!--创建对象-->
       <bean id = "book" class="com.jz201.spring.context.aop.xml.Book"></bean>
       <bean id = "bookProxy" class="com.jz201.spring.context.aop.xml.BookProxy"></bean>
       <!--配置aop增强-->
       <aop:config>
           <!--切入点-->
           <aop:pointcut id="point" expression="execution(* com.jz201.spring.context.aop.xml.Book.buy(..))"/>
           <!--配置切面 orde表示优先级 -->
           <aop:aspect order="1" id="bookProxy" ref="bookProxy">
               <!--配置通知-->
               <aop:before method="before" pointcut-ref="point"/>
               <aop:after-returning method="afterReturn" pointcut-ref="point" returning="result"/>
           </aop:aspect>
       </aop:config>
   </beans>
                        
   ```

3. 测试

   ```java
   public static void main(String[] args) {
       ApplicationContext context = new ClassPathXmlApplicationContext("classpath*:bean3Aop.xml");
       Book book = context.getBean("book",Book.class);
       book.buy(5);
   }
   ```

4. 结果：

   ```sh
   [xml] BookProxy before通知：参数-[5]
   买了5本书
   [xml] BookProxy after-returning通知：参数-[5],调用结果：买了5本书
   ```

   

	切面：权限、事务、日志
	通知：  切面中的方法
	切入点：满足切点的表达式的类可以生成代理类
	连接点：在客户端调用的目标方法


​			
​	


​			

​	


## AOP（CGLIB动态代理）

