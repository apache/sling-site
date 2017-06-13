translation_pending: true
Title: Old Stuff

Should either be deleted or reviewed and updated to match the current code:

{% for label, page in children %}* [{{ page.headers.title }}]({{ page.path }})
{% endfor %}
