#!/bin/sh
#
# Synchronizes the Confluence Export of the
# Sling site to the site folder and fixes
# the mirror link settings of the downloads.html
# page which are incorrectly expanded to absolute
# links by the confluence export 

# Site folder
SITE=/www/incubator.apache.org/sling/site

# downloads page location
DLPAGE=${SITE}/downloads.html

# temporary copy of the downloads page
DLTMP=/home/fmeschbe/d.html 

# synchronized from Confluence export
/usr/local/bin/rsync -rt /www/confluence-exports/SLINGxSITE/ ${SITE}

# copy downloads page and replace with patched
cp ${DLPAGE} ${DLTMP}
cat ${DLTMP} | sed  's/http:\/\/cwiki.apache.org\/confluence\/display\/SLINGxSITE\/%5Bpreferred%5D/[preferred]/g' > ${DLPAGE}

# copy apache-sling.html to index.html
cp ${SITE}/apache-sling.html ${SITE}/index.html

