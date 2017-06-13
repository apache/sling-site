xmlDeclaration()
feed(xmlns:"http://www.w3.org/2005/Atom"){

    title("${config.blog_title}")
    newLine()
    link(href:"${config.site_host}${config.site_contextPath}")
    newLine()
    link(rel:"self", type:"application/atom+xml", href:"${config.site_host}${config.site_contextPath}${config.feed_file}")
    newLine()
    subtitle("${config.blog_subtitle}")
    newLine()
    updated("${published_date.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')}")
    newLine()
    id("tag:${config.feed_id},${published_date.format('yyyy:MM')}")
    newLine()
    published_posts.each {post ->
        entry{
          title("${post.title}")
          newLine()
          author{
              name("${post.author}")
          }
          newLine()
          link(href:"${config.site_host}${config.site_contextPath}${post.uri}")
          newLine()
          updated("${post.date.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')}")
          newLine()
          id("${config.site_host}${config.site_contextPath}${post.uri}")
          newLine()
          post.tags.each { tag ->
            category(term:"${tag}")
            newLine()
          }
          content(type:"html") {
            yield post.body
          }
        }
        newLine()
    }
}
