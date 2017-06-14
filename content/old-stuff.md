title=Old Stuff		
type=page
status=published
~~~~~~
translation_pending: true

Should either be deleted or reviewed and updated to match the current code:

{% for label, page in children %}* [{{ page.headers.title }}]({{ page.path }})
{% endfor %}
