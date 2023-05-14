include config.mk

export DESTDIR=
export MODULEDIR=${DESTDIR}$(DRACUT_MODULEDIR)

ifeq ($(NEED_CRYPTSETTLE),1)
	SUBDIRS=modules/60crypt-ssh modules/cryptsettle-patch
else
	SUBDIRS=modules/60crypt-ssh
endif

.PHONY: install all clean dist $(SUBDIRS) rpm

all: $(SUBDIRS)

install: $(SUBDIRS)
	mkdir -p $(DESTDIR)/etc/dracut.conf.d/
	cp crypt-ssh.conf $(DESTDIR)/etc/dracut.conf.d/

clean: $(SUBDIRS)
	rm -f dracut-crypt-ssh-*gz config.mk

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

DISTNAME=dracut-crypt-ssh-$(shell git describe --tags | sed s:v::)
dist:
	git archive --format=tar --prefix=$(DISTNAME)/ HEAD | gzip -9 > $(DISTNAME).tar.gz

NAME		:= dracut-crypt-ssh
VERSION		:= $(shell git describe --tags | sed s:v:: | awk -F- '{print $$1}')
RELEASE 	:= $(shell git describe --tags | awk -F- '{print $$2}')
URL		:= https://github.com/dracut-crypt-ssh/dracut-crypt-ssh.git
SUMMARY		:= crypt-ssh dracut module
DESCRIPTION	:= The crypt-ssh dracut module allows remote unlocking of systems with full disk encryption via ssh.
SPECFILE	:= $(NAME).spec
rpm:
	$(RM) -r rpmbuild
	mkdir -p $(CURDIR)/rpmbuild/SOURCES/
	git archive --format=tar --prefix=$(NAME)-$(VERSION)/ HEAD | \
		gzip -9 > $(CURDIR)/rpmbuild/SOURCES/$(NAME)-$(VERSION).tar.gz
	rpmbuild -ba \
        --define="_topdir $(CURDIR)/rpmbuild" \
        --define="name $(NAME)" \
        --define="version $(VERSION)" \
        --define="release $(RELEASE)" \
        --define="summary $(SUMMARY)" \
        --define="desc $(DESCRIPTION)" \
        --define="url $(URL)"\
        --define="packager $(USER)" \
        --define="license GPLv2" \
		$(SPECFILE)
