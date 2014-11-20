#!/bin/bash
trgt=$(basename $1 ".md")
cat "template/header.htm" <(pandoc --from markdown-tex_math_dollars-raw_tex --latexmathml -t html $1) "template/footer.htm" > "$trgt.htm"
