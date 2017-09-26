Title: Sling Query vs JCR

Sling Query is not meant to replace JCR queries (XPath, JCR-SQL, JCR-SQL2). It doesn't use indexes and generally in queries traversing large subtrees (like `/` or `/content` or `/content/mysite/en`) it'll be much slower than well written JCR query.

Purpose of the SlingQuery is to provide a convenient way to traverse resource tree. All SlingQuery operations are eventually transformed into a series of `listChildren()` and `getParent()` operations [1].

As a rule of thumb - if you have a complex Java loop reading resource children or parents and processing them somehow, rewritting it to SlingQuery will be a good choice. If you have a recursive method trying to get some resource ancestor, using SlingQuery will be a good choice. On the other hand, if you have a large resource subtree and want to find all `cq:Page`s, using SlingQuery is a bad choice.

| Description                                           | JCR query | SlingQuery |
| ------------------------------------------------------|-----------|------------|
| You have a complex logic using Sling Resource API     | -         | Yes!       |
| You want to find resource ancestor                    | -         | Yes!       |
| You want to find all descendants with given attribute | Yes!      | -          |
| You want to find all descendants of given type        | Yes!      | -          |
| You'd like to get ordered results                     | Yes!      | -          |

[1] - Actually, the `find()` operation uses QUERY strategy by default, which means that the selector string is transformed to a SQL2 query. However, the transformation process is very naïve and simply skips all conditions that can't be easily transformed to SQL2 (eg. selector `[jcr:content/jcr:title=some title]` won't be transformed as it contains some subresource reference). The result of this query is then filtere manually. See [searchStrategy](methods.html#searchstrategystrategy) for more details.
