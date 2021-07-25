div(class:"edit") {
    def prefix = 'https://github.com/apache/sling-site/edit/master/src/main/jbake/'
    // relativize absolute content.file path
    def relativeSourcePath = config.sourceFolder.toPath().relativize(java.nio.file.Paths.get(content.file))
    a(href:"${prefix}${relativeSourcePath}") {
        yield "Edit"
    }
}