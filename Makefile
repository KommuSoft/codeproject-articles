all :
	bash makeall.sh
%.htm : %.md template/*.htm
	bash makepage.sh $<
