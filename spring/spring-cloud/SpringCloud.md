# 高并发，高性能，高可用

> 实现方案即思路：

## 高性能方案

	- RPC通信
	- Kyro 高速序列化
	- HikariCP 连接池
	- SQL优化
	- Redis缓存
	- JVM优化
	- GC优化

## 高并发方案

- 垂直扩展(单机高配)
- 水平扩展(负载，集群，分布式)

## 高可用方案

- 故障恢复(自动快速)
- 自动扩(缩)容- ----- 自动增加加部署服务(k8s)
- 滚动更新(一次更新一个小功能，) 自动的版本回滚 (k8s)
- DevOps(自动化运维)  (k8s)



- TIDB分布式集群数据库?
- mvn scm插件 预发布，自动一致版本号

# SpringCloud

## 集成概述

> 服务注册与发现：

* Nacos server 提供了服务注册与发现

> 服务配置中心：

* Nacos config 提供了配置中心

> 服务调用：

* **对外接口Rest**(Gateway)；
  * [参考](https://github.com/alibaba/spring-cloud-alibaba/blob/master/spring-cloud-alibaba-examples/nacos-example/nacos-gateway-example/readme-zh.md)
* **对内服务调用 RPC  推荐(Dubbo)**或OpenFeign(伪http)；不推荐的Rest(ribbon)

> 服务熔断降级：

* Alibaba-Sentinel	或者
* Spring-Cloud-Hystrix

> 分布式事务：

* Alibaba-Seata或者
* BiteTcc







## Nacos部署

### Nacos-Docker快速开始

> [start](https://nacos.io/zh-cn/docs/quick-start-docker.html)

Nacos继承了ribbon，但我们通常使用Dubbo作为RPC调用，或者伪http的OpenFeign



1） clone项目

```bash
git clone https://github.com/nacos-group/nacos-docker.git
```

2）单机项目

```bash
docker-compose -f example/standalone.yaml up
```

3）集群模式(建议)

```bash
docker-compose -f example/cluster-hostname.yaml up
```

### Nacos-手动部署

> 集群模式
>
> ```bash
> # 安装nginx
> # 配置多个nacos服务
> # # 开启cluster支持(配置服务ip列表)
> # # 使用mysql持久化配置
> ```
>
> 

## SpringCloud+Nacos

### Nacos registry

> 引入pom和配置bootstrap.yml

```yaml
server:
  port: 84
spring:
  application:
    name: nacos-order-consumer
  main:
    allow-bean-definition-overriding: true # 允许覆盖，解决同类名冲突
  cloud:
    nacos:
      discovery:
        server-addr: ctos.javazz.com:8848
    sentinel:
      transport:
        dashboard: localhost:8089
        port: 8719
# ribbon的服务地址，用feign或dubbo代替服务调用可不用管
#service-url:
#  nacos-user-service: http://nacos-payment-provider

#激活sentinel对feign的支持
feign:
  sentinel:
    enabled: true
```

> 打开localhos:8848/nacos注册成功

### Nacos config

* 为分布式系统提供外部化配置提供服务端和客户端支持，可以在nacos server中管理SpringCloud应用的外部化配置	

* nacos config 在bootstrap阶段 就把配置加载到Spring环境中，支持多生产配置

> 引入Pom和配置bootstrap.yml
``` yaml
server:
  port: 3377
spring:
  application:
    name: nacos-config-client
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 # 注册中心
      config:
        server-addr: localhost:8848 # 配置中心
        file-extension: yaml # 这里指定的文件格式需要和nacos上新建的配置文件后缀相同，否则读不到
        group: TEST_GROUP
        namespace: 4ccc4c4c-51ec-4bd1-8280-9e70942c0d0c

#  ${spring.application.name}-${spring.profile.active}.${spring.cloud.nacos.config.file-extension}
```

> 在application.yml中配置active

```yaml
spring:
  profiles:
    active: dev # 开发环境 对应nacos的配置文件
#    active: test # 测试环境
#    active: info # 开发环境
```

> 在nacos-server中的配置中心编写配置文件：nacos-config-client-dev.yaml

```yaml
# 自定义配置，
# 代码使用注解：@RefreshScope 实现修改配置动态刷新
spring:
  database:
    url: xxxx
```

> 多环境配置

* 



### Nacos+Dubbo集成

* 参考[Readme-dubbo.md](Readme-dubbo.md)





# SpringSecurity-oAuth2

auth2.0协议

密码模式

* 适用于企业内部相同产品线，使用的统一认证中心；如 SSO  单点登录

客户端模式

* 当前系统内 服务与服务之间的直连调用模式，eg：商品服务调用订单服务同样需要认证登录信息

授权码模式

* 适用于企业间应用认证授权

## Access Token



## Refresh Token 

* 刷新令牌，获取到新的AccessToken(即将到期的AccessToken使用)



## 授权码模式实战

创建oAuth2 的server项目

### 基于内存存储令牌

>  服务器安全配置

```java
// Spring Security配置类
// 服务器安全配置
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true,securedEnabled = true,jsr250Enabled = true)// 拦截所有请求
public class WecSecurityConfiguration extends WebSecurityConfigurerAdapter {// 适配模式
    @Bean
    public BCryptPasswordEncoder passwordEncoder(){
        // 配置默认的加密方式     bcrypt混淆机制每次加密结果不一样(非对称加密)
        // 各种实现方式：PasswordEncoderFactories
        return new BCryptPasswordEncoder(); // 适配不同的密码方式
    }

    // 设置认证
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        //auth.jdbcAuthentication().dataSource(ds)   //
       //使用内存级别的 InMemoryUserDetailsManager Bean 对象，提供认证的用户信息。
        auth.inMemoryAuthentication()// 在内存中创建用户
                .withUser("user").password(passwordEncoder().encode("123456")).roles(("USER"))
                .and()
                .withUser("admin").password(passwordEncoder().encode("admin")).roles("ADMIN");
        
    }
}

```

> 认证服务配置(基于内存存储令牌)

```java
package com.javazz201.security.oauth2.server.configure;
 // 授权认证
@Configuration
@EnableAuthorizationServer // 开启授权认证服务
public class AuthorizationServerConfiguration extends AuthorizationServerConfigurerAdapter {
   
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Override
    public void configure(AuthorizationServerSecurityConfigurer security) throws Exception {
        super.configure(security);
    }
    // 配置客户端
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory()// 内存中
                .withClient("client")
                .secret(passwordEncoder.encode("secret"))
                .authorizedGrantTypes("authorization_code")// 授权码模式
                .scopes("app")// 授权范围
            //.redirectUris("https://host.javazz.com:8088/get/access_token")// 回调地址,异步 ；调用发能使用access_token
                .redirectUris("https://www.baidu.com")// 回调地址,异步 ；调用发能使用access_token
            ;
        //http://192.168.1.100:8001/oauth/authorize?response_type=code&client_id=client
    }
}
```



> 请求授权码，获得令牌

- 获取code

```bash
# 请求：http://192.168.1.100:8001/oauth/authorize?response_type=code&client_id=client
# 在页面点击同意授权：Approve - > Authorize
# 将跳转至redirect_url:https://www.baidu.com/?code=ssEvau # 取得授权码code:ssEvau

```

* 请求令牌

```bash
# curl请求：
# # curl:
#  curl -X POST -H "Content-type:application/x-www-form-urlencoded" -d 'grant_type=authorization_code&code=IUghe0' "http://client:secret@192.168.1.100:8001/oauth/token"

# 或者打开postMan工具请求Post
# http://client:secret@192.168.1.100:8001/oauth/token ###-H -

```

- 结果

```json
// 正确：
{
    "access_token":"96b9bb5b-c9ba-42ca-b0e8-8758b8791cba",
    "token_type":"bearer",
    "expires_in":43061,
    "scope":"app"
}
{
    "timestamp":"2020-11-24T15:24:12.492+00:00",
    "status":401,
    "error":"Unauthorized",
    "message":"",
    "path":"/oauth/token"
}
```



### 基于JDBC存储令牌

> 初始化oauth2相关表

```sql
-- https://github.com/spring-projects/spring-security-oauth/blob/master/spring-security-oauth2/src/test/resources/schema.sql

-- used in tests that use HSQL
create table oauth_client_details (
  client_id VARCHAR(128) PRIMARY KEY,
  resource_ids VARCHAR(256),
  client_secret VARCHAR(256),
  scope VARCHAR(256),
  authorized_grant_types VARCHAR(256),
  web_server_redirect_uri VARCHAR(256),
  authorities VARCHAR(256),
  access_token_validity INTEGER,
  refresh_token_validity INTEGER,
  additional_information VARCHAR(4096),
  autoapprove VARCHAR(256)
);

create table oauth_client_token (
  token_id VARCHAR(256),
  token varbinary,
  authentication_id VARCHAR(256) PRIMARY KEY,
  user_name VARCHAR(256),
  client_id VARCHAR(256)
);

create table oauth_access_token (
  token_id VARCHAR(256),
  token LONGBLOB,
  authentication_id VARCHAR(256) PRIMARY KEY,
  user_name VARCHAR(256),
  client_id VARCHAR(256),
  authentication LONGBLOB,
  refresh_token VARCHAR(256)
);

create table oauth_refresh_token (
  token_id VARCHAR(256),
  token LONGBLOB,
  authentication LONGBLOB
);

create table oauth_code (
  code VARCHAR(256), authentication LONGBLOB
);

create table oauth_approvals (
	userId VARCHAR(256),
	clientId VARCHAR(256),
	scope VARCHAR(256),
	status VARCHAR(10),
	expiresAt TIMESTAMP,
	lastModifiedAt TIMESTAMP
);


-- customized oauth_client_details table
create table ClientDetails (
  appId VARCHAR(128) PRIMARY KEY,
  resourceIds VARCHAR(256),
  appSecret VARCHAR(256),
  scope VARCHAR(256),
  grantTypes VARCHAR(256),
  redirectUrl VARCHAR(256),
  authorities VARCHAR(256),
  access_token_validity INTEGER,
  refresh_token_validity INTEGER,
  additionalInformation VARCHAR(4096),
  autoApproveScopes VARCHAR(256)
);
```

> pom.xml

```xml
<!--mysql JDBC驱动 8.0.22-->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <!--<version>8.0.22</version>-->
</dependency>
<!--data-jdbc-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jdbc</artifactId>
    <exclusions>
        <exclusion>
            <artifactId>HikariCP</artifactId>
            <groupId>com.zaxxer</groupId>
        </exclusion>
    </exclusions>
</dependency>
<!-- 数据库连接池工具HikariCP -->
<!-- HikariCP 是几个常见数据库连接池中出现的最晚的一个。它口号是“快速、简单、可靠”，官方宣传是性能最快的数据库连接池
-->
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>3.4.5</version>
</dependency>
```

yaml

```yaml
server:
  port: 8001
spring:
  application:
    name: oAuth2-server
  datasource:
    type: com.zaxxer.hikari.HikariDataSource
    driver-class-name: com.mysql.cj.jdbc.Driver
    #url: jdbc:mysql://ctos.javazz.com:3306/oauth2?autoReconnect=true&useUnicode=true&useSSL=false&characterEncoding=utf8&allowMultiQueries=true&serverTimezone=Hongkong # 后台ClientDetails需要换位jdbc连接
    jdbc-url: jdbc:mysql://ctos.javazz.com:3306/oauth2?autoReconnect=true&useUnicode=true&useSSL=false&characterEncoding=utf8&allowMultiQueries=true&serverTimezone=Hongkong
    username: root
    password: roto-123456
    hikari:
      minimum-idle: 5
      idle-timeout: 600000
      auto-commit: true
      pool-name: MyHikariCP
      maximum-pool-size: 10
      max-lifetime: 1800000
      connection-timeout: 30000
      connection-test-query: select 1
```
> 配置类：
```java
@Configuration
@EnableAuthorizationServer // 开启授权认证服务
public class AuthorizationServerConfiguration extends AuthorizationServerConfigurerAdapter {
    // 授权认证
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Bean(name = "dataSource")
    @ConfigurationProperties(prefix = "spring.datasource")
    @Primary
    public DataSource datasource(){// 改成jdbc的连接
        return new HikariDataSource();
        //return DataSourceBuilder.create().build();
    }
    
    @Qualifier("dataSource")
    @Autowired
    private DataSource dataSource;

    @Bean
    public TokenStore tokenStore(){
        // token存储
        return new JdbcTokenStore(dataSource);
    }
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
        endpoints.tokenStore(tokenStore());// token写入到数据库
    }
    @Bean("jdbcClientDetailsService")
    public ClientDetailsService clientDetailsService(){
        // client details信息<读取的客户端配置信息>
        return new JdbcClientDetailsService(dataSource);
    }
    // 配置客户端
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
       /* clients.inMemory()// 内存中
                .withClient("client")
                .secret(passwordEncoder.encode("secret"))
                .authorizedGrantTypes("authorization_code")// 授权码模式
                .scopes("app")// 授权范围
                .redirectUris("https://www.baidu.com")// 回调地址,异步 ；调用发能使用access_token
            ;*/
        //http://192.168.1.100:8001/oauth/authorize?response_type=code&client_id=client
        clients.withClientDetails(clientDetailsService()).jdbc().dataSource(dataSource).passwordEncoder(passwordEncoder);
    }
}
```

> 插入client数据 ()

```sql
INSERT INTO `oauth_client_details`(`client_id`, `resource_ids`, `client_secret`, `scope`, `authorized_grant_types`, `web_server_redirect_uri`, `authorities`, `access_token_validity`, `refresh_token_validity`, `additional_information`, `autoapprove`) VALUES ('client', NULL, '$2a$10$bBrFUJ4aCXT7JLrkbsvFBO43TFIg7rSlcpa902ezEHUR6q7EKDxhi', 'App', 'authorization_code', 'https://www.baidu.com/', NULL, NULL, NULL, NULL, NULL);

```

> 启动测试

```bash
## 启动Application并访问
# 请求：http://192.168.1.100:8001/oauth/authorize?response_type=code&client_id=client
# 在页面点击同意授权：Approve - > Authorize
# 将跳转至redirect_url:https://www.baidu.com/?code=ssEvau # 取得授权码code:ssEvau

```
> 请求令牌

```bash
# curl请求：
# # curl:
#  curl -X POST -H "Content-type:application/x-www-form-urlencoded" -d 'grant_type=authorization_code&code=8XuCvS' "http://client:secret@192.168.1.100:8001/oauth/token"

# 或者打开postMan工具请求Post
# http://client:secret@192.168.1.100:8001/oauth/token ###-H -

```

> 结果

``` bash
{"access_token":"9f6eeb03-4289-4522-9691-a2a8e94e4018","token_type":"bearer","expires_in":43199,"scope":"App"}
```



### RBAC 基于角色的访问控制

* 基于用户，角色，权限 的访问控制认证 ，
* 有时我们会可有扩展一个用户组：user_group分配角色，把用户置于对应的user_group中；方便使用 

