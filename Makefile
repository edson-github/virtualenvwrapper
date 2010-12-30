# Get the version of the app.  This is used in the doc build.
export VERSION=$(shell python setup.py --version)

# Default target is to show help
help:
	@echo "sdist          - Source distribution"
	@echo "html           - HTML documentation"
	@echo "docclean       - Remove documentation build files"
	@echo "register       - register a new release on PyPI"
	@echo "website        - build web version of docs"
	@echo "installwebsite - deploy web version of docs"
	@echo "develop        - install development version"
	@echo "test           - run the test suite"
	@echo "test-quick     - run the test suite for bash and one version of Python ($(PYTHON26))"


.PHONY: sdist
sdist: html
	rm -f dist/*.gz
	rm -rf docs/website
	python setup.py sdist
	cp -v dist/*.gz ~/Desktop

# Documentation
.PHONY: html
html:
	(cd docs && $(MAKE) html LANGUAGE="en")
	(cd docs && $(MAKE) html LANGUAGE="es")
	(cd docs && $(MAKE) html LANGUAGE="ja")

.PHONY: docclean
docclean:
	rm -rf docs/build docs/html

# Website copy of documentation
.PHONY: website
website: 
	[ ~/Devel/doughellmann/doughellmann/templates/base.html -nt docs/sphinx/web/templates/base.html ] && (echo "Updating base.html" ; cp ~/Devel/doughellmann/doughellmann/templates/base.html docs/sphinx/web/templates/base.html) || exit 0
	rm -rf docs/website
	(cd docs && $(MAKE) html BUILDING_WEB=1 BUILDDIR="website/en" LANGUAGE="en")
	(cd docs && $(MAKE) html BUILDING_WEB=1 BUILDDIR="website/es" LANGUAGE="es")
	(cd docs && $(MAKE) html BUILDING_WEB=1 BUILDDIR="website/ja" LANGUAGE="ja")

installwebsite: website
	(cd docs/website/en && rsync --rsh=ssh --archive --delete --verbose . www.doughellmann.com:/var/www/doughellmann/DocumentRoot/docs/virtualenvwrapper/)
	(cd docs/website/es && rsync --rsh=ssh --archive --delete --verbose . www.doughellmann.com:/var/www/doughellmann/DocumentRoot/docs/virtualenvwrapper/es/)
	(cd docs/website/ja && rsync --rsh=ssh --archive --delete --verbose . www.doughellmann.com:/var/www/doughellmann/DocumentRoot/docs/virtualenvwrapper/ja/)

# Register the new version on pypi
.PHONY: register
register:
	python setup.py register

# Testing
test:
	tox

test-quick:
	tox -e py27

develop:
	python setup.py develop
