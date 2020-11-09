### docker-compose搭建Nexus

* 搭建Maven私服Nexus   ： docker-compose.yml

```yml
version: '3.7'
services:
  nexus:
    image: 'sonatype/nexus3'
    container_name: 'nexus'
    ports:
      - 8081:8081
    volumes:
      - ./data:/nexus-data
# 给./data赋予读写权限
# 登录http://ip:port/nexus  # 默认账户admin,密码在/nexus-data/admin.password on the server.

# Pom配置私服地址：
## 1.配置代理仓库：<repositories> 详略
## 2. 配置代理仓库插件 <pluginRepositories> 祥略
## 如上就可以从私服拉取依赖，（过程：pom文件先从私服仓库下载，如果没有再仓中央仓库拉取）
### 执行命令 mvn clean package -Dmaven.test.skip=true即可拉取依赖

# 发布jar到私服
## 1. 在本地maven的settings中配置Server节点(发行版和快照版)
<server><id>nexus=releases</id><username>admin</username><password><admin123</password></server>
<server><id>nexus-snapshots</id><username>admin</username><password><admin123</password></server>
## 2. 在项目pom中配置<distributionManagment>
<repository><id>nexus-release</id><name>x</name><url>http://ip:8081/repository/maven-release/</url></repository>
<snapshotRepository><id>nexus-snapshots</id><name>x</name><url>http://ip:8081/repository/maven-release/</url></snapshotRepository>
# 执行命令： mvn deploy -Dmaven.test.skip=true     # (install and upload)

# 手动上传第三方依赖(Nexus3.1+支持) 或者pom下执行如下：
# 如第三方jar包 aliyun-sdk-oss-2.2.3.jar
mvn deploy:deploy-file
    -DgroupId=com.aliyun.oss
    -DartifactId=aliyun-sdk-oss
    -Dversion=2.2.3
    -Dpackaging=jar
    -Dfile=D:\jar\aliyun-sdk-oss-2.2.3.jar
    -Drepository=nexus-releases
```

