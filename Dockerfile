FROM harbor.eniot.io/envisioniot/java8:latest

MAINTAINER alan.wang<alan.wang@envision-digital.com>

USER root

#RUN useradd -u 1001 -r -g 0 -s /sbin/nologin \
#            -c "Default Application User" atlas
# 定义环境变量
# ssm streaming-state-mgmt-web
ENV APP_NAME atlas
ENV APP_DIR /home/atlas/
ENV ATLAS_TOOLS_DIR $APP_DIR/tools

RUN mkdir -p $ATLAS_TOOLS_DIR
# 复制文件夹

COPY ./target/atlas.tar.gz $APP_DIR
COPY ./target/atlas-index-repair/target/atlas-index-repair-tool-*.jar $ATLAS_TOOLS_DIR
COPY ./target/atlas-index-repair/target/classes/repair_index.py $ATLAS_TOOLS_DIR
COPY ./target/ik-analyzer-8.3.0.jar $APP_DIR

WORKDIR $APP_DIR

RUN tar -zxvf atlas.tar.gz
RUN mv apache-atlas-* $APP_NAME
COPY ./startup.sh $APP_DIR/atlas/bin
RUN mkdir -p $APP_DIR/atlas/dumps
RUN rm $APP_DIR/atlas/solr/server/solr/configsets/_default/conf/managed-schema
RUN rm $APP_DIR/atlas/solr/server/solr/configsets/_default/conf/solrconfig.xml
RUN cp $APP_DIR/atlas/solr/contrib/analysis-extras/lucene-libs/lucene-analyzers-smartcn-7.5.0.jar $APP_DIR/atlas/solr/server/solr-webapp/webapp/WEB-INF/lib/
RUN mv $APP_DIR/ik-analyzer-8.3.0.jar $APP_DIR/atlas/solr/server/solr-webapp/webapp/WEB-INF/lib/
RUN mkdir -p $APP_DIR/atlas/solr/server/solr-webapp/webapp/WEB-INF/classes
RUN cp $APP_DIR/atlas/conf/solr/resources/* $APP_DIR/atlas/solr/server/solr-webapp/webapp/WEB-INF/classes/
RUN cp $APP_DIR/atlas/conf/solr/managed-schema $APP_DIR/atlas/solr/server/solr/configsets/_default/conf/
RUN cp $APP_DIR/atlas/conf/solr/solrconfig.xml $APP_DIR/atlas/solr/server/solr/configsets/_default/conf/
RUN rm $APP_DIR/atlas.tar.gz

#RUN chown -R 1001:1001 /home/atlas
#USER atlas
# 指定工作目录
WORKDIR $APP_DIR/atlas/bin

## 执行命令，改变文件权限
RUN chmod 755 startup.sh

# 指定容器启动程序及参数
ENTRYPOINT ["bash","./startup.sh"]