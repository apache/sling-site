div(class:"termin"){
    div(class:"month","${post.date?.format("MMM")}")
    newLine()
    div(class:"date","${post.date?.format("dd")}")
    newLine()
    div(class:"year","${post.date?.format("yyyy")}")
}
