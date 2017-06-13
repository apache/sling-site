#!/bin/bash

# Note: so far this is only tested on Mac OSX. Please remove this comment
#       if it works on Linux, or fix if it doesn't.

if [ "$2" == "" ]; then
    echo "Usage: sh $0 <module> <version>"
    echo "       e.g. sh $0 org.apache.sling.commons.threads 3.2.2"
    exit 1
fi

MODULE=$1
VERSION=$2

TMP_DIR=tmp-update-obr/$MODULE-$VERSION

URL_PREFIX=https://repository.apache.org/content/groups/public/org/apache/sling/$MODULE/$VERSION
JAR_NAME=$MODULE-$VERSION.jar
POM_NAME=$MODULE-$VERSION.pom

SITE_DIR=$(pwd)

function download {
    FILE=$1
    curl -fO $URL_PREFIX/$FILE 2> /dev/null
    if [ "$?" != "0" ]; then
        echo Failed to download artifact $URL_PREFIX/$FILE
        echo Please verify that the desired artifact is available. 
        exit 1;
    fi
}

mkdir -p $TMP_DIR

(
    cd $TMP_DIR                       

    download $POM_NAME
    download $JAR_NAME

    mvn org.apache.felix:maven-bundle-plugin:deploy-file \
        -Dfile=$JAR_NAME -DpomFile=$POM_NAME \
        -DbundleUrl=http://repo1.maven.org/maven2/org/apache/sling/$MODULE/$VERSION/$JAR_NAME \
        -Durl=file:///$SITE_DIR/content/obr \
        -DprefixUrl=http://repo1.maven.org/maven2 \
        -DremoteOBR=sling.xml
)

rm -rf tmp-update-obr/
echo OBR updated successfully. Please review the changes and commit.

