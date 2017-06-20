title=TODO title for old-stuff.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
translation_pending: true
Title: Old Stuff

Should either be deleted or reviewed and updated to match the current code:

{% for label, page in children %}* [{{ page.headers.title }}]({{ page.path }})
{% endfor %}
