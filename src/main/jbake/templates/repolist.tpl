// ------------------------------------------------------------------------------------------------
// Sling 'repolist' page - list of GitHub repositories generated from an XML file
// that our pom downloads.
// ------------------------------------------------------------------------------------------------

// Include common utilities
U = new includes.U(config)

layout 'layout/main.tpl', true,
    projects: projects,
    breadcrumbs : contents {
        include template : 'breadcrumbs-brick.tpl'
    },
    tags : contents {
        include template: 'tags-brick.tpl'
    },
    lastModified: contents {
        include template : 'lastmodified-brick.tpl'
    },
    bodyContents: contents {
        def filename = "${config.repolist_path}"
        def file = new File(filename)
        def repos = new XmlSlurper().parse(file)
        def NOGROUP = "<NO GROUP SET>"
        Set groups = []

        // Get the groups
        def reposCount = 0;
        repos.'**'.findAll { 
            node -> 
            node.name() == 'project' }*.each() {
                p ->
                reposCount++
                def group = p.attributes().groups
                if(group) {
                    groups.add(group)
                }
            }

        // Sort and add ungrouped projects to the end
        groups=groups.toSorted()
        groups.add(NOGROUP)

        // Mardown + computed summary
        section(class:"wrap"){
            yieldUnescaped U.processBody(content, config)
            p() {
                yield("A total of ${reposCount} repositories are listed below, in ${groups.size()} groups.")
            }
        }

        // List projects by group
        groups.each() {
            group ->
            h2() { 
                yield("Group: ${group}")
            }
            newLine()
            
            ul(class:"repolist") {
                repos.'**'.findAll { 
                    node -> 
                    node.name() == 'project' && (group == NOGROUP ? !node.attributes().groups : node.attributes().groups == group)
                }*.each() {
                    p -> 
                    li(class:"module") {
                        a(
                            class:"buildBadge", 
                            title:"build details for ${p.attributes().path}",
                            href:"https://ci-builds.apache.org/job/Sling/job/modules/job/sling-${p.attributes().path}/job/master/"
                        ) {
                            img(src:"https://ci-builds.apache.org/job/Sling/job/modules/job/sling-${p.attributes().path}/job/master/badge/icon?style=ball-24x24")
                        }
                        yield(" ")
                        span(class:"description") {
                            yield("${p.attributes().description}")
                        }
                        yield(" - ")
                        a(href:"${config.sling_github_baseURL}${p.attributes().name}") {
                            yield("${p.attributes().path}")
                        }
                    }
                    newLine()
                }
            }
            newLine()
        }
    }
