#!/bin/bash
trgt=$(basename $1 ".md")
cat "template/header.htm" <(pandoc -t html $1) "template/footer.htm" > "$trgt.htm"
