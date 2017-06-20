#!/bin/sh
# Wrapper script around mirrors.cgi script (http://www.apache.org/dev/release-download-pages.html)
# (we must change to that directory in order for python to pick up the
#  python includes correctly)
cd /www/www.apache.org/dyn/mirrors
/www/www.apache.org/dyn/mirrors/mirrors.cgi $*
