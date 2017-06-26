title=Getting Started		
type=page
status=published
~~~~~~

We're on the way to update the documentation to make it more easy to get in touch with Sling. At the moment we can give you the following starting points:

{% for label, page in children %}* [{{ page.headers.title }}]({{ page.path }})
{% endfor %}

## Where to head from here

We recommend you read through following topics to get as fast as possible into Sling: 

* [Getting and building Sling](/documentation/development/getting-and-building-sling.html)
* [Architecture](/documentation/the-sling-engine/architecture.html)
* [Dispatching Requests](/documentation/the-sling-engine/dispatching-requests.html)
* [Resources](/documentation/the-sling-engine/resources.html)
* [Sling IDE Tooling](/documentation/development/ide-tooling.html)
* [Manipulating Content - The SlingPostServlet (servlets.post)](/documentation/bundles/manipulating-content-the-slingpostservlet-servlets-post.html)
* [Request Parameters](/documentation/the-sling-engine/request-parameters.html)
* [Authentication](/documentation/the-sling-engine/authentication.html)
* [Eventing and Jobs](/documentation/bundles/apache-sling-eventing-and-job-handling.html)
