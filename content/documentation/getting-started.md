title=TODO title for getting-started.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Getting Started

We're on the way to update the documentation to make it more easy to get in touch with Sling. At the moment we can give you the following starting points:

{% for label, page in children %}* [{{ page.headers.title }}]({{ page.path }})
{% endfor %}

## Where to head from here

We recommend you read through following topics to get as fast as possible into Sling: 

* [Getting and building Sling](/documentation/development/getting-and-building-sling.html)
* [Architecture](/documentation/the-sling-engine/architecture.html)
* [Dispatching Requests](/documentation/the-sling-engine/dispatching-requests.html)
* [Resources](/documentation/the-sling-engine/resources.html)
* [{{ refs.ide-tooling.headers.title }}](/documentation/development/ide-tooling.html)
* [Manipulating Content - The SlingPostServlet (servlets.post)](/documentation/bundles/manipulating-content-the-slingpostservlet-servlets-post.html)
* [Request Parameters](/documentation/the-sling-engine/request-parameters.html)
* [Authentication](/documentation/the-sling-engine/authentication.html)
* [Eventing and Jobs]({{ refs.eventing-and-jobs.path }})
