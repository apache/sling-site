#!/bin/bash
# conversion of the Sling website to JBake
# generates a conversion script for links
find content -name '*.md' | while read f
do
	r=$(echo $f | sed 's/^content//' | sed 's/\//\\\//g' | sed 's/md$/html/')
	b=$(basename $f | sed 's/\.md/\.path/')
	echo "sed s'/{{ *refs\.${b} *}}/${r}/g'" \| \\
done
echo cat