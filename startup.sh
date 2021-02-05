#!/bin/bash
source /etc/profile
SERVICE_IP=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
sed -i "s|STORAGE_DIR|$STORAGE_DIR|g" $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|SERVICE_IP|$SERVICE_IP|g" $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|KAFKA_ZOOKEEPER_CONNECT|$KAFKA_ZOOKEEPER_CONNECT|g" $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|KAFKA_BOOTSTRAP_SERVERS|$KAFKA_BOOTSTRAP_SERVERS|g"  $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|KAFKA_HOOK_GROUP_ID|$KAFKA_HOOK_GROUP_ID|g" $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|ATLAS_HOOK_TOPIC|$ATLAS_HOOK_TOPIC|g"  $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|ATLAS_ENTITIES_TOPIC|$ATLAS_ENTITIES_TOPIC|g"  $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|ATLAS_WEB_MIN_THREAD|$ATLAS_WEB_MIN_THREAD|g"  $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|ATLAS_WEB_MAX_THREAD|$ATLAS_WEB_MAX_THREAD|g"  $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|ATLAS_WEB_QUEUE_SIZE|$ATLAS_WEB_QUEUE_SIZE|g"  $ATLAS_HOME/conf/atlas-application.properties
sed -i "s|DB_CACHE_TIME|$DB_CACHE_TIME|g"  $ATLAS_HOME/conf/atlas-application.properties

echo "atlas.orgId=$ORG_ID" >>  $ATLAS_HOME/conf/atlas-application.properties
echo "atlas.graph.cache.db-cache=$DB_CACHE" >>  $ATLAS_HOME/conf/atlas-application.properties
echo "atlas.graph.cache.db-cache-size=$DB_CACHE_SIZE" >>  $ATLAS_HOME/conf/atlas-application.properties
echo "atlas.graph.cache.tx-cache-size=$TX_CACHE_SIZE" >>  $ATLAS_HOME/conf/atlas-application.properties

#sed -i "s|ATLAS_SERVER_JVM|$ATLAS_SERVER_JVM|g"  $ATLAS_HOME/conf/atlas-env.sh
#sed -i "s|ATLAS_OPTS|$ATLAS_OPTS|g"  $ATLAS_HOME/conf/atlas-env.sh
#sed -i "s|ATLAS_HOME|$ATLAS_HOME|g"  $ATLAS_HOME/conf/atlas-env.sh

#echo "export ATLAS_SERVER_HEAP=\"$ATLAS_SERVER_JVM\"" >>  $ATLAS_HOME/conf/atlas-env.sh
#echo "export ATLAS_SERVER_OPTS=\"$ATLAS_OPTS_UDF\"" >>  $ATLAS_HOME/conf/atlas-env.sh


echo "SOLR_JAVA_MEM=\"$SOLR_JVM\"" >> $ATLAS_HOME/solr/bin/solr.in.sh
echo "SOLR_LOGS_DIR=$SOLR_LOGS_DIR" >> $ATLAS_HOME/solr/bin/solr.in.sh
echo "SOLR_DATA_HOME=$SOLR_DATA_HOME" >> $ATLAS_HOME/solr/bin/solr.in.sh
echo "SOLR_HOME=$SOLR_HOME" >> $ATLAS_HOME/solr/bin/solr.in.sh
echo "GC_TUNE=\"$SOLR_GC_TUNE\"" >> $ATLAS_HOME/solr/bin/solr.in.sh

mkdir -p $ATLAS_HOME/data/solr/data
mkdir -p $ATLAS_HOME/data/solr/log
mkdir -p $ATLAS_HOME/data/solr/cores
mkdir -p $ATLAS_HOME/data/atlas/logs
mkdir -p $ATLAS_HOME/data/atlas/dumps
cp -r $ATLAS_HOME/solr/server/solr/solr.xml $APP_DIR/atlas/data/solr/cores/

cd $ATLAS_HOME/bin
python atlas_start.py
sleep 10

while true
do
    sleep 5
done
