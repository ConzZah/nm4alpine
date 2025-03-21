#!/bin/sh
  #===============================================
  # Project: nm4alpine / v0.4
  # Author:  ConzZah / ©️ 2025
  # Last Modification: 16.03.25 / 18:07
  # https://github.com/ConzZah/nm4alpine
  #===============================================

wifi_backend="wpa_supplicant"
nm="networkmanager"

# setup eudev
doas setup-devd udev

## install packages:
doas apk add "$nm" "$nm"-cli "$nm"-tui "$nm"-wifi "$nm"-wwan \
"$nm"-bluetooth "$nm"-dnsmasq "$nm"-openvpn "$nm"-bash-completion network-manager-applet

# check if iwd is installed, set as backend if that's the case
type -p iwctl >/dev/null && echo "iwd detected, setting as wifi backend.." && wifi_backend="iwd"

# install NetworkManager.conf in:
# /etc/NetworkManager/NetworkManager.conf
##########################################
echo "[main] 
dhcp=internal
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=yes
wifi.backend=$wifi_backend" > NetworkManager.conf

doas mv -f NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
##########################################

# add current user to plugdev group
doas adduser "$USER" plugdev

# symlink iptables to /sbin/iptables so wifi & bluetooth ap's ACTUALLY work
[ ! -f /sbin/iptables ] && doas ln -s /usr/sbin/iptables /sbin/iptables

# stop conflicting services & add nm as default
doas rc-service -S "$nm" start
doas rc-update add "$nm" default
doas rc-service -s networking stop
doas rc-service -s wpa_supplicant stop
doas rc-update del networking boot
doas rc-update del wpa_supplicant boot
doas rc-service "$nm" restart
doas rc-service -S "$wifi_backend" start
[ "$wifi_backend" = "iwd" ] && doas rc-update add iwd
echo -e "\nDONE, HAVE A GREAT DAY :D \n"; exit 
