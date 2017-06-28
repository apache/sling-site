export BASE="http://localhost:8820"

find content -type f | sort | sed 's/\.md$/\.html/' | sed 's/^content//' | while read f
do
	open $BASE$f
done