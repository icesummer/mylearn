# 												Docker手册

## 一、基本命令

### 1）帮助命令

```dockerfile
docker -- help 
docker version
docker info
```

### 2）docker 镜像命令 

http://hub.daocloud.io/

#### 1.2.1 查看本地镜像 

```linux
docker images [-aq] [--digests] [--no-trunc ]
		-a 全部镜像
		-q 只显示镜像ID
		--digests 镜像的摘要写信息
		--no-trunc 镜像的完整信息
```

#### 1.2.2 搜索镜像

```linux
docker search [image name]
eg 搜索不低于3星的python：
docker search --filter=stars=3 python
```

#### 1.2.3 下载镜像
```
docker pull [image name]
eg 下载最新python：
docker pull python 或 docker pull python:latest 
```

#### 1.2.4 删除镜像
```
dockers rmi [-f] [image id|name]
# 删除单个：
docker rmi -f 镜像ID
# 删除多个：
docker rmi -f 镜像名1:tag 镜像名2:tag
# 删除全部：
docker rmi -f $(docker images -qa)

eg: 
```

### 3）docker 容器命令 

#### 1.3.1 创建并启动容器

```yml
1.下载镜像: docker pull [image name] 
2.启动容器: docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
	[OPTIONS]:
	--name 容器新名字：为容器起的一个名称
	-d: 后台运行容器，并返回容器ID，也即启动守护式容器；
	-i: 以交互模式运行容器，通常与-t同时使用；进入docker并返回一个命令终端方便交互
	-t: 为容器重新分配一个伪输入终端，
	-P：随机端口映射
3. 两种启动模式：
	docker run -it 表示以交互模式启动
   	docker run -d  表示以后台守护模式启动
   	
eg1: run -it 0d120b6ccaa8  [centos的imageID=0d120b6ccaa8]
eg2: docker run -it  --name mycentos001 centos
eg3: docker run -d -p 8081:8080 myweb/tomcat8.5:1.2
	重进tomcat->docker exec -it a49fe28c4109 /bin/bash 操作tomcat部署文件
```

#### 1.3.2 列出当前容器

```less
docker ps [OPTIONS]
	-l 最近容器
	-a 当前运行和历史运行的
	-n [n] 前n次
	-q 静默模式，只显示容器编号
	--no-trunc  不截断输出(显示完整containerID)
```

#### 1.3.3 退出和进入运行中容器

​	1.3.3.1 交互启动模式下--两种：

 	1. `exit`  容器内执行，容器停止并退出
 	2. 快捷键：`ctrl+P+Q  ` 容器不停止退出

#### 1.3.4  停止容器

1. 慢慢停止 `docker stop [containerID]`

 	2. 强制停止 `docker kill[containerID]`

#### 1.3.5  启动和重启容器

​	`docker start [containerID]`

​	`docker restart [containerID]`

#### 1.3.6  删除已停止容器

```shell
docker rm [-f] [containerID]  删除某容器,不加-f只能删已停止的
```
* 一次行删除多个容器:

```shell
docker rm -f $(docker ps -a -q) 删除所有容器
docker rm -f $(docker ps -a |grep Exited) 删除不运行的容器
docker ps -a -q|xargs docker rm 同1
```

#### 1.3.7  查看容器日志

```less
docker logs -f -t --tail 容器ID
    -t是加入时间戳
    -f是跟随最新的日志打印
    --tail [n] 显示最后n条
```
#### 1.3.8   查看容器内运行的进程

​	`docker top 容器ID`

#### 1.3.9   查看容器内部细节

​	`docker inspect 容器ID`

#### 1.3.10  进入正在运行的容器并以命令交互

* docker exec -it 容器ID [执行的命令]
  ```less
  docker exec -it 容器ID [执行的命令]
  1. docker exec -it xxx /bin/bash
  	跟attach一样进入了容器shell终端
  2. docker exec -it xxx ls -l /tmp
  	直接返回了tmp下的文件列表并退出容器 
  3. docker exec -it a49fe28c4109 /bin/bash 重进tomcat操作部署文件
  ```
* docker attach [容器ID]
  	直接进入容器启动命令的终端，不产生新的进程

#### 1.3.11  从容器内拷贝文件到主机上

```turtle
docker cp 容器ID:/tmp/a.txt /root
将容器ID中的a.txt拷贝到本机/root下
```

## 二、自定义本地镜像
### 2.1） 命令格式

* 使用docker commit 提交容器的副本使之成为一个新的镜像
* <u>docker commit -m="提交的描述信息" -a="作者" 被复制的容器ID 要创建的目标镜像名</u>:

#### 2.1.1 将一个tomcat容器发布为本地镜像

1.下载tomcat镜像到本地运行

``` less
1. 下载tomcat镜像 docker pull tomcat:8.5
2. 创建容器并启动 docker run -it -p 8080:8080 tomcat:8.5 
```
2.故意删除上一步镜像的tomcat/webapps下的内容/或放入自己的war包

