model.put("projects",projects)
layout 'layout/main.tpl', true,
        bodyContents: contents {
			p("TODO this is the post template")
            model.put('post', content)
            include template: 'post-brick.tpl'
        }
