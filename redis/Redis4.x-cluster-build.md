# redis4以下集群搭建

## 一、搭建集群的要求（redis4）

### ruby环境

集群管理工具redis-trib.rb依赖ruby环境，首先安装ruby环境：

- 注：redis 5.0版本集群搭建不需要我们安装ruby就可以搭建成功

```sh
yum install ruby
yum install rubygems# ruby管理工具，管理redis的ruby包：redis.x.0.0.gem

需要下载拷贝redis.3.0.0.gem至/usr/local下 # 此处抄袭的redis4.0.0版本的方法
执行：
gem install /usr/local/redis.?.gem # 此处抄袭的redis4.0.0版本的方法

```



## 二、集群搭建

集群搭建规划

> 3个主节点，每个主节点对应1个从节点：需要6台服务机
>
> Master节点：192.168.1.102:7001 192.168.1.102:7003 192.168.1.102:7003 
>
> Slave   节点：192.168.1.102:7004 192.168.1.102:7005 192.168.1.102:7006 
>
> 在/usr/local/下创建redis-cluster存放6个节点的安装实例

搭建步骤

1. 安装redis到linux

2. 创建集群实例目录：mkdir redis-cluster

3. 创建6个redis实例,端口7001~7006

   ```sh
   cp -r redis/bin redis-cluster/redis01
   cp -r redis/bin redis-cluster/redis02
   cp -r redis/bin redis-cluster/redis03
   cp -r redis/bin redis-cluster/redis04
   cp -r redis/bin redis-cluster/redis05
   cp -r redis/bin redis-cluster/redis06
   ```

4. 修改配置文件redis.conf 

   ```sh
   1. port 6371 # // 7001~7006
   2. cluster-enable yes
   3. daemonize yes
   ```

   

5. 把创建集群的ruby脚本复制到redis-cluster目录下 

   ```sh
   cp redis5/src/*.rb ./redis-cluster/
   ```

   

6. 启动6个redis实例

   1. 在redis-cluster目录下

   2. 编辑启动脚本 startup-all.sh

      curDir=$(pwd)

      echo "cur dir is:$curDir"

      $curDir/redis01/redis-server redis.conf

      $curDir/redis02/redis-server redis.conf

      $curDir/redis03/redis-server redis.conf

      $curDir/redis04/redis-server redis.conf

      $curDir/redis05/redis-server redis.conf

      $curDir/redis06/redis-server redis.conf

   3. chmod 755 startup-all.sh
   4. 启动测试 sh startup-all.sh

6. 创建集群

    redis-cluster目录下

   ```sh
   ./redis-trib.rb create --replicas 1 192.168.1.102:7001 192.168.1.102:7002 192.168.1.102:7003 192.168.1.102:7004 192.168.1.102:7005 192.168.1.102:7006  
   ```

   ![image-20201122203842691](E:/summer/mylearn/redis/typora-user-images/image-20201122203842691.png)

- 会自动询问是否将7001~7004；7002~7005；7003~7006作为主从节点？yes同意即可
- slot槽分配：0~5460到master1，5461~10922到master2，10923~16383到master3 ，从节点没有槽点