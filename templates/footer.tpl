
div(class:"row"){
    div(class:"small-12 small-text-center"){
        p(class:"muted credit"){
         yield "2014 - ${new Date().format("yyyy")} | "
         yield "Mixed with "
         a(href:"http://foundation.zurb.com/","Foundation v${config.foundation_version}")
         yield " | Baked with "
         a(href:"http://jbake.org","JBake ${version}")
        }
    }
}