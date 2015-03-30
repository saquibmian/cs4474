---
title: Announcements
icon: bullhorn
index: 1
---

{% for post in site.announcements %}

{% box post.title %}

Posted: {{ post.date | date: "%b %-d %Y at %-I:%m %P" }}
Link: [here]({{ post.url }})
{{ post.content }}

{% endbox %}

{% endfor %}
