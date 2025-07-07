# object files for shared libraries need to be compiled as position independent
# code (-fPIC) because they are mapped to any position in the address space.

VERSION := 2025.1

CFLAGS += -O0 -Wall -Werror -I./include -std=c99 -fPIC
ifndef RANLIB
	RANLIB = ranlib
endif

# COMPILING SETUP
CC        = gcc
LD        = ld
AR        = ar
RANLIB    = ranlib

.PHONY: deb
deb: bin/is_segfault
	rm -rf build/deb

	# temporary fpm source
	mkdir -p build/deb/is_segfault/usr/local
	cp -r $(addprefix ./, bin) build/deb/is_segfault/usr/local
	mkdir -p build/deb/is_segfault/usr/local/share/man/man3
	#cp -r $(MANS) build/deb/is_segfault/usr/local/share/man/man3
	fpm \
	    --after-install postinst \
	    --after-remove postrm \
	    --category apps \
	    --chdir build/deb/is_segfault \
	    --deb-priority optional \
	    --description "Intro_SW tool to provide context for segmentation fault errors in C programs" \
	    --input-type dir \
	    --maintainer "Intro_SW <perezh@unican.es>" \
	    --name is_segfault \
	    --output-type deb \
	    --package build/deb \
	    --provides is-segfault \
	    --replaces is-segfault \
	    --url https://www.istr.unican.es/asignaturas/intro_sw/ \
	    --vendor Intro_SW \
	    --version $(VERSION) \
	    --depends 'file >= 5.30' \
	    --depends binutils \
	    --depends libc-bin \
	    --depends coreutils \
	    .

	rm -rf build/deb/is_segfault

clean:
	rm -rf build/deb