```
docker exec -it a49fe28c4109 /bin/bash 
	重进tomcat修改部署文件，
eg: 上传部署包 webapps/ROOT/xxx.war
```
3.将它作为新的镜像 myweb/tomcat8.5

```less
docker commit -a="ice" -m="myweb" a49fe28c4109 myweb/tomcat8.5:1.2
	用容器a49fe28c4109新建一个myweb/tomcat8.5的镜像tag=1.2
```

4.新的镜像启动容器

```
docker run -it -p 8081:8080 myweb/tomcat8.5:1.2
	启动了一个新的tomcat
```

***

## 三、Docker容器数据卷

### 1）做什么

   * <u>容器的数据持久化</u>
     
   * 容器间继承共享数据

#### 1.1  数据卷特点

1. 容器之间共享数据
2. 卷中的更改可以直接生效
3. 数据卷的更改不会包含在镜像的更新中
4. 数据卷的生命周期一直持续到没有容器用它为止

### 2）向容器添加数据卷

#### 2.1 直接命令添加

命令：

`docker run -v /宿主机绝对目录:/容器内目录  镜像名`

命令(带权限)：

```docker run -v /宿主机绝对目录:/容器内目录:ro  镜像名```

```turtle
eg: 1、宿主机D:/work/test/zhuji下的文件与容器/data/volume/container下的文件同步共享： 
docker run -it -v D:/work/test/zhuji:/data/volume/container centos

eg: 2、但容器下权限时readonly操作，增加ro：
docker run -it -v D:/work/test/zhuji:/data/volume/container:ro centos
```

#### 2.2 DockerFile添加



- Dockerfile中使用VOLUME指令来给镜像添加一个或多个数据卷:

  ```less
  VOLUMN["/dataValume/container1/","/dataValume/container2/","/dataValume/container3/"]
  ```

  [^注]: Dockerfile只是容器内部的数据卷映射，不支持宿主机和容器的数据卷映射

  ![image-20201030120115398](C:\Users\sum\AppData\Roaming\Typora\typora-user-images\image-20201030120115398.png)

## 四、Dockerfile

Dockerfile是用来构建Docker镜像的构建文件，是有一系列命令和参数构成的脚本

### 1）Dockerfile体系结构(保留字指令)

```	less
FROM 基础镜像，当前镜像是基于哪个镜像
	FROM scratch # scratch是最基础的镜像
MAINTAINER 镜像维护者的姓名和邮箱 
	MAINTAINER wuxw <928255095@qq.com>
RUN 容器构建时需要执行的命令
	RUN groupadd redis
EXPOSE 当前容器对外暴露的端口号
WORKDIR 指定在创建容器后，终端默认登录进来的工作目录，
	WORKDIR /data
ENV 用来在构建镜像过程中设置环境变量
	ENV MY_PATH /usr/mypath
		#声明了/usr/mypath目录的环境变量￥MY_PATH
ADD 将宿主机目录下的文件拷贝到镜像且ADD命令自动处理URL和解压tar包
COPY 类似ADD命令，不解压等操作，将从构建上下文目录<源路径>的文件/目录复制到新的一层镜像的<目标目录>位置
	COPY src dest
	COPY ["src","dest"]
VOLUME 容器数据卷，用于数据持久化和容器间共享
CMD 指定一个容器启动时要运行的命令
	Dockerfile可以有多个CMD，但最后一个为准
	CMD会被docker run之后的参数命令替换：
		Dockerfile中:CMD {"catalina.sh","run"]
		docker run tomcat:22 ls -l
		第一个命令就被ls-l替换执行了，导致tomcat未启动
ENTRYPOINT 指定一个容器启动时要运行的命令
	与CMD不同的是docker run 后的参数命令不对其替换
		Dockerfile配置的:ENTRYPOINT {"catalina.sh","run"]
		docker run tomcat:1.0 ls -l
		Dockerfile命令执行完后再执行 ls-l
ONBUILD 当构建一个被继承的Dockerfile时运行命令，父镜像在被子继承后，父镜像的onbuild被触发
```

