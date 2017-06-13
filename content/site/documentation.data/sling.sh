#!/bin/sh
#
# Synchronizes the Confluence Export of the
# Sling site to the site folder and fixes
# the mirror link settings of the downloads.html
# page which are incorrectly expanded to absolute
# links by the confluence export 

# Site Mirror Sources
MIRROR_SOURCE=/x1/www

# Site folder
SITE=${MIRROR_SOURCE}/sling.apache.org/site

# downloads page location
DLPAGE=${SITE}/downloads.html
DLCGI=${SITE}/downloads.cgi

# temporary copy of the downloads page
DLTMP=/home/fmeschbe/d.html 

# synchronized from Confluence export
#/usr/local/bin/rsync -rt --out-format='%n %l %M' ${MIRROR_SOURCE}/confluence-exports/SLINGxSITE/ ${SITE}
#/usr/local/bin/rsync -rt ${MIRROR_SOURCE}/confluence-exports/SLINGxSITE/ ${SITE}

# add -p option according to INFRA-2518
/usr/local/bin/rsync -rtp --chmod=Dg+s,g+w ${MIRROR_SOURCE}/confluence-exports/SLINGxSITE/ ${SITE}

# copy downloads page and replace with patched
cp ${DLPAGE} ${DLTMP}
cat ${DLTMP} | sed  's/http:\/\/cwiki.apache.org\/confluence\/display\/SLINGxSITE\/%5Bpreferred%5D/[preferred]/g' > ${DLPAGE}

# copy apache-sling.html to index.html
cp ${SITE}/apache-sling.html ${SITE}/index.html

# ensure the download.cgi script exists
if [ ! -f ${DLCGI} ] ; then
    cat >${DLCGI} <<-'EOF'
	!/bin/sh
	# Wrapper script around mirrors.cgi script
	# (we must change to that directory in order for python to pick up the
	#  python includes correctly)
	cd /www/www.apache.org/dyn/mirrors
	/www/www.apache.org/dyn/mirrors/mirrors.cgi $*
EOF
    chmod 775 ${DLCGI}
fi

