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
	install -p -d $(DESTDIR)$(SBINDIR)
	install -p -m0755 memavaild $(DESTDIR)$(SBINDIR)/memavaild

	install -p -d $(DESTDIR)$(DOCDIR)
	install -p -m0644 README.md $(DESTDIR)$(DOCDIR)/README.md

	install -p -d $(DESTDIR)$(SYSCONFDIR)

	sed "s|:TARGET_DATADIR:|$(DATADIR)|" \
		memavaild.conf.in > memavaild.conf

	install -p -m0644 memavaild.conf $(DESTDIR)$(SYSCONFDIR)/memavaild.conf

	install -p -d $(DESTDIR)$(DATADIR)/memavaild

	install -p -m0644 memavaild.conf $(DESTDIR)$(DATADIR)/memavaild/memavaild.conf

	rm -fv memavaild.conf

units:
	install -p -d $(DESTDIR)$(SYSTEMDUNITDIR)

	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" \
		memavaild.service.in > memavaild.service

	install -p -m0644 memavaild.service $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

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
	rm -fv $(DESTDIR)$(SYSCONFDIR)/memavaild.conf

uninstall-units:
	# 'make uninstall-units' must not fail with error if systemctl is unavailable or returns error
	-systemctl stop memavaild.service || true
	-systemctl disable memavaild.service || true

	rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

uninstall: uninstall-base uninstall-units daemon-reload

