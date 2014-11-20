#!/bin/bash
for f in *.md
do
	fl=$(basename $f ".md")
	make "$fl.htm"
done
