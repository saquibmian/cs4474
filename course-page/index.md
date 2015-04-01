---
title: Announcements
icon: bullhorn
index: 1
---

{% for post in site.announcements reversed %}

{% box post %}

Link: [here]({{ post.url }})
{{ post.content }}

{% endbox %}

{% endfor %}
