title=Plugins		
type=page
status=published
~~~~~~
translation_pending: true

These pages present the various Maven Plugins of Sling:

{% for label, page in children %}* [{{ page.headers.title }}]({{ page.path }})
{% endfor %}
