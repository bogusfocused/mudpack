PROGNM = mudpack
PREFIX ?= /usr
SHRDIR ?= $(PREFIX)/share
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
ETCDIR ?= /etc
OUTDIR ?= build
BUILDDIR ?= $(OUTDIR)/mudpack
INTDIR ?= $(OUTDIR)/obj
DISTDIR ?= $(OUTDIR)/dist
MUDPACK_LIB_DIR ?= $(LIBDIR)/$(PROGNM)
MUDPACK_SHR_DIR ?= $(SHRDIR)/$(PROGNM)
MUDPACK_VERSION ?= $(shell git describe --tags || true)
ifeq ($(MUDPACK_VERSION),)
MUDPACK_VERSION := 0.9
endif

.PHONY: clean build-dir install build install-lib mudpack mudpack.debug dist

clean:
	@rm -rf '$(OUTDIR)'

build-dir: clean
	@mkdir '$(OUTDIR)'
	@mkdir '$(BUILDDIR)'/{,lib,bin,share}
	@mkdir '$(INTDIR)'

mudpack: src/mudpack.in build-dir
	sed -e 's|@MUDPACK_LIB_DIR@|$(MUDPACK_LIB_DIR)|' \
		-e 's|@MUDPACK_DEBUG@|false|' \
		-e 's|@MUDPACK_CONF@|/etc/mudpack.conf|' \
		-e 's|@MUDPACK_SHR_DIR@|$(MUDPACK_SHR_DIR)|' \
	    -e 's|@MUDPACK_VERSION@|$(MUDPACK_VERSION)|' \
		src/mudpack.in >$(INTDIR)/$@.in
	@install -Dm755 '$(INTDIR)/$@.in' '$(BUILDDIR)/bin/$@'

mudpack.debug: src/mudpack.in build-dir
	sed -e 's|@MUDPACK_LIB_DIR@|$(BUILDDIR)/lib|' \
		-e 's|@MUDPACK_DEBUG@|true|' \
		-e 's|@MUDPACK_CONF@|mudpack.conf|' \
		-e 's|@MUDPACK_SHR_DIR@|$(BUILDDIR)/share|' \
	    -e 's|@MUDPACK_VERSION@|$(MUDPACK_VERSION)|' \
		src/mudpack.in >$(INTDIR)/$@.in
	@install -Dm755 '$(INTDIR)/$@.in' '$(INTDIR)/$@'

install-lib: build-dir
	@install -Dm755 src/lib/mudpack_aur  -t '$(BUILDDIR)/lib'
	@ln -s ./mudpack_aur '$(BUILDDIR)/lib/mudpack-add'
	@ln -s ./mudpack_aur '$(BUILDDIR)/lib/mudpack-remove'
	@ln -s ./mudpack_aur '$(BUILDDIR)/lib/mudpack-list'
	@ln -s ./mudpack_aur '$(BUILDDIR)/lib/mudpack-update'
	@install -Dm755 src/lib/mudpack_run  -t '$(BUILDDIR)/lib'
	@ln -s ./mudpack_run '$(BUILDDIR)/lib/mudpack-run'
	@ln -s ./mudpack_run '$(BUILDDIR)/lib/mudpack-runas'
	@install -Dm755 src/lib/mudpack-*  -t '$(BUILDDIR)/lib'
	@install -Dm755 src/lib/*.inc  -t '$(BUILDDIR)/lib'
	@install -Dm755 src/lib/templates/*  -t '$(BUILDDIR)/lib/templates'

build: build-dir mudpack mudpack.debug install-lib

install: build
	@install -Dm755 -d '$(DESTDIR)$(BINDIR)'
	@cp -r '$(BUILDDIR)/bin/' -T '$(DESTDIR)$(BINDIR)'
	@install -Dm755 -d '$(DESTDIR)$(MUDPACK_LIB_DIR)'
	@cp -r '$(BUILDDIR)/lib/' -T '$(DESTDIR)$(MUDPACK_LIB_DIR)'
	@install -Dm755 -d '$(DESTDIR)$(MUDPACK_SHR_DIR)'
	@cp -r '$(BUILDDIR)/share/' -T '$(DESTDIR)$(MUDPACK_SHR_DIR)'
	@install -Dm644 src/mudpack.conf.in '$(DESTDIR)$(ETCDIR)/$(PROGNM).conf'
	@install -Dm644 LICENSE -t '$(DESTDIR)/share/licenses/$(PROGNM)'

dist:
	$(MAKE) 'DESTDIR=$(DISTDIR)/mudpack-$(MUDPACK_VERSION)' install
	@tar -czf  $(OUTDIR)/mudpack-$(MUDPACK_VERSION).tar.gz -C $(DISTDIR) .