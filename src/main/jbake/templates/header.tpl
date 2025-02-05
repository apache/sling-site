head {
	meta("http-equiv":"Content-Type", content:"text/html;charset=UTF-8") newLine()
	title("${config.blog_title} :: ${content.title?:tag}") newLine()

	// For now, try to reproduce the layout of the current website, to be able to compare pages
	link(rel:"icon", href:"${config.site_contextPath}favicon.ico") newLine()
	link(rel:"stylesheet", href:"${config.site_contextPath}res/css/bulma.min.css") newLine()
	link(rel:"stylesheet", href:"${config.site_contextPath}res/css/site.css") newLine()
	
	// Apache current events
	yieldUnescaped "<script src='https://www.apachecon.com/event-images/snippet.js'></script>"

	// highlightjs.org
	link(rel:'stylesheet', href:'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/default.min.css') newLine()
	yieldUnescaped "<script src='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js'></script>"
	script {
		yield 'hljs.initHighlightingOnLoad();'
	} newLine()
	yieldUnescaped '''
	<!-- Matomo Web Analytics -->
	<script>
	var _paq = window._paq = window._paq || [];
	/* tracker methods like "setCustomDimension" should be called before "trackPageView" */
	/* We explicitly disable cookie tracking to avoid privacy issues */
	_paq.push(['disableCookies']); 
	_paq.push(['trackPageView']);
	_paq.push(['enableLinkTracking']);
	(function() {
	  var u="https://matomo.privacy.apache.org/";
	  _paq.push(['setTrackerUrl', u+'matomo.php']);
	  _paq.push(['setSiteId', '6']);
	  var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
	  g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
	})();
	</script>
	<!-- End Matomo Code -->
	'''

	yieldUnescaped "<link href='/pagefind/pagefind-ui.css' rel='stylesheet'>"
	yieldUnescaped "<script src='/pagefind/pagefind-ui.js' type='text/javascript'></script>"
	yieldUnescaped '''
	<script>
    window.addEventListener('DOMContentLoaded', (event) => {
        new PagefindUI({ element: "#searchbox" });
    });
	</script>
	'''
}
