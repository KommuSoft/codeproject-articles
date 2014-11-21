all :
	bash makeall.sh
book : 
	bash makebook.sh
clean :
	rm -rf *.tex *.aux *.log
install : 
	sudo apt-get install coreutils make bash pandoc
%.htm : %.md template/*.htm *.sh Makefile
	bash makepage.sh $<
