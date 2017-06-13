Title=TODO add front matter 
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

* [Getting and building Sling]({{ refs.getting-and-building-sling.path }})
* [Architecture]({{ refs.architecture.path }})
* [Dispatching Requests]({{ refs.dispatching-requests.path }})
* [Resources]({{ refs.resources.path }})
* [{{ refs.ide-tooling.headers.title }}]({{ refs.ide-tooling.path }})
* [Manipulating Content - The SlingPostServlet (servlets.post)]({{ refs.manipulating-content-the-slingpostservlet-servlets-post.path }})
* [Request Parameters]({{ refs.request-parameters.path }})
* [Authentication]({{ refs.authentication.path }})
* [Eventing and Jobs]({{ refs.eventing-and-jobs.path }})
