# 1. NFS介绍

## **1.1 什么是NFS？**

- NFS是Network File System的缩写，中文意思是网络文件系统。
- 它的主要功能是通过网络（一般是局域网）让不同的主机系统之间可以共享文件或目录。
- NFS客户端（一般为应用服务器，例如web）可以通过挂载（mount）的方式将NFS服务器端共享的数据目录挂载到NFS客户端本地系统中（就是某一个挂载点下）。
- 从客户端本地看，NFS服务器端共享的目录就好像是客户端自己的磁盘分区或者目录一样，而实际上却是远端的NFS服务器的目录。
- NFS网络文件系统很像Windows系统的网络共享，安全功能，网络驱动器影射，这也和Linux系统里的samba服务类似。只不过一般情况下，Windows网络共享服务或samba服务用于办公局域网共享，而互联网中小型网站集群架构后端常用NFS进行数据共享。如果是大型网站，那么有可能会用到更复杂的分布式文件系统，例如：Moosefs（mfs），GlusterFS，FastDFS等。

## 1.2 NFS的历史介绍

- 1976年，第一个网络文件系统被成为File Access Listener

- NFS是第一个**构建于IP协议**之上的现代网络文件系统。

- 1980年，首先作为实验的文件系统，由Sun Microsystems在内部完成开发。

- NFS协议归属于Request for Comments（RFC）标准，并且随后演化为NFSv2。

- 随后，标准继续演化，成为NFSv3.

- 

   

   

NFS系统已经有了近30年的发展。它代表了一个非常稳定的（可移植）网络文件系统，具备可扩展、高性能等特性，并达到了企业级应用质量标准。

## 1.3 NFS在企业中的应用场景

在企业集群架构的工作场景中，NFS网络文件系统一般被用来存储共享视频，图片，附件等静态资源文件，通常网站用户上传的文件都会放到NFS共享里。

例如：BBS产品的图片，附件，头像（注意网站BBS程序不要放NFS共享里），然后前端所有的节点访问这些静态资源时都会读取NFS存储上的资源。

 

NFS是当前互联网系统架构中最常用的数据存储服务之一，前面说过，中小型网站公司应用频率更高，大公司或门户除了使用NFS外，还可能会使用更为复杂的分布式文件系统，比如Moosefs（mfs），GlusterFS，FastDFS等。

 

在企业生产集群架构中，NFS作为所有前端Web服务的共享存储，存储的内容一般包括网站用户上传的图片，附件，头像等，注意，网站的程序代码不要放NFS共享里，因为网站程序是开发运维人员统一发布的，不存在发布延迟问题，直接批量发布到Web节点提供访问比共享到NFS里访问效率更高。

![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191203172434039-1969132315.png)

## 1.4 **企业生产集群为什么需要共享存储角色？**

这里通过图解给大家展示以下集群架构需要共享存储服务的理由。

例如：

A用户上传图片到Web1服务器，然后让B用户访问这张图片，结果B用户访问的请求分发到了Web2，因为Web2上没有这张图片，这就导致它无法看到A用户上传的图片，如果此时有一个共享存储，A用户上传图片的请求无论是分发到Web1还是Web2上，最终都会存储到共享存储上，而在B用户访问图片时，无论请求分发到Web1还是Web2上，最终也都会去共享存储上找，这样就可以访问到需要的资源了。这个共享存储的位置可以通过开源软件和商业硬件实现，互联网中小型集群架构会用普通PC服务器配置NFS网络文件系统实现。

**当及集群中没有NFS共享存储时，用户访问图片的情况如下图所示。**

**![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191203172852902-331718757.png)**

 

 **下图是企业生产集群有NFS共享存储的情况：**

 ![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191203173315551-40067398.png)

 

 

中小型互联网企业一般不会买硬件存储，因为太贵，大公司如果业务发展很快的话，可能会临时买硬件存储顶一下网站压力，当网站并发继续加大时，硬件存储的扩展相对就会很费劲，且价格成几何级数增加。

例如：淘宝网就曾替换掉了很多硬件设备，比如，用lvs+haproxy替换了netscaler负载均衡设备，用FastDFS，TFS配合PC服务器替换了netapp，emc等商业存储设备，去IOE正在成为互联网公司的主流。



------

# 2. NFS系统原理介绍

## 2.1 NFS系统挂载结构图解与介绍

下图是企业工作中的NFS服务器与客户端挂载情况结构图：

![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191203174144872-1496239423.png)

 

 

在NFS服务器端设置好一个共享目录/video后，其他有权限访问NFS服务器端的客户端都可以将这个共享目录/video 挂载到客户端本地的某个挂载点（其实就是一个目录，这个挂载点目录可以自己随意指定）。上图中两个NFS 客户端本地的挂载点分别为/v/video和/video，不同的客户端的挂载点可以不相同。

客户端正确挂载完毕后，就可以通过NFS客户端的挂载点所在的/v/video或/video目录查看到NFS服务器端/video共享出来的目录下的所有数据。在客户端上查看时，NFS服务器端的/video目录就相当于客户端本地的磁盘分区或目录，几乎感觉不到使用上的区别，根据NFS服务端授予的NFS共享权限以及共享目录的本地系统权限，只要在指定的NFS客户端操作挂载/v/video或/video的目录，就可以将数据轻松地存取到NFS服务器端的/video目录中了。 

 

 

客户端挂载NFS后，本地挂载基本信息显示如下：

