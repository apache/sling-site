Title=TODO add front matter 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
translation_pending: true
Title: Plugins

These pages present the various Maven Plugins of Sling:

{% for label, page in children %}* [{{ page.headers.title }}]({{ page.path }})
{% endfor %}
