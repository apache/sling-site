title=Sample pipes
type=page
status=published
tags=pipes
~~~~~~

## Pipebuilder samples

those are samples built with pipebuilder api you can 

### echo | $ | children | write
write repository user prefix Ms/Mr depending on gender

      echo('/home/users')
      .$('rep:User')
      .children("nt:unstructured#profile")
      .write("fullName","${(profile.gender === 'female' ? 'Ms ' + profile.fullName : 'Mr ' + profile.fullName)}")

### echo | $ | multiProperty | auth | write
move badge<->user relation ship from badge->users MV property to a user->badges MV property

     .echo('/etc/badges/jcr:content/par')
     .$('[sling:resourceType=myApp/components/badge]').name('badge')
     .pipe('slingPipes/multiProperty').path('${path.badge}/profiles').name('profile')
     .auth('${profile}').name('user')
     .echo('${path.user}/profile')
     .write('badges','+[${path.badge}]')

##### echo | children | children | echo | json | write

this use case is for completing repository website with external system's data (that has an json api),
it does 

- loop over "my:Page" country/language tree under `/content/mySite`, 
- fetch json with contextual parameter that must be in upper case, 
- and write part of the returned json in the current resource. 

This pipe is run asynchronously in case the execution takes long.

     .echo("/content/mySite")
     .children('my:Page')
     .children('my:Page').name("localePage")
     .echo('${path.localePage}/jcr:content').name("content")
     .json('https://www.external.com/api/${content.country.toUpperCase()}.json.name('api')
     .write('cachedValue','${api.remoteJsonValueWeWant}')


##### echo | $ | parent | rm

- query all user profile nodes with bad properties,
- get the parent node (user node)
- remove it

        .echo("/home/users")
        .$("profile[@bad]")
        .parent()
        .rm()

some other samples are in https://github.com/npeltier/sling-pipes/tree/master/src/test/