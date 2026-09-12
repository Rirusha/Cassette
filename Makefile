# Makefile for devel purpose. For release packaging just use meson

ifeq ($(shell id -u), 0)
	SUDO :=
else
	SUDO := sudo
endif

.PHONY: setup setup-ci install compile test lint lint-fix

setup:
	rm -rf _build
	meson setup _build --prefix=/usr --auto-features=enabled

setup-ci:
	meson setup --wipe _build --prefix=/usr --auto-features=enabled -Dwith_lib_documentation=true

compile:
	meson compile -C _build

install: compile
	meson install -C _build

uninstall:
	$(SUDO) ninja uninstall -C _build

test: compile
	meson test -C _build

lint:
	io.elementary.vala-lint -d .
	find ./ -name "*.blp" -print0 | xargs -0 blueprint-compiler format -s 2

lint-fix:
	find ./ -name "*.blp" -print0 | xargs -0 blueprint-compiler format -f -s 2

update-potfiles:
	./app/po/update_potfiles
	./libtape/po/update_potfiles

update-pot:
	meson compile cassette-pot -C _build
	meson compile libtape-pot -C _build

update-po:
	meson compile cassette-update-po -C _build
	meson compile libtape-update-po -C _build
