## dubbo+nacos+springboot搭建

#### 官方例子1: 
> 地址 [网址](https://github.com/apache/dubbo-spring-boot-project/blob/master/dubbo-spring-boot-samples/registry-samples/pom.xml)
#### 官方例子2
> [1.网址](https://github.com/apache/dubbo-samples/tree/master/dubbo-samples-nacos)
> - 版本信息：
> - dubbo.version：2.7.8 >
> - nacos.version: 1.3.2 >
>
> 2.dubbo-provider.properties:
> - dubbo.application.name=nacos-registry-demo-provider
> - dubbo.registry.address=nacos://${nacos.address:localhost}:8848
> - dubbo.protocol.name=dubbo
> - dubbo.protocol.port=20880 
> - dubbo.scan.base-packages=com.?.service.impl
> - dubbo.config-center.address.nacos=//${nacos.server-address}:${nacos.port}
 
> 3.dubbo-consumer.properties
 > - dubbo.application.name=nacos-registry-demo-consumer
 > - dubbo.registry.address=nacos://${nacos.address:localhost}:8848
 > - dubbo.consumer.timeout=3000
 > - dubbo.config-center.address.nacos=//${nacos.server-address}:${nacos.port}
 
>>> [推荐用法](http://dubbo.apache.org/zh-cn/docs/2.7/user/recommend/)

> - [dubbo官网](http://dubbo.apache.org/zh-cn/docs/2.7/user/configuration/annotation/)

#### 其它版本
> - [dubbo+spring组合](https://github.com/apache/dubbo-samples)
>
> - end

## dubbo 序列化
- 概念
```  
序列化：   将对象转化为二进制进行网络传输<网络传输的需要>
反序列化： 序列化的反过程
TCP:        长连接 - 避免了每次新建连接
UDP:        无连接
多路复用：   单个TCP连接可以交替传输多个请求和相应的消息，
            降低了连接的等待时间，减少了网络连接数，提高系统吞吐量
```
- Dubbo RPC
```
> Dubbo RPC是Dubbo体系中最核心的高性能高吞吐量的远程调用方式，称之为多路复用的TCP长连接调用
> Dubbo RPC 主要用于两个Dubbo系统之间的远程调用，
    而序列化对于远程调用的响应速度、吞吐量、带宽消耗等关键作用，
    是提升分布式系统性能的关键因素之一
```
> dubbo 序列化方式
``` 
> dubbo序列化  -- 尚未成熟的java序列化
> hesslan2序列化 dubbo默认的序列化实现
> json序列化   -- 
> java序列化
```
- 推荐使用两个：Kryo和THrift
--- 
### dubbo序列化之Kryo和Thrift
> dubbo 序列化之Kryo（java）和Thrift（跨语言）
> > 打法

#### kryo
``` xml
<dependency>
    <groupId>org.apache.dubbo</groupId>
    <artifactId>dubbo-serialization-kryo</artifactId>
    <version>${kryo.version:2.7.8}</version>
</dependency>
- > yml:
  protocol:
    name: dubbo
    serialization: kryo # dubbo的序列化支持 需引入组件 dubbo-serialization-kryo(provider和consumer)
    #serialization: thrift # dubbo的序列化支持 需引入组件 dubbo-serialization-thrift
```
---
## Dubbo负载均衡
> 负载均衡算法  默认四大策略 leastactive  
> - 1.随机 random(缺省);: 按权重随机
> - 2.轮询 roundrobin；(nacos默认是轮询)
> - 3.最不活跃优先 leastactive; 
> - 4.一致性哈希 consistenthash
> ``` properties
> dubbo.consumer.loadbalance= roundrobin
> ```


```yaml
# provider.yml
server:
  port: 9008
spring:
  application:
    name: dubbo-provider-nacos9008
  main:
    allow-bean-definition-overriding: true # 允许覆盖，解决同类名冲突
# Dubbo Application
## The default value of dubbo.application.name is ${spring.application.name}
## dubbo.application.name=${spring.application.name}
## nacos信息
nacos:
  server-address: ctos.javazz.com
  port: 8848
  username: nacos
  password: nacos@kszz

dubbo:
  application:
    name: dubbo-provider-nacos9008
  registry:
    address: nacos://ctos.javazz.com:8848
    #file: ${user.home}/output/dubbo.cache # 提供者列表缓存文件
  protocol:
    name: dubbo
    port: -1 # -1表示自动分配端口号 Random port
    #serialization: kryo # dubbo的序列化支持 需引入组件 dubbo-serialization-kryo(provider和consumer)
    #serialization: thrift
  scan: # dubbo服务包扫描
    base-packages: com.aiguigu.springcloud.dubbo.service.impl
#  consumer: # 在Provider端配置的 Consumer 端属性
#    loadbalance: leastactive #负载均衡算法  1.随机 random(缺省); 2.轮询 roundrobin; 3.最不活跃优先 leastactive; 4.一致性哈希 consistenthash
#      actives: 5 # 消费者端的最大并发调用限制:当 Consumer 对一个服务的并发调用到上限后，新调用会阻塞直到超时
#      timeout: 10000  #方法调用的超时时间
#      retries: 3 #失败重试次数 默2
#  provider: # 在Provider端配置合理的 Provider 端属性
#    threads: 5 # 服务线程池大小
#    executes: 5 # 服务者提供的请求上限:当当 Provider 对一个服务的并发调用达到上限后，新调用会阻塞，此时 Consumer 可能会超时；
#  config-center:
#    address: nacos://${nacos.server-address}:${nacos.port}
#    username: ${nacos.username:nacos}
#    password: ${nacos.password}
#    highest-priority: false

```


===

```yaml
# consumer.yml
server:
  port: 7008
spring:
  application:
    name: dubbo-nacos-consumer7008
  main:
    allow-bean-definition-overriding: true # 允许覆盖，解决同类名冲突

#nacos信息设置:
nacos:
  server-address: ctos.javazz.com
  host: ctos.javazz.com
  port: 8848
  username: nacos
  password: nacos@kszz

# dubbo配置
dubbo:
  application:
    name: dubbo-nacos-consumer7008
  registry:
    address: nacos://ctos.javazz.com:8848
  protocol:
    name: dubbo
    port: -1 # -1表示自动分配端口号 Random port
    serialization: kryo # dubbo的序列化支持 需引入组件 dubbo-serialization-kryo(provider和consumer)
  consumer:
    timeout: 3000
    loadbalance: leastactive
  config-center:
    address: nacos://${nacos.server-address:127.0.0.1}:${nacos.port}
    highest-priority: false # ?

# 开启dubbo的健康检查？？？
endpoints:
  dubbo:
    enabled: true
management:
  health:
    dubbo:
      status:
        defaults: memory
        extras: threadpool
  endpoints:
    web:
      exposure:
        include: '*'
```

[阿里maven仓库](https://maven.aliyun.com/)