```
[root@nfs-client ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3       6.9G  1.5G  5.1G  23% /
tmpfs           499M     0  499M   0% /dev/shm
/dev/sda1       190M   36M  145M  20% /boot192.168.0.31:/video  1G  100M  900M 10% /video  # nfs服务器的ip地址和共享目录
```

 

挂载方式：

　　mount 源 目标

　　mount 192.168.0.31:/video /video

 

从挂载信息来看，和本地磁盘分区几乎没什么差别，只是文件系统对应列的开头是以IP地址开头的形式了。

 

 

 

经过前面的介绍，我们知道NFS系统是通过网络来进行数据传输的（所以叫做网络文件系统）因此，NFS会使用一些端口来传输数据，那么，**NFS到底使用哪些端口来进行数据传输呢？**

 

- NFS在传输数据时使用的端口会随机选择。

既然这样，**NFS客户端是怎么知道NFS服务端使用的哪个端口呢？**

 

- 答案就是通过RPC（中文意思远程过程调用，英文Remote Procedure Call简称RPC）协议/服务来实现，这个RPC服务的应用在门户级的网站有很多，例如：百度等。

 

 

## 2.2 什么是RPC

因为NFS支持的功能相当多，而不同的功能都会使用不同的程序来启动，每启动一个功能就会启用一些端口来传输数据，因此，NFS的功能所对应的端口无法固定，它会随机取用一些未被使用的端口来作为传输之用，其中CentOS5.x的随机端口都小于1024，而CentOS6.x的随机端口都是较大的。

因为端口不固定，这样一来就会造成NFS客户端与NFS服务端的通信障碍，因为NFS客户端必须要知道NFS服务端的数据传输端口才能进行通信，才能交互数据。

要解决上面的困扰，就需要通过**远程过程调用RPC服务**来帮忙了。

NFS的RPC服务最主要的功能：

- 就是记录每个NFS功能所对应的端口号，并且在NFS客户端请求时将该端口和功能对应的信息传递给请求数据的NFS客户端，从而确保客户端可以连接到正确的NFS端口上去，达到实现数据传输交互数据目的。
- 这个RPC服务类似NFS服务端和NFS客户端之间的一个中介。

![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191203183309857-1525695446.png)

 

 

就拿房屋中介打个比喻吧：

假设我们要找房子，这里的我们就相当于NFS客户端，中介介绍房子，中介就相当于RPC服务，房子所有者房东就相当于NFS服务，租房的人找房子，就要找中介，中介要预先存有房子主人房东的信息，才能将房源信息告诉租房的人。

**那么RPC服务又是如何知道每个NFS的端口呢？**

- 这是因为，当NFS服务端启动服务时会随机取用若干端口，并主动向RPC服务注册取用的相关端口及功能信息，如此一来，RPC服务就知道NFS每个端口对应的NFS功能了，然后RPC服务使用固定的111端口来监听NFS客户端提交的请求，并将正确的NFS端口信息回复给请求的NFS客户端，这样一来，NFS客户端就可以与NFS服务端进行数据传输了。
- 在启动NFS SERVER之前，首先要启动RPC服务（CentOS5.x下为portmap服务，CentOS6.x下为rpcbind服务，下同），否则NFS SERVER就无法向RPC服务注册了。
- 另外，如果RPC服务重新启动，原来已经注册好的NFS端口数据就会丢失，因此，此时RPC服务管理的NFS程序也需要重新启动以重新向RPC注册。
- 要特别注意的是，一般修改NFS配置文件后，是不需要重启NFS的，直接在命令行执行/etc/init.d/nfs reload或exportfs -rv即可使修改的/etc/exports生效。

 

## 2.3 NFS的工作流程原理

![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191203184445890-1521135757.png)

 

 

 

![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191203184525705-1209076905.png)

 

 ![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191208182650427-301374899.png)

 

 

 

当访问程序通过NFS客户端向NFS服务端存取文件时，其请求数据流程大致如下：

1）首先用户访问网站程序，由程序在NFS客户端上发出存取NFS文件的请求，这时NFS客户端（即执行程序的服务器）的RPC服务（rpcbind服务）就会通过网络向NFS服务器端的RPC服务（rpcbind服务）的111端口发出NFS文件存取功能的询问请求。

2）NFS服务端的RPC服务（rpcbind服务）找到对应的已注册的NFS端口后，通知NFS客户端的RPC服务（rpcbind服务）

3）此时NFS客户端获取到正确的端口，并与NFS daemon联机存取数据

4）NFS客户端把数据存取成功后，返回给前端访问程序，告知给用户存取结果，作为网站用户，就完成了一次存取操作。

 

因为NFS的各项功能都需要向RPC服务（rpcbind服务）注册，所以只有RPC服务（rpcbind服务）才能获取到NFS服务的各项功能对应的端口号（port number），PID，NFS在主机所监听的IP等信息，而NFS客户端也只能通过向RPC服务（rpcbind服务）询问才能找到正确的端口。

也就是说，NFS需要有RPC服务（rpcbind服务）的协助才能成功对外提供服务。

从上面的描述，我们不难推断，无论是NFS客户端还是NFS服务器端，当要使用NFS时，都需要首先启动RPC服务（rpcbind服务），NFS服务必须在RPC服务启动之后启动，客户端无需启动NFS服务，但需要启动RPC服务。

