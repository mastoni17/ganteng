#!/bin/bash
USER=$1
TIMER=$2

# 1. Jalankan script bawaan (z9dtrial)
/usr/local/sbin/z9dtrial ssh $USER $TIMER

# 2. Kunci password, putuskan koneksi aktif, dan hapus user SSH
usermod -L $USER
pkill -u $USER
killall -u $USER
userdel -f $USER
rm -rf /etc/ssh/${USER}

# 3. Hapus user dari database ZIVPN
ZIVPN_CONFIG="/etc/zivpn/config.json"
ZIVPN_DB="/etc/zivpn/user-db.json"
SERVICE_NAME="zivpn.service"

if command -v jq &> /dev/null && [[ -f "$ZIVPN_CONFIG" ]]; then
    # Hapus dari config.json
    jq --arg u "$USER" 'del(.auth.config[] | select(. == $u))' "$ZIVPN_CONFIG" > "${ZIVPN_CONFIG}.tmp" && mv "${ZIVPN_CONFIG}.tmp" "$ZIVPN_CONFIG"
    # Hapus dari user-db.json
    if [[ -f "$ZIVPN_DB" ]]; then
        jq --arg u "$USER" 'del(.[$u])' "$ZIVPN_DB" > "${ZIVPN_DB}.tmp" && mv "${ZIVPN_DB}.tmp" "$ZIVPN_DB"
    fi
    systemctl restart "$SERVICE_NAME"
fi
rm -f /etc/cron.d/trialssh-$USER