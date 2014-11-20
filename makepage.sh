#!/bin/bash
trgt=$(basename $1 ".md")
cat "template/header.htm" <(pandoc --from markdown --latexmathml -t html $1) "template/include.htm" "template/footer.htm" > "$trgt.htm"
