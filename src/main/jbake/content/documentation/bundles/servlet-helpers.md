title=Sling Servlet Helpers and Internal Requests
type=page
status=published
tags=servlets,requests,scripts,servletresolver
~~~~~~

The [Sling Servlet Helpers](https://github.com/apache/sling-org-apache-sling-servlet-helpers) 
bundle provides mock implementations of the `SlingHttpServletRequest`, `SlingHttpServletResponse`
and related classes, along with fluent `SlingInternalRequest` and `ServletInternalRequest`
helpers for internal requests.

The mock request/response implementations are meant to be used in tests and
also with services like the `SlingRequestProcessor` when making requests to
that service outside of an HTTP request processing context.

They are used under the hood by the `SlingInternalRequest` and 
`ServletInternalRequest` helpers to provide a simple and foolproof way
of executing internal Sling requests.

The [GraphQL Core](https://github.com/apache/sling-org-apache-sling-graphql-core/) module,
for example, uses them for internal requests that retrieve a GraphQL schema dynamically,
taking into account the current Resource and request selectors.

See the [automated tests](https://github.com/apache/sling-org-apache-sling-servlet-helpers) 
of the `servlet-helpers` module for more info, besides the general 
descriptions found below.


## InternalRequest helpers

The internal request helpers use either a `SlingRequestProcessor` to execute internal requests using
the full Sling request processing pipeline, or a `ServletResolver` to resolve and call a Servlet or Script
directly. The necessary "mocking" of requests are responses happens under the hood which leads to much
simpler code than using the mock request/response classes directly.

The latter direct-to-servlet (or script) mode is more efficient but less faithful to the way HTTP requests
are processed, as it bypasses all Servlet Filters, in particular.

Here's an example using the `SlingInternalRequest` helper - see the test code for more. The
`ServletInternalRequest` API is very similar but takes a `ServletResolver` and an actual `Resource`
as its starting points.

    OutputStream os = new SlingInternalRequest(resourceResolver, slingRequestProcessor, path)
      .withResourceType("website/article/news")
      .withResourceSuperType("website/article")
      .withSelectors("print", "a4")
      .withExtension("pdf")
      .execute()
      .checkStatus(200)
      .checkResponseContentType("application/pdf")
      .getResponse()
      .getOutputStream()

Not all servlets and scripts are suitable to be called by the `ServletInternalRequest`, depending
on their "environmental" requirements like `Request` attributes for example.


In case of doubt you can start with the `SlingInternalRequest` helper which uses the `SlingRequestProcessor`
so that servlets or scripts should see no difference compared to HTTP requests. And once that works you can
try the more efficient `ServletInternalRequest` helper to check if your scripts and servlets support
that mode.

In both cases, the standard [Sling Servlet/Script resolution mechanism](/documentation/the-sling-engine/servlets.html)
is used, which can be useful to execute scripts that are resolved based on the current resource type, for non-HTTP
operations. Inventing HTTP method names for this is fine and allows for reusing this powerful resolution mechanism
in other contexts.

### Troubleshooting internal requests

To help map log messages to internal requests, as several of those might be used to handle a single
HTTP request, the `InternalRequest` parent class of the helpers discussed above sets a log4j 
_Mapped Diagnostic Context_ (MDC) value with the `sling.InternalRequest`key.

The value of that key provides the essential attributes of the current request, so that using a log
formatting pattern that displays it, like:

    %-5level [%-50logger{50}] %message ## %mdc{sling.InternalRequest} %n

Causes the internal request information to be logged, like in this example (lines folded
for readability):

    DEBUG [o.a.s.s.internalrequests.SlingInternalRequest     ]
       Executing request using the SlingRequestProcessor
       ## GET P=/content/tags/monitor+array S=null EXT=json RT=samples/tag(null)
    WARN  [org.apache.sling.engine.impl.request.RequestData  ]
      SlingRequestProgressTracker not found in request attributes
      ## GET P=/content/tags/monitor+array S=null EXT=json RT=samples/tag(null)
    DEBUG [o.a.s.s.resolver.internal.SlingServletResolver    ]
      Using cached servlet /apps/samples/tag/json.gql
      ## GET P=/content/tags/monitor+array S=null EXT=json RT=samples/tag(null)

In these log messages, `GET P=/content/tags/monitor+array S=null EXT=json RT=samples/tag(null)` points
to the current internal request, showing its method, path, selectors, extension, resource type and
resource supertype.


## Mock Request/Response classes

These are useful for testing or if you need to do something that the internal request helpers
do not support.

### SlingHttpServletRequest

Example for preparing a sling request with custom request data:

    #!java
    // prepare sling request
    MockSlingHttpServletRequest request = new MockSlingHttpServletRequest(resourceResolver);

    // simulate query string
    request.setQueryString("param1=aaa&param2=bbb");

    // alternative - set query parameters as map
    request.setParameterMap(ImmutableMap.<String,Object>builder()
        .put("param1", "aaa")
        .put("param2", "bbb")
        .build());

    // set current resource
    request.setResource(resourceResolver.getResource("/content/sample"));

    // set sling request path info properties
    MockRequestPathInfo requestPathInfo = (MockRequestPathInfo)request.getRequestPathInfo();
    requestPathInfo.setSelectorString("selector1.selector2");
    requestPathInfo.setExtension("html");

    // set method
    request.setMethod(HttpConstants.METHOD_POST);

    // set attributes
    request.setAttribute("attr1", "value1");

    // set headers
    request.addHeader("header1", "value1");

    // set cookies
    request.addCookie(new Cookie("cookie1", "value1"));


### SlingHttpServletResponse

Example for preparing a sling response which can collect the data that was written to it:

    #!java
    // prepare sling response
    MockSlingHttpServletResponse response = new MockSlingHttpServletResponse();

    // execute the code that writes to the response...

    // validate status code
    assertEquals(HttpServletResponse.SC_OK, response.getStatus());

    // validate content type and content length
    assertEquals("text/plain;charset=UTF-8", response.getContentType());
    assertEquals(CharEncoding.UTF_8, response.getCharacterEncoding());
    assertEquals(55, response.getContentLength());

    // validate headers
    assertTrue(response.containsHeader("header1"));
    assertEquals("5", response.getHeader("header2"));

    // validate response body as string
    assertEquals(TEST_CONTENT, response.getOutputAsString());

    // validate response body as binary data
    assertArrayEquals(TEST_DATA, response.getOutput());
    
