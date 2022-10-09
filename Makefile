SHELL := /usr/bin/env bash
VERSION := $(shell cat pubspec.yaml | grep "^version: " | cut -c 10- | sed 's/+/\-/')
SHORT_VERSION := $(shell xx="$(VERSION)"; arrVersion=($${xx//-/ }); echo $${arrVersion[0]};)
BUILD_ROOT := ../build-package
BASE_NAME := quickobs_$(SHORT_VERSION)
BUILD_DIR := $(BUILD_ROOT)/$(BASE_NAME)
BIN_TAR := $(BUILD_ROOT)/$(BASE_NAME).orig.tar
SRC_TAR := $(BUILD_ROOT)/$(BASE_NAME)-src.tar
FLUTTER := /opt/flutter/bin/flutter

version:
	@echo VERSION is $(VERSION)
	@echo SHORT_VERSION is $(SHORT_VERSION)
	@echo BUILD_ROOT is $(BUILD_ROOT)
	@echo type "make bin" to create binary package
	@echo type "make ppa" to upload to launchpad

spawn:
	echo "#! /bin/env bash" > /home/yannick/machines/focal/home/yannick/build.sh
	echo "" >> /home/yannick/machines/focal/home/yannick/build.sh
	echo "cd /opt/flutter-projects/quickobs" >> /home/yannick/machines/focal/home/yannick/build.sh
	echo "make bin" >> /home/yannick/machines/focal/home/yannick/build.sh
	sudo systemd-nspawn -D /home/yannick/machines/focal --resolv-conf=off --bind-ro=/home/yannick/machines/resolv.conf:/etc/resolv.conf --bind=/opt/flutter:/opt/flutter --bind=/opt/flutter-projects:/opt/flutter-projects -u yannick /home/yannick/build.sh

distclean:
	$(FLUTTER) clean
	rm -rf $(BUILD_ROOT)/*

quickobs: distclean
	$(FLUTTER) pub get
	$(FLUTTER) build linux --release

bin: quickobs
	mkdir -p $(BUILD_DIR)
	cp -a build/linux/x64/release/bundle/* $(BUILD_DIR)
	cp -a assets/resources $(BUILD_DIR)
	tar -C $(BUILD_ROOT) -c -v -f $(BIN_TAR) $(BASE_NAME)
	xz -z $(BIN_TAR)

ppa: version
	cp $(BIN_TAR).xz /mnt/data/dev/debianpackages/quickobs.deb/
	cd /mnt/data/dev/debianpackages/quickobs.deb/quickobs ; \
	dch -v $(VERSION) "New changelog message" ; \
	vi debian/changelog ; \
	for dist in focal jammy kinetic; do \
		sed -i "1 s/^\(.*\)) UNRELEASED;\(.*\)\$$/\1~xxx1.0) xxx;\2/g" debian/changelog ; \
		sed -i "1 s/~.*1\.0) .*;\(.*\)\$$/~$${dist}1.0) $$dist;\1/g" debian/changelog ; \
		dpkg-buildpackage -d -S -sa ; \
		dput ppa:yannick-mauray/quickobs ../quickobs_$(VERSION)~$${dist}1.0_source.changes ; \
	done

download: version
	for dist in focal jammy kinetic; do \
		aria2c https://launchpad.net/~yannick-mauray/+archive/ubuntu/quickobs/+files/quickobs_$(VERSION)~$${dist}1.0_amd64.deb; \
	done

src:
	mkdir -p $(BUILD_ROOT)
	tar -C .. -c -v -f $(SRC_TAR) --exclude .git --transform 's/^quickobs/$(BASE_NAME)/' quickobs
	rm ${SRC_TAR}.xz
	xz -z $(SRC_TAR)
