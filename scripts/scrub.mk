#!/usr/bin/make -f

MAKEFLAGS = --jobs 6 --load-average 8 --keep-going # datacollector.infra.ooni.io specs

.PHONY: all scrub

ifndef TMUX
    $(error Run this makefile under TMUX)
endif

all: scrub

# all flag files are created in separate directory
PRJ = scrub
-include $(PRJ)/.deps

$(PRJ)/.keep :
	mkdir -p $(PRJ)
	touch $@

$(PRJ)/.deps : $(PRJ)/.keep
	ls /data/ooni/public/autoclaved | sed 's,.*,reprocess : $(PRJ)/&.flag,' >$@.tmp
	mv $@.tmp $@

$(PRJ)/%.flag: $(PRJ)/.keep
	( cd /data/ooni/public/autoclaved && ~/scrub-autoclaved $*/index.json.gz ) >$@.tmp
	mv $@.tmp $@
