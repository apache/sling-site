title=Apache Sling - Bringing Back the Fun!		
type=page
status=published
tags=community
expandVariables=true
~~~~~~

Apache Sling&trade; is a ${sling_tagline}.

In a nutshell, Sling maps HTTP request URLs to content resources based on the
request's path, extension and selectors. Using convention over
configuration, requests are processed by scripts and
servlets, dynamically selected based on the current resource. This fosters
meaningful URLs and resource driven request processing, while the
modular nature of Sling allows for specialized server instances that
include only what is needed.

Sling serves as basis for a variety of applications ranging from
blogging engines all the way to enterprise content management
systems.

Our [Getting Started](/documentation/getting-started.html) page will help you
start playing with Sling.

Discussions about Sling happen on our mailing lists, see our 
[Project Information](/project-information.html) page for more info.

## News

Here are our most recent news, there are more in our [news archive](/news.html).

<ul id="newsExcerpt">
</ul>

<script src="/res/jquery-3.2.1.min.js" type="text/javascript"></script>
<script type="text/javascript">
        $(document).ready(function() {
            $.get("/news.html", function(news) {
                var $newsExcerpt = $(news).find('li').slice(0,5);
                $('#newsExcerpt').append($newsExcerpt);
            });
        });
</script>
