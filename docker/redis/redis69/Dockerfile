# - ./conf:/usr/local/etc/redis
# 引入redis 5.0.5的镜像
#FROM redis:5.0.5
FROM centos
MAINTAINER icesummer <icessummer_u@qq.com>
RUN groupadd -r redis && useradd -r -g redis redis
RUN mkdir -p /data/conf && chown redis:redis /data
RUN mkdir -p /usr/local/redis6 && chown redis:redis /usr/local/redis6
ADD redis-6.0.9.tar.gz /usr/local/redis6/
RUN yum install -y gcc gcc-c++ epel-release net-tools make
WORKDIR /usr/local/redis6/redis-6.0.9/src/
RUN make && make install
COPY ./datadir/conf/redis.conf /data/conf/redis.conf
#expose 6381
CMD ["redis-server","/data/conf/redis.conf"]
