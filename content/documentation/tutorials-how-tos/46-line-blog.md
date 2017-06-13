Title=TODO add front matter 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: 46 Line Blog

This tutorial is based on the first *Sling Gems* on dev.day.com: The [Sling gems: a blog in 46 lines of code](http://dev.day.com/microsling/content/blogs/main/sling-46-lines-blog.html). It has slightly been adapted to fit here.

In this tutorial, the SlingPostServlet and the sling.js library are brought together using 46 (no kidding: *fourty-six*) lines of code to create a simple blog (or let's say *bloggish*) application.

I used this example in my [Rapid JCR application development with Apache Sling](http://www.slideshare.net/bdelacretaz/rapid-jcr-applications-development-with-sling-1196003) presentation at ApacheCon US 09 in Oakland (slides will be available soon), and I think it's a good testimony to the power and simplicity of Sling.

## Audience

Although this is a simple sample, it requires some custom settings to work. If you're just starting with Sling, [Discover Sling in 15 minutes]({{ refs.discover-sling-in-15-minutes.path }}) might be a better choice.

## Step 0: Start, configure and login to Sling

See [Getting and Building Sling]({{ refs.getting-and-building-sling.path }}) for how to start Sling. Start it on port 8888 for the below links to work.

For this sample we need the optional *org.apache.sling.samples.path-based.rtp* bundle, if it's not present in the [OSGi console](http://localhost:8888/system/console/bundles), install and start it. That bundle is not released yet so you might need to build it yourself, from its [source](http://svn.apache.org/repos/asf/sling/trunk/samples/path-based-rtp). The bundle must then appear in the [OSGI console's list of bundles](http://localhost:8888/system/console/bundles), with name = *org.apache.sling.samples.path-based.rtp* and status = *Active*.

Then, login using <http://localhost:8888/?sling:authRequestLogin=1> which should prompt you for a username and password, use *admin* and *admin*. Once that's done, <http://localhost:8888/index.html> should say *You are currently logged in as user *admin* to workspace *default**.

## Step 1: Creating content

The easiest way to create content in Sling is to use an HTTP POST request, let's use a simple HTML form:

    <html>
      <body>
        <h1>Sling microblog</h1>
      
        <div>
          <form method="POST">
            Title:<br/>
            <input type="text" name="title" style="width:100%"/>
            
            <br/>Text:<br/>
            <textarea style="width:100%" name="text"></textarea>
            
            <br/>
            <input type="submit" value="save"/>
            <input type="hidden" name=":redirect" value="*.html"/>

            <!-- used by Sling when decoding request parameters -->
            <input type="hidden" name="_charset_" value="UTF-8"/>
          </form>
        </div>
      
        <!-- code of step 2 comes here -->
      </body>
    </html>

     
That's two input fields, a submit button and a hidden field that tells Sling what to do after the POST (in this case: redirect to the html view of the node that was just created).
    
To test the form, start Sling and save the above script as {{/apps/blog/blog.esp}} [^esp]  in the Sling repository - a WebDAV mount is the easiest way to do that. Browsing to <http://localhost:8888/content/blog/*.html> [^port] should display the above form.

[^esp]: ESP is Sling's server-side javascript language
[^port]: This assumes your instance of Sling is running on port 8888. If that's not the case, adjust the example URLs accordingly.

Input some data (using "foo" for the title, for the sake of our examples below), save the form, and Sling should display the form again, using the URL of the node that was just created.
    
<div class="note">
If you get an error saying _javax.jcr.AccessDeniedException: ...not allowed to add or modify item_ it means that you are not logged in as user _admin_. See instructions above for logging in.
</div>
    
At this point you're probably looking at an empty form with an URL ending in _foo_, if you used that for the title. Or _foo_0_ or _foo_1_ if other _foo_s already existed. Don't worry about not seeing your content, we'll fix that right away.
    
    
## Step 2: Where's my content?
    
To verify that our content has been created, we can have a look at the JSON data at <http://localhost:8888/content/blog/foo.tidy.json>, which should display our new node's values:
    
    
    {
      "jcr:primaryType": "nt:unstructured",
      "text": "This is the foo text",
      "title": "foo"
    }


That's reassuring, but what we really want is for these values to be displayed on the editing form for our post.

Thanks to the *sling.js* client library, we just need to add a `Sling.wizard()` call to our form to display those values. Let's first add a `<head>` element to our form to load the *sling.js* library, before the existing `<body>` of course:
 
    <head>
      <script src="/system/sling.js"></script>
    </head>

     
And add the `Sling.wizard()` after the form, where we had the _code of step 2 comes here_ comment:
    
    <!-- code of step 2 comes here -->
    <script>Sling.wizard();</script>

 
Reloading the form at `http://localhost:8888/content/blog/*.html` and creating a new post should now redirect to an editable version of the post, with the form fields correctly initialized.

We can now create and edit posts; let's add some navigation, using more of the *sling.js* functionality. 

## Step 3: Navigation

The *sling.js* library provides utilities to access and manipulate content. For our blog, we'll use the `getContent(path)` method to list the siblings of the current node.

Add the following code to your script, after the `Sling.wizard()` call that was added in step 2:

    <h3>Navigation</h3>
    <ul>
        <li><em><a href="/content/blog/*.html">[Create new post]</a></em></li>
        <script>
          var posts = Sling.getContent("/content/blog", 2);
          for(var i in posts) {
            document.write("<li>"
              + "<a href='/content/blog/" + i + ".html'>"    
              + posts[i].title
              + "</a></li>");
          }
        </script>
    </ul>
    
     
The first link to `/content/blog/*` brings us back to our content creating form, which is nothing else than the editing form reading empty values and posting to the "magic star" URL. 
    
The rest of the javascript runs client-side, as it is not embedded in `<% %>` code markers, calls the `sling.getContent` method to get two levels of node data below `/content/blog`, and displays links to nodes that it finds.
    
That's a basic navigation, of course, in a real blog we'd need some paging and contextualization to cope with large numbers of posts.
    
Nevertheless, with this addition our ESP script allows us to create, edit and navigate blog posts - not bad for 46 lines of code, including comments, whitespace and output formatting.
    
     
## Step 4: Data first, structure later
    
You might have heard this mantra, which we apply in many areas of Sling.
    
In this case, adding a new field to our blog posts could not be easier: just add an input field to the form, and Sling will do the rest.
    
Adding this inside our script's `<form>` element, for example:
    
    <br/>Author:<br/>
    <input type="author" name="author" style="width:100%"/>

 
Allows us to add an author name to our blog posts. No need to define anything at the repository level, as Sling is using it in unstructured mode in this case, and no need to migrate existing data, the author field of existing posts will simply be empty.


## I want my ESP!

Now wait...we said we were going to create an ESP script, but our "application" is just static HTML and some client javascript at this point.

That's correct - as we are using only Sling client-facing features at this point (HTTP POST and `sling.js`), we do not necessarily need to use ESP code.

To keep things simple, we'll refrain from adding ESP-based features at this point, but you can of course use any ESP code in the *blog.esp* "script".


## That's the power of Sling

The 46-line blog is a good example of the power of Sling. It leverages the [SlingPostServlet]({{ refs.manipulating-content-the-slingpostservlet-servlets-post.path }}), which handles POST requests in a form-friendly way, and the [`sling.js`](http://svn.apache.org/repos/asf/sling/trunk/bundles/servlets/post/src/main/resources/system/sling.js) client library, which provides high-level functionality on the client side.

///Footnotes Go Here///

