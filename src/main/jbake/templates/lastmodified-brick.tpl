div(class:"revisionInfo") {
    def info = includes.Git.getRevisionInfo(content.file);
    yield "Last modified by "
    span(class:"author") { yield info.author }
    yield " on "
    span(class:"comment") { yield info.date }
}