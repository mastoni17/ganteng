#!/bin/sh

echo ""
echo "#########################################################"
echo "## -> MASTONI GANTENG-Server by MASTONI-ID Software       ##"
echo "## -> Author : Mastoni Ganteng                           ##"
echo "## -> Email : tonilagi12@gmail.com               ##"
echo "## -> Wa    : 085325108022                             ##"
echo "## -> (c) 2023-2025, Mastoni Ganteng-ID Software         ##"
echo "#########################################################"
echo ""

BIN=/usr/bin
CONFIGS=/etc/noobzvpns
SYSTEMD=/etc/systemd/system
SYSTEMCTL=$(which systemctl)

if [ `id -u` != "0" ]; then
    echo "Error at uninstallation, please run uninstaller as root"
    exit 1
fi

echo "Uninstalling NoobzVpn-Server..."
if [ -f $SYSTEMD/noobzvpns.service ]; then
    $SYSTEMCTL stop noobzvpns.service
    $SYSTEMCTL disable noobzvpns.service
    rm $SYSTEMD/noobzvpns.service
    $SYSTEMCTL daemon-reload
fi
if [ -f $BIN/noobzvpns ]; then
    rm $BIN/noobzvpns
fi
if [ -d $CONFIGS ]; then
    rm -rf $CONFIGS
fi
echo "Uninstall NoobzVpn-Server completed"
