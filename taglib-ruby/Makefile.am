INCLUDES =

AM_CFLAGS = -fPIC -Wall -g -fno-strict-aliasing -O2 -I. \
	$(TAGLIB_CFLAGS)				\
	$(RUBY_CFLAGS)
AM_CXXFLAGS = $(AM_CFLAGS)

lib_LTLIBRARIES = libtagruby.la

taglib_wrap.cxx: taglib.i
	$(SWIG) -c++ `echo "$(AM_CXXFLAGS)" | ruby -e 'puts gets.split.collect{|x| x.gsub(/-[^I]\S*/,"")}.join(" ")'` -ruby -o $@ $<

libtagruby_ladir = .
libtagruby_la_LDFLAGS = -avoid-version -shared
libtagruby_la_SOURCES = \
	taglib_wrap.cxx

libtagruby_la_LIBADD = -lpthread -ldl -lcrypt -lm -lc -lstdc++ \
	$(TAGLIB_LIBS)

DISTFILES = \
	taglib.i

CLEANFILES = \
	taglib_wrap.cxx
