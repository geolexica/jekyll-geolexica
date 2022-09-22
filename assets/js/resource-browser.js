(function () {
  var viewer = document.querySelector('.two-pane-viewer');

  if (viewer) {
    var browser = viewer.querySelector('.browser.bp3-tree');
    var iframe = viewer.querySelector('.viewer iframe');
    if (browser && iframe) {

      function selectItem (item) {
        for (var el of browser.querySelectorAll('a')) {
          el.classList.remove('selected');
        }
        item.classList.add('selected');
      }

      for (var el of browser.querySelectorAll('.bp3-tree-node-label a')) {
        el.addEventListener('click', function (evt) {
          iframe.setAttribute('src', 'about:blank');

          var itemUrl = evt.target.getAttribute('href');
          // var extension = itemUrl.slice('-1');
          fetchResource(itemUrl, function () {
            if (this.responseXML) {
              try {
                iframe.setAttribute('src', 'about:blank');
                iframe.contentWindow.document.open();
                iframe.contentWindow.document.write(
                  '<pre>' +
                  new Option(prettyPrintXML(this.responseXML)).innerHTML +
                  '</pre>');
                iframe.contentWindow.document.close();

              } catch (e) {
                iframe.setAttribute('src', itemUrl);
              }
            } else {
              iframe.setAttribute('src', itemUrl);
            }
          });

          selectItem(evt.target);

          evt.preventDefault();
          return false;
        });
      }
    }
  }

  function fetchResource(url, handleResourceResponse) {
    var oReq = new XMLHttpRequest();
    oReq.addEventListener("load", handleResourceResponse);
    oReq.open("GET", url);
    // oReq.overrideMimeType("text/plain; charset=x-user-defined");
    oReq.send();
  }

  function prettyPrintXML(xmlDoc) {
    var xsltDoc = new DOMParser().parseFromString([
      // describes how we want to modify the XML - indent everything
      '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">',
      '  <xsl:strip-space elements="*"/>',
      '  <xsl:template match="para[content-style][not(text())]">', // change to just text() to strip space in text nodes
      '    <xsl:value-of select="normalize-space(.)"/>',
      '  </xsl:template>',
      '  <xsl:template match="node()|@*">',
      '    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>',
      '  </xsl:template>',
      '  <xsl:output indent="yes"/>',
      '</xsl:stylesheet>',
    ].join('\n'), 'application/xml');

    var xsltProcessor = new XSLTProcessor();    
    xsltProcessor.importStylesheet(xsltDoc);
    var resultDoc = xsltProcessor.transformToDocument(xmlDoc);
    var resultXml = new XMLSerializer().serializeToString(resultDoc);
    return resultXml;
  };
}());
