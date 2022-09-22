---
permalink: "/api/stats.json"
layout: null
---
{% jbuilder %}

# } # (fixes syntax highlight in Sublime)

json.merge! context["glossary"]["language_statistics"]

{% endjbuilder %}
