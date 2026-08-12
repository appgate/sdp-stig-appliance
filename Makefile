DEB_PACKAGES = auditd libpam-pwquality vlock aide
DEB_REQUIREMENTS = debian-requirements.txt

stig-customization: clean-debs
	echo $@
	cd src; zip ../$@ `find`

.PHONY: debs
debs: clean-debs
	mkdir -p src/data/debian
	cd src/data/debian && apt-get download $$(cat $(CURDIR)/$(DEB_REQUIREMENTS))

stig-customization-offline: debs
	cd src; zip ../$@ `find`

.PHONY: clean-debs
clean-debs:
	rm -rf src/data/debian

venv:
	python3 -m venv venv
	source venv/bin/activate && pip install --upgrade pip && pip install requests

changelog: venv
	venv/bin/python3 generate_changelog.py

.PHONY: clean
clean: clean-debs
	$(RM) stig-customization.zip stig-customization-offline.zip
	rm -f change.log
	rm -rf venv


.PHONY: upgrade-debs
upgrade-debs:
	pkgs=$$(for pkg in $(DEB_PACKAGES); do \
		apt-cache depends --recurse \
			--no-recommends \
			--no-suggests \
			--no-conflicts \
			--no-breaks \
			--no-replaces \
			--no-enhances \
			"$$pkg" | \
			grep '^\w'; \
	done | sort -u); \
	for pkg in $$pkgs; do \
		ver=$$(apt-cache policy "$$pkg" | awk '/Candidate:/ {print $$2}'); \
		[ -n "$$ver" ] && [ "$$ver" != "(none)" ] && echo "$$pkg=$$ver"; \
	done | sort -u > $(DEB_REQUIREMENTS)
