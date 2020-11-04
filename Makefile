DESTDIR ?=
PREFIX ?=         /usr/local
SYSCONFDIR ?=     /usr/local/etc
SYSTEMDUNITDIR ?= /usr/local/lib/systemd/system

SBINDIR ?= $(PREFIX)/sbin
DATADIR ?= $(PREFIX)/share
DOCDIR ?=  $(DATADIR)/doc/memavaild
MANDIR ?=  $(DATADIR)/man

PANDOC := $(shell command -v pandoc 2> /dev/null)

all:
	@ echo "Use: make install, make uninstall"

update-manpage:

ifdef PANDOC
	pandoc MANPAGE.md -s -t man > memavaild.8
else
	@echo "pandoc is not installed, skipping manpages generation"
endif

base:
	install -p -d $(DESTDIR)$(SBINDIR)
	install -p -m0755 memavaild $(DESTDIR)$(SBINDIR)/memavaild

	install -p -d $(DESTDIR)$(SYSCONFDIR)
	install -p -m0644 memavaild.conf $(DESTDIR)$(SYSCONFDIR)/memavaild.conf

	install -p -d $(DESTDIR)$(DATADIR)/memavaild
	install -p -m0644 memavaild.conf $(DESTDIR)$(DATADIR)/memavaild/memavaild.conf

	install -p -d $(DESTDIR)$(DOCDIR)
	install -p -m0644 README.md $(DESTDIR)$(DOCDIR)/README.md
	install -p -m0644 MANPAGE.md $(DESTDIR)$(DOCDIR)/MANPAGE.md

	install -p -d $(DESTDIR)$(MANDIR)/man8
	sed "s|:SYSCONFDIR:|$(SYSCONFDIR)|g; s|:DATADIR:|$(DATADIR)|g" \
		memavaild.8 > tmp.memavaild.8
	gzip -9cn tmp.memavaild.8 > $(DESTDIR)$(MANDIR)/man8/memavaild.8.gz
	rm -fv tmp.memavaild.8

units:
	install -p -d $(DESTDIR)$(SYSTEMDUNITDIR)

	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" \
		memavaild.service.in > memavaild.service

	install -p -m0644 memavaild.service $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

	rm -fv memavaild.service

useradd:
	-useradd -r -s /bin/false memavaild &>/dev/null

chcon:
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service &>/dev/null

daemon-reload:
	-systemctl daemon-reload

build_deb: base units

reinstall-deb:
	set -v
	deb/build.sh
	sudo apt install --reinstall ./deb/package.deb

install: base units useradd chcon daemon-reload
	# This is fine.

uninstall-base:
	rm -fv $(DESTDIR)$(SBINDIR)/memavaild
	rm -fv $(DESTDIR)$(SYSCONFDIR)/memavaild.conf
	rm -fv $(DESTDIR)$(MANDIR)/man8/memavaild.8.gz
	rm -fvr $(DESTDIR)$(DATADIR)/memavaild/
	rm -fvr $(DESTDIR)$(DOCDIR)/

uninstall-units:
	# 'make uninstall-units' must not fail with error if systemctl is unavailable or returns error
	-systemctl stop memavaild.service || true
	-systemctl disable memavaild.service || true

	rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

uninstall: uninstall-base uninstall-units daemon-reload
