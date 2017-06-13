yieldUnescaped '<!DOCTYPE html>'
html(lang:'en'){

    head {
        include template: "header.tpl"
    }

    body(class:"antialiased", onload:"prettyPrint();") {

        include template: 'menu.tpl'

        main {
            bodyContents()
        }
        newLine()
        include template: 'footer.tpl'


        script(src:"${config.site_contextPath}js/vendor/jquery.js"){}
        newLine()
        script(src:"${config.site_contextPath}js/foundation.min.js"){}
        newLine()
        script(src:"${config.site_contextPath}js/vendor/prettify.js"){}
        newLine()
        script {
            yieldUnescaped "\$(document).foundation();"
            newLine()
            yieldUnescaped "\$(function() {"
            newLine()
            yieldUnescaped "   hljs.tabReplace = \"  \";"
            newLine()
            yieldUnescaped "   hljs.initHighlighting();"
            newLine()
            yieldUnescaped "});"
        }
        newLine()
    }
}
newLine()
