PACKAGER="Anton Tetov <anton@tetov.se>"
CHROOT=$$HOME/chroot

OBJECTS= caddy-auriga wsl-open
.PHONY: $(OBJECTS) sign-all chroot all clean pull check-upstreams

$(OBJECTS):
	cd $@ && makechrootpkg -c -r /home/tetov/chroot -l $@ -- PACKAGER=$(PACKAGER) --sign

sign-all-missing:
    find . -iname "*.pkg.tar.zst" -exec sh -c "test -e {}.sig || gpg -v --detach-sign --no-armor {}" \;


check-upstream:
	aur-out-of-date -local **/.SRCINFO

pull:
	vcs pull --nested ..

clean:
	vcs custom --nested --git --args clean -ff -xd ..

pacman.conf:
	cp /etc/pacman.conf ./
	cat pacman.conf.addition >> pacman.conf

chroot: pacman.conf
	mkdir -p $(CHROOT)

all: $(OBJECTS)
