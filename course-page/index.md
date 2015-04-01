---
title: Announcements
icon: bullhorn
index: 1
---

{% for post in site.announcements reversed %}

{% box post %}

{{ post.content }}

{% endbox %}

{% endfor %}
