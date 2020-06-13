.PHONY: prerequisites
prerequisites:
	curl -LO https://github.com/bats-core/bats-core/archive/v1.2.0.tar.gz
	tar zxf v1.2.0.tar.gz
	cd bats-core-1.2.0; \
	  sudo ./install.sh /usr/local
	curl -LO https://github.com/koalaman/shellcheck/releases/download/v0.7.1/shellcheck-v0.7.1.linux.x86_64.tar.xz
	tar xf shellcheck-v0.7.1.linux.x86_64.tar.xz
	cd shellcheck-v0.7.1; \
	  sudo cp shellcheck /usr/local/bin; \
	  sudo chmod +x /usr/local/bin/shellcheck

.PHONY: tests
tests: prerequisites
	bats tests/
	shellcheck lib/setup-ssh.sh

.PHONY: build
build:
	npm install
	npm run build
	npm run format-check
	npm run lint

.PHONY: all
all: build
.DEFAULT_GOAL := all
