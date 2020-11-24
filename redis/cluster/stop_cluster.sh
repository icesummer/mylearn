#!bin/bash
## 关闭700x端口的redis节点：vim stop_cluster.sh
ps -ef | grep redis | grep 700 | grep -v grep | awk '{print $2}'| xargs kill -9
echo 'close cluster success'
## 关闭所有redis服务：pgrep redis-server | xargs -exec kill -9
#redis-cli --cluster create 192.168.1.201:7001 192.168.1.201:7002 192.168.1.201:7003 192.168.1.201:7004 192.168.1.201:7005 192.168.1.201:7006 --cluster-replicas 1

#redis-cli --cluster add-node 127.0.0.1:7004 127.0.0.1:7001 --cluster-slave --cluster-master-id f38845ab85a24db4521d226939f2a56d0c0742b5