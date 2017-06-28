export SRC="src/main/jbake/content"
export PAT=".*jbake.*content"
export BASE="http://localhost:8820"

find $SRC -type f | sort | sed 's/\.md$/\.html/' | sed "s/${PAT}//" | while read f
do
    open $BASE$f
done