**注意：**
NFS的RPC服务，在CentOS5.X下名称为portmap，在CentOS6.x下名称为rpcbind

 

------

 

# 3. NFS部署

## 3.1 服务端和客户端的环境准备

### （统一使用模版机进行克隆）

### 3.1.1 角色-ip

| 角色               | 主机名 | eth0（外网） | eth1（内网） |
| ------------------ | ------ | ------------ | ------------ |
| C1-NFS服务器端     | nfs01  | 10.0.0.31    | 192.168.0.31 |
| C2-Rsync存储服务器 | backup | 10.0.0.41    | 192.168.0.41 |
| B2-nginx web服务器 | web01  | 10.0.0.8     | 192.168.0.8  |

### 3.1.2 主机名设置

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@web01-8 ~]# hostname
web01-8
[root@web01-8 ~]# cat /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=web01-8# 其它两台机器分别为：[root@nfs-31 ~]# hostname nfs-31
```

　[root@backup-41 ~]# hostname
　　backup-41

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

### 3.1.3 操作系统和内核版本

```
[root@web01-8 ~]# cat /etc/redhat-release 
CentOS release 6.7 (Final)
[root@web01-8 ~]# uname -r
2.6.32-573.el6.x86_64
```

 

### 3.1.4 /etc/hosts本地dns解析文件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@web01-8 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.5 lb01
192.168.0.6 lb02
192.168.0.7 web02
192.168.0.8 web01
192.168.0.51 db01 
192.168.0.31 nfs01
192.168.0.41 backup
192.168.0.61 m01
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

## 3.2 NFS 服务端的设置

### 3.2.1 NFS软件列表

要部署NFS服务，需要安装下面的软件包：

- - nfs-utils:
    NFS服务的主程序，包括rpc.nfsd, rpc.mountd这两个daemons和相关文档说明，以及执行命令文件等。
  - rpcbind:
    CentOS6.X下面RPC的主程序。NFS可以视为一个RPC程序，在启动任何一个RPC程序之前，需要做好端口和功能的对应映射工作，这个映射工作就是由rpcbind服务来完成的。因此，在提供NFS服务之前必须先启动rpcbind服务才行。

### 3.2.2 查看NFS软件包

可使用如下命令查看默认情况下CentOS6.x里NFS软件的安装情况。

　　　　rpm -qa nfs-utils rpcbind

如果未安装，则使用yum -y install nfs-utils rpcbind 安装。

当不知道软件名字时候，可以用`rpm -qa | grep -E "nfs-|rpcbind"`来过滤包含在引号内的字符串。

CentOS6.8默认没有安装NFS软件包，可以使用`yum -y install nfs-utils rpcbind`命令来安装NFS软件。

 

### 3.2.3 启动NFS相关服务

**启动rpcbind**

因为NFS及其辅助程序都是基于RPC（remote Procedure Call）协议的（使用的端口为111），所以首先要确保系统中运行了rpcbind服务。

启动的实际操作如下：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@web01-8 ~]# /etc/init.d/rpcbind status  # 查看rpcbind服务状态
rpcbind is stopped
[root@web01-8 ~]# /etc/init.d/rpcbind start  # 启动rpcbind服务
Starting rpcbind:                                          [  OK  ]
[root@web01-8 ~]# rpcinfo -p localhost   # 查看NFS服务向rpc服务注册的端口信息，因为NFS还未启动，因此，没有太多注册的端口影射信息。
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

注意：111端口为rpcbind服务对外提供服务的主端口。

通过chkconfig命令查看开机自启动服务中rpcbind的状态。

```
[root@web01-8 packages]# chkconfig --list rpcbind
rpcbind         0:off   1:off   2:on    3:on    4:on    5:on    6:off
```

 

如果rpcbind服务未启动，执行rpcinfo -p localhost检查时，会报如下错误。

rpcinfo: can't contact portmapper: RPC: Remote system error - Connection refused

即：rpcinfo无法同portmapper交互：RPC：远程系统错误-拒绝连接。

解决办法：执行/etc/init.d/rpcbind start启动rpcbind服务即可。

 

**启动NFS服务**

```
[root@web01-8 ~]# /etc/init.d/nfs start
Starting NFS services:                                     [  OK  ]
Starting NFS quotas:                                       [  OK  ]
Starting NFS mountd:                                       [  OK  ]
Starting NFS daemon:                                       [  OK  ]
正在启动 RPC idmapd：                                      [确定]
```

 

注意：如果不启动rpcbind服务，直接启动nfs服务，会启动失败。

 

**查看NFS服务向rpc服务注册的端口信息：**

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@web01-8 packages]# rpcinfo -p localhost
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100011    1   udp    875  rquotad
    100011    2   udp    875  rquotad
    100011    1   tcp    875  rquotad
    100011    2   tcp    875  rquotad
    100005    1   udp  56093  mountd
    100005    1   tcp  61293  mountd
    100005    2   udp  52653  mountd
    100005    2   tcp  35532  mountd
    100005    3   udp  60787  mountd
    100005    3   tcp  56885  mountd
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    2   tcp   2049  nfs_acl
    100227    3   tcp   2049  nfs_acl
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl
    100021    1   udp  12625  nlockmgr
    100021    3   udp  12625  nlockmgr
    100021    4   udp  12625  nlockmgr
    100021    1   tcp  29370  nlockmgr
    100021    3   tcp  29370  nlockmgr
    100021    4   tcp  29370  nlockmgr
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**NFS服务常见进程说明：**

从上面NFS服务启动过程可以看出，运行NFS服务默认需要启动的服务或进程有：

- NFS quotas(rpc.rquotad) 磁盘配额进程，remote quota server
- NFS daemon(nfsd)  nfs主进程
- NFS mountd(rpc.mountd)。 权限管理验证等，NFS mount daemon

可以通过执行如下命令查看启动NFS后，系统中运行的NFS相关进程：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@web01-8 packages]# ps -ef|egrep 'rpc|nfs'
rpc       5624     1  0 16:48 ?        00:00:00 rpcbind
root      5668     2  0 16:51 ?        00:00:00 [rpciod/0]
root      5677     1  0 16:51 ?        00:00:00 rpc.rquotad  # 磁盘配额进程remote quota server
root      5682     1  0 16:51 ?        00:00:00 rpc.mountd  # 权限管理验证等 NFS mount daemon
root      5689     2  0 16:51 ?        00:00:00 [nfsd4]
root      5690     2  0 16:51 ?        00:00:00 [nfsd4_callbacks]
root      5691     2  0 16:51 ?        00:00:00 [nfsd]  # nfs主进程
root      5692     2  0 16:51 ?        00:00:00 [nfsd]  # nfs主进程
root      5693     2  0 16:51 ?        00:00:00 [nfsd]  
root      5694     2  0 16:51 ?        00:00:00 [nfsd] 
root      5695     2  0 16:51 ?        00:00:00 [nfsd]
root      5696     2  0 16:51 ?        00:00:00 [nfsd]
root      5697     2  0 16:51 ?        00:00:00 [nfsd]
root      5698     2  0 16:51 ?        00:00:00 [nfsd]
root      5729     1  0 16:51 ?        00:00:00 rpc.idmapd  # name mapping daemon
root      5870  5503  0 18:20 pts/0    00:00:00 grep -E rpc|nfs
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

NFS服务的主要任务是共享文件系统数据，而文件系统数据的共享离不开权限问题。

所以NFS服务器启动时最少需要两个不同的进程：

- 管理NFS客户端是否能够登入的rpc.nfsd主进程
- 管理NFS客户端是否能够取得对应权限的rpc.mountd进程。
- 如果还需要管理磁盘配额，则NFS还要再加载rpc.rquotad进程。

| 服务或进程名        | 用途说明                                                     |
| ------------------- | ------------------------------------------------------------ |
| nfsd(rpc.nfsd)      | rpc.nfsd主要功能是管理NFS客户端是否能够登入NFS服务端主机，其中还包含登入者的ID判别等 |
| mountd(rpc.mountd)  | rpc.mountd的主要功能则是管理NFS文件系统。当NFS客户端顺利通过rpc.nfsd登入NFS服务端主机时，在使用NFS服务器提供数据之前，它会去读NFS的配置文件/etc/exports来比对NFS客户端的权限，通过这一关之后，还会经过NFS服务端本地文件系统使用权限（就是owner，group，other权限）的认证程序。如果都通过了，NFS客户端就可以取得使用NFS服务器端文件的权限。注意，这个/etc/exports文件也是我们用来管理NFS共享目录的使用权限与安全设置的地方，特别强调，NFS本身设置的是网络共享权限，整个共享目录的权限还和目录自身系统权限有关。 |
| rpc.lockd(非必需)   | 可用来锁定文件，用于多客户端同时写入。                       |
| rpc.statd（非必须） | 检查文件的一致性，与rpc.lockd有关。c，d两个服务需要客户端、服务端同时开启才可以；rpc.statd监听来自其它主机重启的通知，并且管理当本地系统重启时主机列表。 |
| rpc.idmapd          | 名字映射后台进程                                             |

查看以上进程，均可以用man 进程名 的方式查看相关说明。

 

**配置NFS服务器端服务开机自启动**

```
[root@web01-8 packages]# chkconfig rpcbind on
[root@web01-8 packages]# chkconfig nfs on
```

特别说明：
在很多大企业里，大都是统一按照运维规范将服务的启动命令放到/etc/rc.local文件里的，而不是用chkconfig管理的。

把/etc/rc.local文件作为本机的重要服务档案文件，所有服务的开机自启动都必须放入/etc/rc.local。

这样规范的好处是，一旦管理此服务器的人员离职，或者业务迁移都可以通过/etc/rc.local很容易的查看到服务器对应的相关服务，可以方便的运维管理。

下面是把启动命令放入到/etc/rc.local文件中的配置信息，注意别忘了加上启动服务的注释。

```
[root@web01-8 packages]# tail -3 /etc/rc.local
# start up nfs service
/etc/init.d/rpcbind start
/etc/init.d/nfs start
```

 

## 3.3 配置NFS服务端

### 3.3.1 NFS服务端配置文件路径

**NFS服务的默认配置文件路径为：/etc/exports，并且默认是空的。**

```
[root@web01-8 packages]# ls -l /etc/exports
-rw-r--r-- 1 root root 0 Jan 12  2010 /etc/exports
[root@web01-8 packages]# cat /etc/exports
```

**提示：**
NFS默认配置文件/etc/exports其实是存在的，但是没有内容，需要用户自行配置。

可以通过man exports查看配置文件说明，和rsync的配置文件man rsyncd.conf查看方式是一致的。

### 3.3.2 exports配置文件格式

/etc/exports文件位置格式为：

```
NFS共享的目录 NFS客户端地址1（参1，参2...）客户端地址2（参1，参2...）

