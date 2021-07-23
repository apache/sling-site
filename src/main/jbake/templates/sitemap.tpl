def printSection(def linkPrefix, def sectionFolderUri, def sectionChildren) {
    if (!sectionChildren) {
        return
    }
    // comment "found ${sectionChildren.size()} children below '${sectionFolderUri}'"
    ul {
        // iterate over all direct children of rootUri
        sectionChildren.findAll( { page -> !page.uri.substring(sectionFolderUri.length()).contains('/') } ).sort( { page -> page.title } ).each { page -> 
            li {
                a (href:"${linkPrefix}${page.uri}") {
                   yield page.title
                }
                newLine()
                String subsectionFolderUri = page.uri.substring(0, page.uri.length() - '.html'.length()) + '/'
                // comment "subsectionFolderUri: '${subsectionFolderUri}'"
                printSection(linkPrefix, subsectionFolderUri, sectionChildren.findAll( child -> child.uri.startsWith(subsectionFolderUri) ))
            }
            newLine()
        }
    }
}


layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {

            div(class:"sitemap"){
                section(class:"wrap"){
					ul {
					    // published_content is just a list of https://github.com/jbake-org/jbake/blob/master/jbake-core/src/main/java/org/jbake/model/DocumentModel.java items
						printSection(config.site_contextPath, '', published_content)
					}
                }
            }
        }
