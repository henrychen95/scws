# Automake file on top directory
# $Id$

AUTOMAKE_OPTIONS = 1.5 subdir-objects

SUBDIRS = . libscws cli etc

DIST_SUBDIRS = libscws cli etc

EXTRA_DIST = API.md README.md INSTALL.md RELEASING.md docs phpext win32 acprep scripts tests

UNISON_OPT = -auto -batch -prefer newer -terse -times -logfile /dev/null
	
dict:
	cd etc && make dict

dist-dict:
	cd etc && make dist-dict

sync-web:
	rsync -avzp --delete ./web/* d10:/data/dockers/php-runner/www/xunsearch/web/scws

dist-web: dist-bzip2
	mv -f $(distdir).tar.bz2 web/down
	cd etc && tar czf ../web/down/rules.tgz *.ini
	make sync-web

