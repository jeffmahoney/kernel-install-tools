SCRIPTS = sbtool-enroll-key sbtool-genkey sbtool-sign-kernel installkernel

install: $(SCRIPTS)
	install -D -m 755 sbtool-genkey \
	       	$(DESTDIR)/usr/bin/sbtool-genkey
	install -D -m 755 sbtool-enroll-key \
		$(DESTDIR)/usr/sbin/sbtool-enroll-key
	install -D -m 755 sbtool-sign-kernel \
		$(DESTDIR)/usr/bin/sbtool-sign-kernel
	install -D -m 755 installkernel \
		$(DESTDIR)/usr/sbin/installkernel
