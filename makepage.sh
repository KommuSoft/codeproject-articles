trgt=$(basename $1 ".md")
pandoc -o "$trgt.htm" $1
