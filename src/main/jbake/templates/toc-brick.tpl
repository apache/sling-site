// Temporary (?) ToC generation, until we get markdown support for that
// using https://github.com/nghuuphuoc/tocjs
nav(class:"menu"){
    ul(class:"menu-list box is-shadowless is-paddingless"){
        li(id:"generatedToC") {
            p(class:"menu-label") {
                strong("Table of Contents")
            }
        }
    }
}
yieldUnescaped "<script src='/res/jquery-3.2.1.min.js' type='text/javascript'></script>"
yieldUnescaped "<script src='/res/tocjs-1-1-2.js' type='text/javascript'></script>"
yieldUnescaped "<script type='text/javascript'>\$(document).ready(function() { \$('#generatedToC').toc({'selector':'h1[class!=title],h2,h3','ulClass':'menu-list'}); } );</script>"
