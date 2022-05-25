if [ -f ../adrv/usr/bin/weechat-headless ]; then
	mv -f ../adrv/usr/bin/weechat-headless usr/bin/
	cp -r ../adrv/usr/lib/weechat usr/lib/
	chroot . weechat-headless -r "/server add libera irc.libera.chat/6697 -autoconnect -ssl;/set irc.server.libera.autojoin #puppylinux;/quit"
	chroot . run-as-spot weechat-headless -r "/server add libera irc.libera.chat/6697 -autoconnect -ssl;/set irc.server.libera.autojoin #puppylinux;/quit"
	rm -rf usr/lib/weechat
else
	chroot . weechat-headless -r "/server add libera irc.libera.chat/6697 -autoconnect -ssl;/set irc.server.libera.autojoin #puppylinux;/quit"
	chroot . run-as-spot weechat-headless -r "/server add libera irc.libera.chat/6697 -autoconnect -ssl;/set irc.server.libera.autojoin #puppylinux;/quit"
fi
rm -f usr/bin/weechat-headless

echo '#!/bin/ash
exec weechat-shell' > usr/local/bin/defaultchat
chmod 755 usr/local/bin/defaultchat