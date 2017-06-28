# Extracts files which have images or embedded files
# Currently that's
#  http://localhost:8820/documentation/bundles/context-aware-configuration/context-aware-configuration-default-implementation.html
#  http://localhost:8820/documentation/bundles/context-aware-configuration/context-aware-configuration.html
#  http://localhost:8820/documentation/bundles/datasource-providers.html
#  http://localhost:8820/documentation/bundles/discovery-api-and-impl.html
#  http://localhost:8820/documentation/bundles/log-tracers.html
#  http://localhost:8820/documentation/bundles/manipulating-content-the-slingpostservlet-servlets-post.html
#  http://localhost:8820/documentation/bundles/metrics.html
#  http://localhost:8820/documentation/bundles/mime-type-support-commons-mime.html
#  http://localhost:8820/documentation/bundles/osgi-installer.html
#  http://localhost:8820/documentation/bundles/request-analysis.html
#  http://localhost:8820/documentation/bundles/resource-editor.html
#  http://localhost:8820/documentation/bundles/scripting/scripting-thymeleaf.html
#  http://localhost:8820/documentation/bundles/sling-health-check-tool.html
#  http://localhost:8820/documentation/development/ide-tooling.html
#  http://localhost:8820/documentation/development/jsr-305.html
#  http://localhost:8820/documentation/development/logging.html
#  http://localhost:8820/documentation/development/monitoring-requests.html
#  http://localhost:8820/documentation/the-sling-engine/authentication.html
#  http://localhost:8820/documentation/tutorials-how-tos/how-to-manage-events-in-sling.html
#  http://localhost:8820/news/sling-ide-tooling-11-released.html
GREPOPT="$1"
find assets -type f | \
egrep -v 'assets/res|assets/apidocs|assets/components|assets/logos' | \
egrep 'png|jpg|java|pptx' | \
while read f
do 
	find content -type f | xargs grep $GREPOPT $(basename $f); 
done