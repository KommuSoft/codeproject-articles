all :
	bash makeall.sh
%.htm : %.md template/*.htm *.sh Makefile
	bash makepage.sh $<
