DOCKER_IMAGE     = ubuntu
DOCKER_TAG       = noble-20260730.1
DOCKER_PLATFORM  = linux/amd64

DEB_PACKAGES     = auditd libpam-pwquality vlock aide
DEB_REQUIREMENTS = debian-requirements.txt
APT_PACKAGES     = make zip

DOCKER_RUN = docker run --rm --platform ${DOCKER_PLATFORM} \
	-v ${CURDIR}:/home/appgate/$(shell basename $(CURDIR)) \
	-w /home/appgate/$(shell basename $(CURDIR))

CONTAINER_TARGETS = stig-customization stig-customization-offline debs upgrade-debs

.PHONY: docker-shell
docker-shell:
	$(DOCKER_RUN) -it -e IN_CONTAINER=1 ${DOCKER_IMAGE}:${DOCKER_TAG} /bin/bash -c \
	"apt-get update && apt-get install -y $(APT_PACKAGES) && /bin/bash"

ifndef IN_CONTAINER

.PHONY: $(CONTAINER_TARGETS)
$(CONTAINER_TARGETS):
	$(DOCKER_RUN) ${DOCKER_IMAGE}:${DOCKER_TAG} /bin/bash -c \
	"apt-get update && apt-get install -y $(APT_PACKAGES) && make IN_CONTAINER=1 $@"

else

stig-customization: clean-debs
	echo $@
	cd src; zip ../$@ `find`

.PHONY: debs
debs: clean-debs
	mkdir -p src/data/debian
	cd src/data/debian && apt-get download $$(cat $(CURDIR)/$(DEB_REQUIREMENTS))

stig-customization-offline: debs
	cd src; zip ../$@ `find`

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

endif

.PHONY: clean-debs
clean-debs:
	rm -rf src/data/debian

.PHONY: clean
clean: clean-debs
	$(RM) stig-customization.zip stig-customization-offline.zip
	rm -f change.log
	rm -rf venv

venv:
	python3 -m venv venv
	source venv/bin/activate && pip install --upgrade pip && pip install requests

changelog: venv
	venv/bin/python3 generate_changelog.py
