#!/bin/bash
cd $WORKSPACE
mvn clean -DskipTests package -Pdist,embedded-solr -Drat.skip=true || exit 1
rm -rf target
mkdir target
cp distro/target/apache-atlas-*-server.tar.gz ./target/atlas.tar.gz
#cp package/apache-atlas-*-server.tar.gz ./target/atlas.tar.gz
cd tools/atlas-index-repair
mvn clean -DskipTests package || exit 1
cd ../..
cp -r tools/atlas-index-repair ./target/
cp package/ik-analyzer-8.3.0.jar ./target/