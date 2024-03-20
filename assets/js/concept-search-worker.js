---
---
importScripts("{{ '/assets/js/babel-polyfill.js' | relative_url }}");

const CONCEPTS_URL = "{{ '/api/concept-search-index.json' | relative_url }}";

/** For example:
 *    const LANGUAGES = [ 'eng', 'deu' ];
 *  Having a wrapper function helps not to break syntax highlight.
 */
const LANGUAGES = (function() {
  return {{ site.geolexica.term_languages | jsonify }} || [];
})();

var concepts = null;
var latestQuery = null;

// TODO Support filters here maybe.
class SearchQuery {
  constructor(queryString) {
    this.searchWords = queryString.toLowerCase().match(/\p{Letter}+/ug) || [];
  }

  isEmpty() {
    return this.searchWords.length == 0;
  }

  match(string) {
    const stringLC = string.toLowerCase();
    return this.searchWords.every((word) => stringLC.includes(word));
  }
}

function fetchConcepts() {
  if (concepts === null) {
    concepts = fetch(CONCEPTS_URL).then((resp) => resp.json());
  }
  return concepts;
}

async function filterAndSort(params) {
  var concepts = await fetchConcepts();

  const query = new SearchQuery(params.string);

  if (!query.isEmpty()) {
    concepts = concepts.map((_item) => {
      // Search all localized term names for the presence of given search string

      const item = Object.assign({}, _item);
      const matchingLanguages = LANGUAGES.
        filter((lang) => {
          const term = (item[lang] || {}).term;
          return term && query.match(term);
        });

      if (matchingLanguages.length > 0) {
        for (let lang of LANGUAGES) {
          if (matchingLanguages.indexOf(lang) < 0) {
            delete item[lang];
          }
        }
        return item;
      } else {
        return null;
      }
    }).filter((item) => item !== null);
  }

  if (params.valid !== undefined) {
    concepts = concepts.
      filter((item) => {
        // Only select concepts with at least one localized version matching given validity query
        const validLocalizedItems = LANGUAGES.
          filter((lang) => item.hasOwnProperty(lang)).
          filter((lang) => item[lang].entry_status === params.valid);
        return validLocalizedItems.length > 0;
      }).
      map((_item) => {
        // Delete localized versions that don’t match given validity query

        const item = Object.assign({}, _item);
        for (let lang of LANGUAGES) {
          if (item[lang] && item[lang].entry_status !== params.valid) {
            delete item[lang];
          }
        }
        return item;
      });
  }

  return concepts.sort((item1, item2) => item1.sort_order.natural - item2.sort_order.natural);
}

onmessage = async function(msg) {
  latestQuery = msg.data;

  let concepts;
  try {
    concepts = await filterAndSort(msg.data);
  } catch (e) {
    console.error(e);
    postMessage({ error: "Failed to fetch concepts, please <a href='javascript:window.location.reload();'>reload</a> & try again!" });
    throw e;
    return;
  }

  // Check if we the query changed while concepts were being fetched,
  // in that case skip posting back the message
  // NOTE: if more query parameters are supported, update the condition to ensure
  // full comparison
  if (latestQuery.string === msg.data.string) {
    postMessage(concepts);
  }
};
