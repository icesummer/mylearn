#!/bin/bash
cur_path=$(cd `dirname $0`; pwd)
cur_name="${project_path##*/}"
echo $cur_path
/usr/local/bin/redis-server $cur_path/7001/redis.conf
/usr/local/bin/redis-server $cur_path/7002/redis.conf
/usr/local/bin/redis-server $cur_path/7003/redis.conf
/usr/local/bin/redis-server $cur_path/7004/redis.conf
/usr/local/bin/redis-server $cur_path/7005/redis.conf
/usr/local/bin/redis-server $cur_path/7006/redis.conf
echo 'start cluster success'
# chmod +x start_cluster.sh
