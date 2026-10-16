# $Id$
#

LIBTOOL = @LIBTOOL@ $(QUIET:y=--quiet)

libscwsdir = $(top_builddir)/libscws

AM_CPPFLAGS = -I$(top_builddir) -I$(top_builddir)/libscws -I$(top_srcdir)/libscws

bin_PROGRAMS = scws scws-gen-dict

scws_SOURCES = scws_cmd.c
scws_LDADD = $(libscwsdir)/libscws.la

scws_gen_dict_SOURCES = gen_dict.c
scws_gen_dict_LDADD = $(libscwsdir)/libscws.la

