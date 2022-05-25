chroot . weechat -r "/server add libera irc.libera.chat/6697 -autoconnect -ssl;/set irc.server.libera.autojoin #puppylinux;/quit"
chroot . run-as-spot weechat -r "/server add libera irc.libera.chat/6697 -autoconnect -ssl;/set irc.server.libera.autojoin #puppylinux;/quit"

echo '#!/bin/ash
exec weechat-shell' > usr/local/bin/defaultchat
chmod 755 usr/local/bin/defaultchat