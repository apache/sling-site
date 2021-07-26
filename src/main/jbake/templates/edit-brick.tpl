div(class:"editpagelink") {
    // relativize absolute content.file path
    def relativeSourcePath = config.sourceFolder.toPath().relativize(java.nio.file.Paths.get(content.file))
    yield "This page can be edited on GitHub at "
    a(href:"${config.sling_github_baseEditingURL}${relativeSourcePath}") {
        yield "${relativeSourcePath}"
    }
}