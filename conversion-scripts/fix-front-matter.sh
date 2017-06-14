MARKER="~~~~~~"
COPYING=0
TMPFILE=/tmp/$$.tmp
cat > $TMPFILE
TITLE=$(cat $TMPFILE | grep ^Title: | cut -d: -f2- | sed 's/^ *//g')

doFrontMatter() {
cat << EOFM
title=$TITLE		
type=page
status=published
${MARKER}
EOFM
}

cat $TMPFILE | while read line
do
	if [[ $COPYING -eq 1 ]]
	then
		echo "$line"
	elif [[ "$line" == "$MARKER" ]]
	then
		COPYING=1
		doFrontMatter
	fi
done | grep -v ^Title:
rm -f $TMPFILE