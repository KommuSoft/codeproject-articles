all :
	bash makeall.sh
book : 
	bash makebook.sh
install : 
	sudo apt-get install coreutils make bash pandoc
%.htm : %.md template/*.htm *.sh Makefile
	bash makepage.sh $<
