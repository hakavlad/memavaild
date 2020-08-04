DESTDIR ?=
PREFIX ?=         /usr/local
SYSCONFDIR ?=     /usr/local/etc
SYSTEMDUNITDIR ?= /usr/local/lib/systemd/system



SBINDIR ?= $(PREFIX)/sbin
DATADIR ?= $(PREFIX)/share
DOCDIR ?=  $(DATADIR)/doc/memavaild

all:
	@ echo "Use: make install, make uninstall"

base:
	install -d $(DESTDIR)$(SBINDIR)
	install -m0755 memavaild $(DESTDIR)$(SBINDIR)/memavaild

	install -d $(DESTDIR)$(DOCDIR)
	install -m0644 README.md $(DESTDIR)$(DOCDIR)/README.md

	install -d $(DESTDIR)$(SYSCONFDIR)

	sed "s|:TARGET_DATADIR:|$(DATADIR)|" \
		memavaild.conf.in > memavaild.conf

	install -m0644 memavaild.conf $(DESTDIR)$(SYSCONFDIR)/memavaild.conf

	install -d $(DESTDIR)$(DATADIR)/memavaild

	install -m0644 memavaild.conf $(DESTDIR)$(DATADIR)/memavaild/memavaild.conf

	rm -fv memavaild.conf

units:
	install -d $(DESTDIR)$(SYSTEMDUNITDIR)

	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" \
		memavaild.service.in > memavaild.service

	install -m0644 memavaild.service $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

	rm -fv memavaild.service

useradd:
	-useradd -r -M -s /bin/false memavaild

chcon:
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service
	# Don't worry if you see "make: [chcon] Error 1", just ignore it.

daemon-reload:
	-systemctl daemon-reload

install: base units useradd chcon daemon-reload

uninstall-base:
	rm -fv $(DESTDIR)$(SBINDIR)/memavaild
	rm -fvr $(DESTDIR)$(DOCDIR)/

uninstall-units:
	# 'make uninstall-units' must not fail with error if systemctl is unavailable or returns error
	-systemctl stop memavaild.service || true
	-systemctl disable memavaild.service || true

	rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

uninstall: uninstall-base uninstall-units daemon-reload

