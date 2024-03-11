stig-customization.zip:
	echo $@
	cd src; zip ../$@ `find`

.PHONY: clean
clean:
	$(RM) stig-customization.zip
