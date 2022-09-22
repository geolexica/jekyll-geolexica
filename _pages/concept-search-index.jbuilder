---
permalink: "/api/concept-search-index.json"
---
{% jbuilder %}

# } # (fixes syntax highlight in Sublime)

json.array! site["concepts"].each_with_index.to_a do |(concept, idx)|
  json.termid concept.termid
  json.term concept.data.dig("eng", "terms", 0, "designation")
  json.term_url concept.url

  json.sort_order do
    json.natural idx + 1 # loop index, indexing from 1
  end

  for lang in site["geolexica"]["term_languages"]
    json.set! lang do
      english = concept.data["eng"] || {}
      localized = concept.data[lang]

      unless localized
        json.merge! Hash.new # A trick to force an empty object
        next
      end

      json.term localized.dig("terms", 0, "designation")
      json.id localized["id"]
      json.term_url "#{concept.url}#entry-lang-#{lang}"
      json.entry_status english["entry_status"]
      json.language_code localized["language_code"]
      json.review_decision english["review_decision"]
    end
  end
end

{% endjbuilder %}
