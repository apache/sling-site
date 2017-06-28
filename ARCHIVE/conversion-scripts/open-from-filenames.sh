export BASE="http://localhost:8820"
while read f
do
  path=$(echo $f | sed 's/\content\///' | sed 's/md$/html/')
  open "$BASE/$path"; 
done
