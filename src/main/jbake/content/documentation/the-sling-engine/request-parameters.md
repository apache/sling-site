title=Request Parameter Handling in Sling		
type=page
status=published
excerpt=Explains how Sling provides request parameters to the `Component`.
tags=core,requests
~~~~~~

## Servlet API

The Servlet API specification provides the following methods to access the parameters of a request

| Method | Description |
|-|-|
| `HttpServletRequest.getQueryString()` | Returns the query part of the request URL |
| `ServletRequest.getParameter(String)` | Returns the (first) named parameter |
| `ServletRequest.getParameterValues(String)` | Returns all parameters of that name |
| `ServletRequest.getParameterMap()` | Returns all parameters as a map of `String[]` |
| `ServletRequest.getParameterNames()` | Returns an enumeration of the names of the parameters |
| `ServletRequest.getParts()` | Returns all parts of the multipart request (since v3.0) |
| `ServletRequest.getPart(String)` | Returns the request part with that name in case of multipart requests (since v3.0) |

The actual encoding of the parameters is all but safe because the encoding of URLs is not very well defined and browsers do not set the character encoding when sending post data. Fortunately, they use the same character encoding for sending back form content as was used by the server to send the form. 


## Sling API

To overcome the restrictions and to provide uniform access to request parameters the Sling API in addition to the Servlet API methods to access parameters provides an abstraction of parameters which is applicable to all parameters sent by clients, the `RequestParameter` interface. Through this interface, each parameter may be analyzed for these topics:

| Type | Description |
|-|-|
| Raw Content | Byte array and `InputStream` representation of the request parameter values. You will generally use the `InputStream` to handle uploaded files. |
| String Content | Access the values as strings is some given encoding (see below) or by requesting the conversion using an explicit encoding. |
| File Uploads | Find out whether a parameter is a file upload, get the size in bytes of the parameter value and client side file name as sent by the browser. |

To accomodate this new interface as well as to provide easy access in the traditional way the `SlingHttpServletRequest` interface adds following methods to the standard Servlet API parameter access methods:

| Method | Description |
|-|-|
| `getRequestParameter(String)` | Returns the (first) named parameter as a `RequestParameter` instance |
| `getRequestParameters(String)` | Returns the named parameter as an array of `RequestParameter` instances |
| `getRequestParameterMap()` | Returns `RequestParameterMap` being a map of `RequestParameter` arrays indexed by parameter names |

All parameters are handled the same, that is all methods give access to the same parameters regardless of whether the parameters were transmitted in the request query, as part of form encoded data or as part of a `multipart/form-data` request.

As of Sling Engine 2.1.0 the order or request parameters in the `getRequestParameterMap()`, `getParameterMap()`, and `getParameterNams()` is preserved as follows:

* The first entries are the parameters reported by the servlet container. The order of these parameters amongst each other is not defined. The `SlingHttpServletRequest` provides them in the same order as provided by the servlet container.
* After the servlet container provided parameters are parameters extracted from the request in case `multipart/form-data` POST requests. The order of these parameters is preserved as they are submitted in the request. This conforms to HTML 4.01 spec on forms submitted with multipart/form-data encoding: *A "multipart/form-data" message contains a series of parts, each representing a successful control. The parts are sent to the processing agent in the same order the corresponding controls appear in the document stream. Part boundaries should not occur in any of the data; how this is done lies outside the scope of this specification* ([17.13.4 Form content types](http://www.w3.org/TR/html401/interact/forms.html))

Be warned: Only rely on request parameter ordering `multipart/form-data` POST requests without a query part in the request URL.

### Effects of Sling on Servlet API parameter methods

From within Sling servlets/scripts you can no longer rely on the original semantics of the Servlet API methods for dealing with parameters as

* `ServletRequest.getParameter(String)`
* `ServletRequest.getParameterValues(String)`
* `ServletRequest.getParameterMap()`
* `ServletRequest.getParameterNames()`
* `ServletRequest.getParts()` and
* `ServletRequest.getPart(String)` 

internally use the Sling parameter support (and therefore have the same implications on e.g. encoding). You should preferably use the Sling methods `getRequestParameter*` instead.

Calling `ServletRequest.getInputStream()` is not supported, nor relying on some 3rd party libraries which are internally using that method like [Apache Commons Fileupload](https://commons.apache.org/proper/commons-fileupload/). This is because the Sling parameter support needs exclusive access to the request's input stream.

## Character Encoding

Traditionally, the encoding of parameters, especially in text area input forms, has been a big issue. To solve this issue Sling introduces the following convention:

   * All forms should contain a hidden field of the name `_charset_` containing the actual encoding used to send the form from the server to the client
   * All forms should be sent with *UTF-8* character encoding

The first rule is essential as it helps decoding the form input correctly. The second rule is not actually a very hard requirement but to enable support for all (or most) character sets used, using *UTF-8* is one of the best choices anyway.

When Sling is now receiving a request and is asked for the parameters, the parameters are parsed in two phases: The first phase just parses the raw input data using an identity transformation of bytes to characters. This identity transformation happens to generate strings as the original data was generated with `ISO-8859-1` encoding. The second phase locates the `_charset_` parameter and fixes the character encodings of the parameters as follows:

   * All names of the parameters are re-encoded
   * The parameter values are re-encoded, unless the parameter value is an uploaded file. Actually the parameter (not the files of course) are internally as `byte[]` where the conversion to a string is done on the fly (and yes, the conversion using the `_charset_` character encoding is of course cached for performance reasons)
   * If the parameter is an uploaded file, the file name is re-encoded on the fly when accessed

<div class="info">
Up to and including Sling Engine 2.2.2 request parameters are always decoded with ISO-8859-1 encoding if the <code>_charset_</code> request parameter is missing. As of Sling Engine 2.2.4 the <code>_charset_</code> request parameter is optional. As of this version the Sling Main Servlet supports a configuration setting which allows to change the default character encoding used if the <code>_charset_</code> request parameter is missing. 
To enable this functionality set the <code>sling.default.parameter.encoding</code> parameter of the Sling Main Servlet (PID <code>org.apache.sling.engine.impl.SlingMainServlet</code>) configuration (for Sling Engine < 2.3.0) or the same parameter of the Sling Request Parameter Handling (PID <code>org.apache.sling.engine.parameters</code>) configuration (for Sling Engine >= 2.3.0 ) to the desired encoding, which of course must be supported by the actual Java Platform.
</div>
