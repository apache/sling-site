model.put("projects",projects)
layout 'layout/main.tpl', true,
        bodyContents: contents {
            model.put('post', content)
            include template: 'post-brick.tpl'
        }
