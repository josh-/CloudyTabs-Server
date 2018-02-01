BINARY?=cloudytabs-server
BUILD_FOLDER?=.build
PREFIX?=/usr/local
PROJECT?=cloudytabs-server
RELEASE_BINARY_FOLDER?=$(BUILD_FOLDER)/release/$(PROJECT)

build:
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(RELEASE_BINARY_FOLDER) $(PREFIX)/bin/$(BINARY)
