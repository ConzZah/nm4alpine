#!/bin/sh
  #===============================================
  # Project: nm4alpine / v0.2
  # Author:  ConzZah / ©️ 2025
  # Last Modification: 17.02.25 / 06:18
  # https://github.com/ConzZah/nm4alpine
  #===============================================

nm="networkmanager"

## install packages:
doas apk add "$nm" "$nm"-cli "$nm"-tui "$nm"-wifi "$nm"-wwan "$nm"-bluetooth "$nm"-bash-completion network-manager-applet

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
wifi.backend=wpa_supplicant" > NetworkManager.conf

doas mv -f NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

##########################################

# add current user to plugdev group

doas adduser "$USER" plugdev

# stop conflicting services & add nm as default

doas rc-service networking stop
doas rc-service wpa_supplicant stop
doas rc-service "$nm" start
doas rc-update add "$nm" default
doas rc-update del networking boot
doas rc-update del wpa_supplicant boot
doas rc-service wpa_supplicant start
echo -e "\nDONE, HAVE A GREAT DAY :D \n\nPRESS ANY KEY TO EXIT"; sleep 1; exit 
