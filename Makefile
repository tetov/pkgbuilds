PACKAGER="Anton Tetov <anton@tetov.se>"
CHROOT=$$HOME/chroot

PKG_REPO=/srv/http/pkg-repo

OBJECTS= caddy-auriga wsl-open rtorrent-flood

.PHONY: $(OBJECTS) sign-all chroot all clean pull check-upstreams sign-all-missing check-aur check-outdated

$(OBJECTS):
	cd $@ && makechrootpkg -c -r /home/tetov/chroot -l $@ -- PACKAGER=$(PACKAGER)

sign-all-missing:
	find $(PKG_REPO) -iname "*.pkg.tar.zst" -exec sh -c "test -e {}.sig || gpg -v --detach-sign --no-armor {}" \;
	repoctl update

generate-srcinfo:
	find . -name "PKGBUILD" -exec sh -c 'cd $$(dirname {}) && makepkg --printsrcinfo > .SRCINFO' \;

check-upstream: generate-srcinfo
	aur-out-of-date -local **/.SRCINFO

check-aur:
	repoctl status -a

check-outdated: check-upstream check-aur

lint:
	namcap -i */PKGBUILD

pull:
	vcs pull --nested .

clean:
	vcs custom --nested --git --args clean -ff -xd .

pacman.conf:
	cp /etc/pacman.conf ./
	cat pacman.conf.addition >> pacman.conf

chroot: pacman.conf
	mkdir -p $(CHROOT)
	mkarchroot -C pacman.conf $(CHROOT) base-devel

all: $(OBJECTS)
