PACKAGER="Anton Tetov <anton@tetov.se>"
CHROOT=$$HOME/chroot

PKG-REPO=/srv/http/pkg-repo

PKGS := ${dir ${wildcard ./*/PKGBUILD}}

SRCINFO-FILES := ${addsuffix .SRCINFO,$(PKGS)}

$(PKGS):
	cd $@ && makechrootpkg -c -r /home/tetov/chroot -l $@ -- PACKAGER=$(PACKAGER)

%.SRCINFO: %PKGBUILD
	cd $(@D) && makepkg --printsrcinfo > $(@F)

check-outdated: generate-srcinfo
	aur-out-of-date -local **/.SRCINFO

chroot: pacman.conf
	mkdir -p $(CHROOT)
	mkarchroot -C pacman.conf $(CHROOT)/root base-devel

generate-srcinfo: $(SRCINFO-FILES)

lint:
	namcap -i */PKGBUILD

pacman.conf:
	curl -O https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/pacman/trunk/pacman.conf
	cat pacman.conf.addition >> pacman.conf

sign-all-and-update:
	find $(PKG-REPO) -iname "*.pkg.tar.zst" \
		-exec sh -c "test -e {}.sig || gpg -v --detach-sign --no-armor {}" \;
	repoctl update

all: $(PKGS)

.PHONY: $(PKGS) check-upstream chroot generate-srcinfo lint pacman.conf sign-all-and-update all
