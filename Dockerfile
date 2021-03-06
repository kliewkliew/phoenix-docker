FROM sequenceiq/hadoop-docker:2.7.0
MAINTAINER Kevin Liew, kliewkliew

# Zookeeper
ARG ZOOKEEPER_VERSION=3.4.8
RUN curl -s https://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./zookeeper-$ZOOKEEPER_VERSION zookeeper
ENV ZOO_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOO_HOME/bin
RUN mv $ZOO_HOME/conf/zoo_sample.cfg $ZOO_HOME/conf/zoo.cfg
RUN mkdir /tmp/zookeeper

# HBase
ARG HBASE_MAJORMINOR=1.1
ARG HBASE_PATCH=2
RUN curl -s https://archive.apache.org/dist/hbase/$HBASE_MAJORMINOR.$HBASE_PATCH/hbase-$HBASE_MAJORMINOR.$HBASE_PATCH-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hbase-$HBASE_MAJORMINOR.$HBASE_PATCH hbase
ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin

# Phoenix
ARG PHOENIX_VERSION=4.7.0
RUN curl -s https://archive.apache.org/dist/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJORMINOR/bin/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJORMINOR-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJORMINOR-bin phoenix
ENV PHOENIX_HOME /usr/local/phoenix
ENV PATH $PATH:$PHOENIX_HOME/bin
RUN ln -s $PHOENIX_HOME/phoenix-core-$PHOENIX_VERSION-HBase-$HBASE_MAJORMINOR.jar $HBASE_HOME/lib/phoenix.jar
RUN ln -s $PHOENIX_HOME/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJORMINOR-server.jar $HBASE_HOME/lib/phoenix-server.jar

# HBase and Phoenix configuration files
RUN rm $HBASE_HOME/conf/hbase-site.xml
RUN rm $HBASE_HOME/conf/hbase-env.sh
ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
ADD hbase-env.sh $HBASE_HOME/conf/hbase-env.sh

# bootstrap-phoenix
ADD bootstrap-phoenix.sh /etc/bootstrap-phoenix.sh
RUN chown root:root /etc/bootstrap-phoenix.sh
RUN chmod 700 /etc/bootstrap-phoenix.sh

CMD ["/etc/bootstrap-phoenix.sh", "-qs"]

# expose Zookeeper and Phoenix queryserver ports
EXPOSE 2181 8765
