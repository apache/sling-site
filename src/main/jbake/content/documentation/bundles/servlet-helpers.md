title=Sling Servlet Helpers		
type=page
status=published
~~~~~~

The Sling Servlet Helpers bundle provides mock implementations of the
`SlingHttpServletRequest`, `SlingHttpServletResponse` and related classes.

Those mock implementations are meant to be used in tests and also with services
like the `SlingRequestProcessor` when making requests to that service outside of
an HTTP request processing context.

See the [automated tests](https://svn.apache.org/repos/asf/sling/trunk/bundles/extensions/servlet-helpers) 
of the `servlet-helpers` module for more info.


## Usage

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
