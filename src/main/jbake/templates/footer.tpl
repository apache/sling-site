import java.text.SimpleDateFormat

p() {
    yield '''Apache Sling, Sling, Apache, the Apache feather logo, and the Apache Sling project
    logo are trademarks of The Apache Software Foundation. All other marks mentioned 
    may be trademarks or registered trademarks of their respective owners.'''
}
p() {
    String currentYear = new SimpleDateFormat("YYYY").format(new Date())
    yield "Copyright \u00a9 2007-${currentYear}"
    a(href:'https://www.apache.org/') {
        yield 'The Apache Software Foundation'
    }
    yield '|'
    a(href:'https://privacy.apache.org/policies/privacy-policy-public.html') {
        yield 'Privacy Policy'
    }
}