NFS共享的目录 NFS客户端地址（参1，参2...）
```

 

查看exports语法文件格式帮助的方法为：
执行man exports命令，然后切换到文件结尾，可以快速看如下样例格式：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
# sample /etc/exports file
       /               master(rw) trusty(rw,no_root_squash)
       /projects       proj*.local.domain(rw)
       /usr            *.local.domain(ro) @trusted(rw)
       /home/joe       pc001(rw,all_squash,anonuid=150,anongid=100)
       /pub            *(ro,insecure,all_squash)
       /srv/www        -sync,rw server @trusted @external(ro)
       /foo            2001:db8:9:e54::/64(rw) 192.0.2.0/24(rw)
       /build          buildhost[0-9].local.domain(rw)
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

上述各个列的参数含义如下：

- NFS共享的目录：为NFS服务器端要共享的实际目录，要用绝对路径。注意共享目录的本地权限，如果需要读写权限，一定要让本地目录可以被NFS客户端的用户nfsnobody读写
- NFS客户端地址：为NFS服务器端授权的可访问共享目录的NFS客户端地址，可以为单独的IP地址或主机名、域名等，也可以为整个网段地址，还可以用“*”来匹配所有客户端服务器，这里所谓的客户端，一般来说是前端的业务服务器，如：Web服务。
- 权限参数集：对授权的NFS客户端的访问权限设置。

| 客户端地址             | 具体地址      | 说明                                                 |
| ---------------------- | ------------- | ---------------------------------------------------- |
| 授权单一客户端访问NFS  | 10.0.0.30     | 一般情况，生产环境中此配置不多                       |
| 授权整个网段可访问NFS  | 10.0.0.0/24   | 指定网段为生产环境中最常见的配置。配置简单，维护方便 |
| 授权整个网段可访问NFS  | 10.0.0.*      | 指定网段的另一种写法（不推荐使用）                   |
| 授权某个域名客户端访问 | nfs.baidu.com | 生产环境中不常用                                     |
| 授权整个域名客户端访问 | *.baidu.com   | 生产环境中不常用                                     |

###  3.2.3 企业生产场景NFS exports配置实例

**配置例1: /data 10.0.0.0/24(rw,sync)** 

允许客户端读写，并且数据同步写到服务器端的磁盘里，注意，24和“(”之间不能有空格。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@nfs-31 ~]# mkdir /data -p  
[root@nfs-31 ~]# id nfsnobody  # nfs用rpm安装时，会自动创建虚拟用户nfsnobody
uid=65534(nfsnobody) gid=65534(nfsnobody) 组=65534(nfsnobody)
[root@nfs-31 ~]# ls -ld /data
drwxr-xr-x. 8 root root 4096 8月  31 23:21 /data
[root@nfs-31 ~]# chown -R nfsnobody.nfsnobody /data
[root@nfs-31 ~]# ls -ld /data                      
drwxr-xr-x. 8 nfsnobody nfsnobody 4096 8月  31 23:21 /data
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

配置/etc/exports配置文件：

```
[root@nfs-31 ~]# cat /etc/exports
# shared /data by zoe for test at 20191205
/data 192.168.0.0/24(rw,sync)
```

修改配置文件后，平滑重启nfs服务：

```
[root@nfs-31 ~]# /etc/init.d/nfs reload
[root@nfs-31 ~]# showmount -e 192.168.0.31  # 查看生效的nfs配置文件规则
Export list for 192.168.0.31:
/data 192.168.0.0/24
```

说明：

- /data为要共享的NFS服务器端的目录，注意，被共享的目录一定要用绝对路径
- 10.0.0.0/24 表示允许NFS客户端访问共享目录的网段范围。
- (rw,sync)中的rw表示允许读写，sync表示数据同步写入到NFS服务器端的硬盘中
- 也可以用通配符*替换IP地址，表示允许所有主机，也可以写成10.0.0.*的形式
- 如果不授权属主，数组，那么共享目录挂载以后，将不遵循配置文件exports的设定好的读写规则。虽然能正常挂载，但是会导致写入文件时提示没有权限。
- 修改配置文件后，必须重启nfs服务（reload，平滑重启，相当于exportfs -rw）
- showmount -e ip地址，查看生效的nfs配置文件规则

 

**配置例2: /data/blog 10.0.0.0/24(rw, sync, all_squash, anonuid=2000,anongid=2000)**

允许客户端读写，并且数据同步写到服务器端的磁盘里，并且指定客户端的用户UID和GID。

早期生产环境的一种配置，适合多客户端共享一个NFS服务单目录，如果所有服务器的nfsnobody账户UID都是65534，则本例没什么必要了。

早期CentOS 5.5 系统默认情况下nfsnobody的UID不一定是65524，此时如果这些服务器共享一个NFS目录，就会出现访问权限问题。

 

**配置例3: /home/oldboy 10.0.0.0/24(ro)**

用途：在生产环境中，开发人员有查看生产服务器日志的需求，但又不希望给开发生产服务器的权限，那么就可以给开发提供从某个测试服务器NFS客户端上查看某个生产服务器的日志目录（NFS共享）的权限。

 

## 3.4 NFS配置参数权限

即/etc/exports文件配置格式中小括号()里的参数集。

- **rw**  read-write，可读写

- ro  read-only，只读

- **sync** （同步，实时）请求或写入数据时，数据同步写入到NFS Server的硬盘后才返回。数据安全不会丢，但是性能比不启用该参数要差。

- async （异步）写入时数据会先写到内存缓冲区，直到硬盘有空档才会再写入磁盘，这样可以提升写入效率！风险是服务器宕机或不正常关机，可能会丢失buffer的数据。

- no_root_squash 访问NFS Server共享目录的用户如果是root的话，对该共享目录具有root权限。这个配置是未无盘客户端准备的。用户应避免使用/

- root_squash 访问NFS Server共享目录的用户是root，则它的权限将被压缩成匿名用户，同时它的UID和GID通常会变成nfsnobody账号身份

- all_squash

   不管访问NFS Server共享目录的用户身份如何，它的权限都将被压缩成匿名用户，同时UID和GID都会变成nfsnobody的账号身份。

  - 在早期多个NFS客户端同时读写NFS Server数据时，这个参数很有用
  - 在生产中配置NFS的重要技巧：
    - 确保所有客户端服务器对NFS共享目录具备相同的用户访问权限
      - all_squash把所有客户端都压缩成固定的匿名用户（UID相同）
      - 就anonuid，anongid指定的UID和GID的用户
    - 所有的客户端和服务器端都需要有一个相同的UID和GID的用户，即nfsnobody（UID必须相同）

- anonuid 参数以anon*开头，即指anonymous匿名用户，这个用户的UID设置值通常为nfsnobody的UID值，当然也可以自行设置这个UID值。

  - 这个指定的UID必须存在/etc/passwd中
  - 在多NFS 客户端时，如多台Web Server共享一个NFS目录，通过这个参数可以使得不同的NFS客户端写入数据时对所有NFS客户端保持同样的用户权限，即为配置的匿名UID对应用户权限，这个参数很有用，一般默认即可。

- anongid 同anonuid，区别就是把uid换成gid

 可以通过man exports查阅更多exports参数说明。

 

配置好NFS服务后，通过cat /var/lib/nfs/etab 命令可以看到NFS配置的参数以及默认自带的参数。

```
[root@nfs-31 ~]# cat /var/lib/nfs/etab
/data   192.168.0.0/24(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534,sec=sys,rw,root_squash,no_all_squash)
```

 

一般情况下， 大多数参数我们不需要理会。

 

![img](https://img2018.cnblogs.com/blog/1162655/201912/1162655-20191209174041784-1655525203.png)

 

 

 

## 3.5 NFS服务企业案例配置实践

将NFS服务端上的/data目录共享给192.168.0.0/24 整个网段的主机，且可读写。

 

### 【NFS服务端】

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
# 系统环境
[root@nfs-31 mnt]# cat /etc/redhat-release 
CentOS release 6.10 (Final)
[root@nfs-31 mnt]# uname -r
2.6.32-573.el6.x86_64
[root@nfs-31 mnt]# uname -m
x86_64

# 查看rpcbind和nfs服务，并设置开机自启动
[root@nfs-31 mnt]# rpm -qa nfs-utils rpcbind
rpcbind-0.2.0-16.el6.x86_64
nfs-utils-1.2.3-78.el6_10.1.x86_64

[root@nfs-31 mnt]# /etc/init.d/rpcbind status
rpcbind 已停
[root@nfs-31 mnt]# /etc/init.d/rpcbind start
正在启动 rpcbind：                                         [确定]

[root@nfs-31 mnt]# /etc/init.d/nfs status
rpc.svcgssd 已停
rpc.mountd 已停
nfsd 已停
rpc.rquotad 已停
[root@nfs-31 mnt]# /etc/init.d/nfs start
启动 NFS 服务：                                            [确定]
关掉 NFS 配额：                                            [确定]
启动 NFS mountd：                                          [确定]
启动 NFS 守护进程：                                        [确定]
正在启动 RPC idmapd：                                      [确定]

[root@nfs-31 mnt]# chkconfig --list rpcbind
rpcbind         0:关闭  1:关闭  2:启用  3:启用  4:启用  5:启用  6:关闭
[root@nfs-31 mnt]# chkconfig --list nfs
nfs             0:关闭  1:关闭  2:启用  3:启用  4:启用  5:启用  6:关闭

[root@nfs-31 mnt]# tail -3 /etc/rc.local  # chkconfig和/etc/rc.local的配置二选一即可。
# start up nfs service
/etc/init.d/rpcbind start
/etc/init.d/nfs start


# 创建需要共享的目录并授权
mkdir /data -p
grep nfsnobody /etc/passwd
chown -R nfsnobody.nfsnobody /data
ls -ld /data


# 配置NFS服务配置文件，并且在本地查看挂载信息
[root@nfs-31 mnt]# cat /etc/exports
# shared /data by zoe for test at 20191205
/data 192.168.0.0/24(rw,sync)

[root@nfs-31 mnt]# exportfs -rv # 加载配置，可以用来检查配置文件是否合法
exporting 192.168.0.0/24:/data

# 在NFS服务器本地查看挂载情况
showmount -e 192.168.0.31
showmount -e localhost

# 通过查看nfs服务器配置文件的参数（包括默认加载的参数）
[root@nfs-31 mnt]# cat /var/lib/nfs/etab
/data   192.168.0.0/24(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534,sec=sys,rw,root_squash,no_all_squash)
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

在本地服务器端，同时又作为客户端进行挂载测试：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@nfs-31 mnt]# mount -t nfs 192.168.0.31:/data /mnt
[root@nfs-31 mnt]# df -h
Filesystem          Size  Used Avail Use% Mounted on
/dev/sda3           6.9G  1.9G  4.7G  28% /
tmpfs               499M     0  499M   0% /dev/shm
/dev/sda1           190M   67M  114M  37% /boot
192.168.0.31:/data  6.9G  1.9G  4.7G  28% /mnt
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

看上成功将nfs的共享目录挂载在/mnt目录下。

 

说明：

- /data为要共享的NFS服务器端的目录，注意，被共享的目录一定要用绝对路径
- 10.0.0.0/24 表示允许NFS客户端访问共享目录的网段范围。
- (rw,sync)中的rw表示允许读写，sync表示数据同步写入到NFS服务器端的硬盘中
- 也可以用通配符*替换IP地址，表示允许所有主机，也可以写成10.0.0.*的形式
- 如果不授权属主，数组，那么共享目录挂载以后，将不遵循配置文件exports的设定好的读写规则。虽然能正常挂载，但是会导致写入文件时提示没有权限。
- 修改配置文件后，必须重启nfs服务（reload，平滑重启，相当于exportfs -rw）
- showmount -e ip地址，查看生效的nfs配置文件规则

 

### 【NFS客户端】

在所有的NFS客户端上执行的操作都是相同的。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
# 系统环境
[root@backup-41 ~]# cat /etc/redhat-release 
CentOS release 6.10 (Final)
[root@backup-41 ~]# uname -r
2.6.32-573.el6.x86_64
[root@backup-41 ~]# uname -m
x86_64

# 检查安装包
[root@backup-41 ~]# rpm -qa rpcbind
rpcbind-0.2.0-16.el6.x86_64
# 为了使用showmount等功能，所有客户端最好也安装NFS软件，但不启动NFS服务
rpm -qa nfs-utils

# 启动rpc服务（不需要启动NFS服务）
[root@backup-41 ~]# /etc/init.d/rpcbind status
rpcbind is stopped
[root@backup-41 ~]# /etc/init.d/rpcbind start
Starting rpcbind:                                          [  OK  ]

[root@backup-41 ~]# showmount -e 192.168.0.31
Export list for 192.168.0.31:
/data 192.168.0.0/24

# 挂载NFS共享目录/data
[root@backup-41 ~]# mount -t nfs 192.168.0.31:/data /mnt
[root@backup-41 ~]# df -h
Filesystem          Size  Used Avail Use% Mounted on
/dev/sda3           6.9G  1.9G  4.7G  28% /
tmpfs               499M     0  499M   0% /dev/shm
/dev/sda1           190M   67M  114M  37% /boot
192.168.0.31:/data  6.9G  1.9G  4.7G  28% /mnt

# 测试
[root@backup-41 mnt]# cd /mnt
[root@backup-41 mnt]# ls
[root@backup-41 mnt]# mkdir /mnt/backup/rpcbind/test -p
[root@backup-41 mnt]# ls
backup  file

# 在nfs服务端查看共享目录/data
[root@nfs-31 mnt]# ls /data
backup  file
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

将rpcbind服务和挂载加入开机自启动：

```
[root@backup-41 mnt]# tail -3 /etc/rc.local
# rpcbind start and mount shared directory ip:/data
/etc/init.d/rpcbind start
/bin/mount -t nfs 192.168.0.31:/data /mnt
```

 

 

 

# 4. NFS服务的重点知识梳理

当多个NFS客户端访问服务器端的读写文件时，需要具有以下几个权限：

- NFS服务器/etc/exports设置需要开放可写入的权限，即服务器端的共享权限
- NFS服务器实际要共享的NFS目录权限具有可写入w的权限，即服务端本地目录的安全权限。
- 每台机器都对应存在和NFS默认配置UID的相同UID 65534的nfsnobody用户
  - 确保所有客户端的访问权限统一，否则每个机器需要同时建立相同UID的用户，并覆盖NFS的默认用户配置。

只有满足上述三个条件，多个NFS客户端才能具有查看、修改、删除其它任意NFS客户端上传文件的权限。

这在大规模的集群环境中作为集群共享存储时，尤为重要。

 

**重点NFS服务文件或命令的说明：**

\1. /etc/exports  NFS服务主配置文件，配置NFS具体共享服务的地点，默认内容为空，以行为单位。

\2. /usr/sbin/exportfs NFS服务的管理命令。

例如：

　　可以加载NFS配置生效，还可以直接配置NFS共享目录，即，无需配置/etc/exports实现共享。

　　exportfs -rv  加载配置生效，等价优雅平滑重启/etc/init.d/nfs reload。

　　exportfs不但可以加载配置生效，也可以通过命令直接共享目录，越过/etc/exports，但是重启失效。

 

\3. /usr/sbin/showmount 在客户端查看NFS配置及挂载结果的命令。配置nfsserver，分别在服务器端和客户端查看挂载情况

\4. /var/lib/nfs/etab  NFS配置文件的完整参数设定的文件（有很多没有配置，但是默认就有的NFS参数）

\5. /var/lib/nfs/xtab  适合centos5，centos6没有该文件

\6. /proc/mounts  客户端挂载参数

```
[root@backup-41 mnt]# grep mnt /proc/mounts
192.168.0.31:/data/ /mnt nfs4 rw,relatime,vers=4,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.41,minorversion=0,local_lock=none,addr=192.168.0.31 0 0
```

\7. /var/lib/nfs/rmtab  客户端访问服务器exports的信息列表

 

 

# 5. NFS客户端挂载命令

## 5.1 NFS客户端挂载命令格式

　　mount -f nfs 192.168.0.31:/data /mnt

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
# 挂载前首先检查有权限需要挂载的信息，是否能够挂载
showmount -e 192.168.0.31  

# 执行挂载命令挂载
mount -t nfs 192.168.0.31:/data /mnt

# 查看挂载后结果
df -h

# 查看挂载后结果
mount # 和cat /proc/mounts类似
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

## 5.2 NFS客户端挂载排错思路

- 确认NFS服务器端的设置和服务是否ok。
  - showmount -e 192.168.0.31
  - 在服务器端测试是否可以挂载成功
- 确认NFS客户端的showmount是否ok
  - 如：ping server_ip
  - telnet server_ip 111 

 

## 5.3 NFS客户端开机自启动挂载

方法1: 配置/etc/rc.local

```
[root@backup-41 mnt]# tail -3 /etc/rc.local
# rpcbind start and mount shared directory ip:/data
/etc/init.d/rpcbind start
/bin/mount -t nfs 192.168.0.31:/data /mnt
```

 

方法2: 将挂载命令放在/etc/fstab里

```
[root@web01 ~]# tail -1 /etc/fstab 
192.168.0.31:/data   /mnt            nfs defaults        0 0
```

 

其实所谓配置方法，这里有一个误区，如下：

- fstab会优先于网络被Linux系统加载。网络没启动时执行fstab会导致连不上NFS服务器端，无法实现开机挂载。
- 而且，即使是本地的文件系统，也要注意，fstab最后两列要设置0 0.否则有可能导致无法启动服务器的问题。
- 因此，nfs网络文件系统**最好不要放到fstab里实现开机挂载**。
- 但是，如果是在开机自启动服务里设置并启动了netfs服务，放入fstab里也是可以开机挂载的。

 

# 6. 生产环境高级案例配置实战

## 6.1 指定固定的UID用户配置NFS共享的实例

指定固定的UID用户配置NFS共享在CentOS 5.5及以下生产环境中常用，在CentOS 6.x的场景中不是必须要用的。

在CentOS5.5系统中，NFS有个bug，就是没有UID为65534的nfsnobody的用户，导致需要手动指定固定用户，确保NFS服务端和所有的NFS客户端都能实现对共享目录的增删改查。

客户端和服务端建立统一的NFS用户：用户、UID和GID。

 

步骤1: 建立用户组zuma并指定GID 888，所有客户端也要用同样的命令建立。

```
[root@nfs-31 proc]# groupadd zuma -g 888
```

 

步骤2：建立用户zuma，指定UID为888，且用户组属于zuma，所有客户端同样。

```
useradd zuma -u 888 -g zuma
[root@web01-8 mnt]# id zuma
uid=888(zuma) gid=888(zuma) 组=888(zuma)
```

 

步骤3: 开始部署NFS Server

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@nfs-31 /]# mkdir /oldboy -p
[root@nfs-31 /]# chown -R zuma.zuma /oldboy
[root@nfs-31 /]# ls -ld /oldboy
drwxr-xr-x 2 zuma zuma 4096 Dec  9 21:26 /oldboy

# 编辑/etc/exports配置文件
[root@nfs-31 /]# echo "#new example">>/etc/exports
[root@nfs-31 /]# echo "/oldboy 192.168.0.0/24(rw,sync,all_squash,anonuid=888,anongid=888)">>/etc/exports
[root@nfs-31 /]# tail -2 /etc/exports
#new example
/oldboy 192.168.0.0/24(rw,sync,all_squash,anonuid=888,anongid=888)

# 配置完成后，nfs服务平滑重启
[root@nfs-31 /]# /etc/init.d/nfs reload

# 查看是否部署完成
[root@nfs-31 /]# showmount -e localhost
Export list for localhost:
/oldboy 192.168.0.0/24
/data   192.168.0.0/24
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

步骤4: 部署nfs客户端

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@backup-41 mnt]# mkdir /video -p
[root@backup-41 mnt]# /etc/init.d/rpcbind status
rpcbind (pid  10434) is running...
[root@backup-41 mnt]# showmount -e 192.168.0.31
Export list for 192.168.0.31:
/oldboy 192.168.0.0/24
/data   192.168.0.0/24
[root@backup-41 mnt]# mount -t nfs 192.168.0.31:/oldboy /video  
[root@backup-41 mnt]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda3             6.9G  1.9G  4.7G  28% /
tmpfs                 499M     0  499M   0% /dev/shm
/dev/sda1             190M   67M  114M  37% /boot
192.168.0.31:/data    6.9G  1.9G  4.7G  28% /mnt
192.168.0.31:/oldboy  6.9G  1.9G  4.7G  28% /video
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

步骤5: 在客户端上进行测试

```
[root@backup-41 mnt]# cd /video
[root@backup-41 video]# ls
[root@backup-41 video]# touch test.txt
[root@backup-41 video]# ls -l
total 0
-rw-r--r-- 1 zuma zuma 0 Dec  9 21:39 test.txt # 用户和组都是zuma
```

 

> [文章来源](https://www.cnblogs.com/zoe233/p/11973710.html)





完成。