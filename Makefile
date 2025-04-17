stig-customization.zip:
	echo $@
	cd src; zip ../$@ `find`

venv:
	python3 -m venv venv
	source venv/bin/activate && pip install --upgrade pip && pip install requests

changelog: venv
	venv/bin/python3 generate_changelog.py

.PHONY: clean
clean:
	$(RM) stig-customization.zip
	rm -f change.log
	rm -rf venv
