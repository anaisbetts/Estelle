SUBDIRS = \
	po 		\
	lib
	
ACLOCAL_AMFLAGS = -I m4

all-am:
	chmod +x estelle

install-data-local:
	$(mkinstalldirs) $(DESTDIR)$(bindir)
	$(INSTALL_SCRIPT) estelle $(DESTDIR)$(bindir)

EXTRA_DIST = mkinstalldirs 

CLEANFILES = estelle
