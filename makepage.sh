#!/bin/bash
trgt=$(basename $1 ".md")
cat "template/header.htm" <$(pandoc -t htm $1) "footer.htm" > "$trgt.htm"
