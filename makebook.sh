#!/bin/bash
for f in *.md
do
	if [ "$f" != "README.md" ]
	then
		pandoc -s -f markdown -t latex "$f" | pdflatex --jobname book --
	fi
done
