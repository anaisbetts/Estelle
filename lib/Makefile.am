GLADE_SOURCES = \
	gtk-ui/EntryDialog.glade \
	gtk-ui/ButtonDialog.glade \
	gtk-ui/MainWindow.glade

GTKUI_SOURCES = \
	$(GLADE_SOURCES) \
	gtk-ui/mainwindow.rb 

TAGGER_SOURCES = \
	taggers/taglib-ruby.rb

SOURCES = \
	platform.rb \
	config.rb \
	main.rb \
	settings.rb \
	config.rb.in \
	library.rb \
	song.rb \
	execute_list.rb 

glade_templates = $(addsuffix .rb, $(GLADE_SOURCES))

ALL_SOURCES = \
	$(glade_templates) \
	$(GTKUI_SOURCES) \
	$(TAGGER_SOURCES) \
	$(SOURCES)

SUFFIXES = .glade .glade.rb

$(glade_templates): $(GLADE_SOURCES)
	for i in $(GLADE_SOURCES); do \
		$(RUBY) gtk-ui/ruby-glade-create-template.rb "$$i" > "$$i.rb"; \
	done


all-am: $(ALL_SOURCES) 

install-data-local: $(SOURCES)
	$(mkinstalldirs) $(DESTDIR)$(pkglibdir)
	$(mkinstalldirs) $(DESTDIR)$(pkglibdir)/gtk-ui
	$(mkinstalldirs) $(DESTDIR)$(pkglibdir)/taggers

	for i in $(SOURCES); do 				\
		$(INSTALL_DATA) "$$i" $(DESTDIR)$(pkglibdir);	\
	done

	for i in $(GTKUI_SOURCES) $(glade_templates); do 		\
		$(INSTALL_DATA) "$$i" $(DESTDIR)$(pkglibdir)/gtk-ui;	\
	done

	for i in $(TAGGER_SOURCES); do 				\
		$(INSTALL_DATA) "$$i" $(DESTDIR)$(pkglibdir)/taggers;	\
	done

uninstall-local:
	for i in $(ALL_SOURCES); do 			\
		rm -f  "$(DESTDIR)$(pkglibdir)/$$i";	\
	done

EXTRA_DIST = \
	$(ALL_SOURCES) \
	gtk-ui/ruby-glade-create-template.rb

CLEANFILES = \
	$(glade_templates)
