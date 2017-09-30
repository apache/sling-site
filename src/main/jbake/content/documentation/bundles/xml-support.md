title=XML support		
type=page
status=published
excerpt=XML mechanisms supported by Sling
tags=xml
~~~~~~

Out of the box, Sling provides no special bundles for XML. However, Sling supports multiple mechanisms and libraries. The ones we have validated with integration tests are:

* XPath ( see the [XPathServlet](http://svn.apache.org/repos/asf/sling/trunk/launchpad/test-services/src/main/java/org/apache/sling/launchpad/testservices/servlets/XpathServlet.java) )
* SAX ( see the [SaxServlet](http://svn.apache.org/repos/asf/sling/trunk/launchpad/test-services/src/main/java/org/apache/sling/launchpad/testservices/servlets/SaxServlet.java) )
* DOM ( see the [DomServlet](http://svn.apache.org/repos/asf/sling/trunk/launchpad/test-services/src/main/java/org/apache/sling/launchpad/testservices/servlets/DomServlet.java) )