### 2）3步骤

 1. 创建一个Dockerfile文件，并且指定自定义镜像信息
 ```scss
 Dockerfile中常用的内容
 from 指定当前自定义镜像依赖的环境
 copy 将相对路径下的内容复制到自定义镜像中
 workdir 声明镜像的默认工作目录
 cmd 需要执行的命令```
 ```
 2. 执行docker build 命令，构建一个自定义镜像
 ```scss
 docker build -f /data/web/cloud/docker/Dockerfile -t mycentos:1.1 .<最后的点表示当前目录上下文找Dockerfile>
 ```
 3. docker run
 ```scss
 docker run -it mycentos:1.1
 ```

### 3）自定义tomcat案例

#### 	3.1、编写Dockerfile文件

```sh
FROM centos
MAINTAINER ice<icesummer_u@qq.com>
# 把宿主机当前上下文的c.txt拷贝到容器/usr/local/路径下
COPY c.txt /usr/local/cincontainer.txt
# 把宿主机jdk包tomcat包添加到容器中
ADD jdk-8u171-linux-x64.tar.gz /usr/local/
ADD apache-tomcat-9.0.8.tar.gz /usr/local/
# 安装vim编辑器 
RUN yum -y install vim
# 设置默认访问的WORKDIR目录，登陆落脚点
ENV MYWORKDIR /usr/local
WORKDIR $MYWORKDIR
# 配置java与tomcat环境变量
ENV JAVA_HOME /usr/local/jdk.1.8.0_171
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV CATALINA_HOME /usr/local/apache-tomcat-9.0.8
ENV CATALINA_BASE /usr/local/apache-tomcat-9.0.8
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/lib:$CATALINA_HOME/bin
# 容器运行时监听的端口
EXPOSE 8080
# 启动时运行tomcat
# ENTRYPOINT ["$CATALINA_BASE/bin/startup.sh"]
# CMD ["$CATALINA_BASE/bin/catalina.sh","run"]
CMD $CATALINA_HOME/bin/startup.sh && tail -F $CATALINA_HOME/bin/logs/catalina.out

```

#### 3.2、执行build构建镜像
```scss
	docker build -t mytomcat9
```

#### 3.3、docker run启动容器

```scss
docker run -d -p 9090:8080 --name myweb -v /data/docker/tomcat9/myweb:/usr/local/apache-tomcat-9.0.8/webapps/myweb -v /data/docker/tomcat9/logs:/usr/local/apache...9.0.8/logs --privileged=true mytomcat9
```

## 五、Docker-Compose

> 优点
> * 方便配置参数；
> * 批量管理容器；

### 1）下载安装


``` scss
1、[下载地址][https://github.com/docker/compose] docker-compose-Linux-x86_64
2、传至linux，/data/installs/docker-compose/ 修改名称为docker-compose
​	chmod 755 docker-compose
3、增加配置环境变量
vim /etc/profile
export $PATH:/data/installs/docker-compose
source /etc/profile
```

### 2）管理Mysql和Tomcat容器

> 常规方法：安装mysql5.7

```haskell
docker run -p 3306:3306 --name mysql-57 -v /my/mysql/conf:/etc/mysql/conf -v /my/mysql/logs:/logs - v /my/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=xxx -d centos/mysql-57-centos7
-v /mydata/mysql/conf:/etc/mysql：将配置文件夹挂在到主机
-v /mydata/mysql/log:/var/log/mysql：将日志文件夹挂载到主机
-v /mydata/mysql/data:/var/lib/mysql/：将配置文件夹挂载到主机
----
mysql/mysql-server
```

> 安装mariadb（docker pull mariadb）

```scss
docker run -v /my/mariadb/:/var/lib/mariadb -p 3309:3309 -e MYSQL_ROOT_PASSWORD=xxx --privileged=true --restart unless-stopped --name mariadbs -d mariadb:latest
```

#### 	2.1、docker-compose-yml

centos/mysql-57-centos7

```yml
version: '3.1'
services: 
  mysql:                      # 服务的名称
    restart: always           # 总是随容器启动
    image: daocloud.io/library/mysql:5.7.4 # 镜像的位置 
    container_name: mysql57   # 容器的名称
    ports:                    # 映射容器端口
      - 8817:3306
    environment: 
      MYSQL_ROOT_PASSWORD: roto-!23    # mysql的root密码
      TZ: Asia/Shanghai                # 时区
    volumes: 
      - /data/web/cloud/docker/mysql/data:/var/lib/mysql  #映射数据卷
      - /data/web/cloud/docker/mysql/conf:/etc/mysql/conf.d 
      - /data/web/cloud/docker/mysql/logs:/logs
  tocmat:                      # 服务的名称
    restart: always            # 总是随容器启动
    image: dordoka/tomcat      # 镜像的位置
    container_name: tomcat8    # 容器的名称
    ports:                     # 映射容器端口
      - 8816:8080
    environment: 
      TZ: Asia/Shanghai
    volumes:
      - /data/web/cloud/docker/tc8/webapps:/usr/local/tomcat/webapps
      - /data/web/cloud/docker/tc8/logs:/usr/local/tomcat/logs
```

#### 2.2、docker-compose命令管理容器

> 使用docker-compose时，默认会在当前命令下找docker-compose.yml文件

```sh
mkdir /data/docker//mysql /data/docker/tc8
#1. 基于docker-compose.yml启动管理容器
docker-compose up -d # -d后台启动
#2. 关闭并删除容器
docker-compose down
#3. 开启或关闭已经存在的由docker-compose维护的容器
docker-compose start|stop|restart
#4. 查看由docker-compose维护的容器
docker-compose ps
#5. 查看日志
docker-compose logs -f 
```

#### 2.3、docker-compose配置Dockerfile使用








```

```