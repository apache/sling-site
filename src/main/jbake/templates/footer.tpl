import java.text.SimpleDateFormat

p() {
    yield "Apache Sling, Sling, Apache, the Apache feather logo, and the Apache Sling project "
    yield "logo are trademarks of The Apache Software Foundation. All other marks mentioned "
    yield "may be trademarks or registered trademarks of their respective owners."
}
p() {
    String currentYear = new SimpleDateFormat("YYYY").format(new Date())
    yield "Copyright \u00a9 2007-${currentYear} The Apache Software Foundation."
}
