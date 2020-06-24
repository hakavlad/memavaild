DESTDIR ?=
PREFIX ?=         /usr/local
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

units:
	install -d $(DESTDIR)$(SYSTEMDUNITDIR)

	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" \
		memavaild.service.in > memavaild.service

	install -m0644 memavaild.service $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

	rm -fv memavaild.service

chcon:
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

daemon-reload:
	-systemctl daemon-reload

install: base units chcon daemon-reload

uninstall-base:
	rm -fv $(DESTDIR)$(SBINDIR)/memavaild
	rm -fvr $(DESTDIR)$(DOCDIR)/

uninstall-units:
	# 'make uninstall-units' must not fail with error if systemctl is unavailable or returns error
	-systemctl stop memavaild.service || true
	-systemctl disable memavaild.service || true

	rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/memavaild.service

uninstall: uninstall-base uninstall-units daemon-reload

