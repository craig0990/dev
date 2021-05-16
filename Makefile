prefix ?= /usr/local
exec_prefix ?= $(prefix)/bin
sysconfgdir ?= $(prefix)/etc

.PHONY: install
install:
	mkdir -p "$(exec_prefix)"
	cp dev "$(exec_prefix)/dev"
	mkdir -p "$(sysconfgdir)/bash_completion.d"
	cp completion/dev "$(sysconfgdir)/bash_completion.d/dev"
