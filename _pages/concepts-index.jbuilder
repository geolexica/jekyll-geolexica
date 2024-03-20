---
permalink: "/api/concepts.json"
---
{% jbuilder %}

# } # (fixes syntax highlight in Sublime)

for concept_page in site["concepts"]
  concept_json_page = concept_page.concept.pages[:json]

  # JSON keys must be strings
  json.set! concept_page.termid.to_s do
    json.term concept_page.data["term"]
    json.termid concept_page.termid
    json.set! "uri-html", "#{site["baseurl"]}#{concept_page.url}"

    if concept_json_page&.url
      json.set! "uri-json", "#{site["baseurl"]}#{concept_json_page.url}"
    end
  end
end

{% endjbuilder %}
