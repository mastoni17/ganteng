#!/bin/bash

# ==========================================
# Color
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
NC='\033[0m'

# ==========================================
# Permission
# ==========================================

MYIP=$(wget -qO- ipinfo.io/ip)

echo -e "${CYAN}Checking VPS...${NC}"

# kalau memang ingin dicek izin, ubah bagian ini
echo -e "${GREEN}Permission Accepted...${NC}"

apt-get update -qq
apt-get install -y jq curl

# ==========================================
# Cloudflare
# ==========================================

DOMAIN="mastoni.site"
CF_TOKEN=""

sub=$(tr -dc a-z0-9 </dev/urandom | head -c6)

SUB_DOMAIN="${sub}.${DOMAIN}"
WILD_DOMAIN="*.${sub}.${DOMAIN}"

IP=$(wget -qO- ipinfo.io/ip)

cf_request() {
    local METHOD="$1"
    local URL="$2"
    local DATA="$3"

    if [[ -z "$DATA" ]]; then
        curl -s -X "$METHOD" "$URL" \
            -H "Authorization: Bearer ${CF_TOKEN}" \
            -H "Content-Type: application/json"
    else
        curl -s -X "$METHOD" "$URL" \
            -H "Authorization: Bearer ${CF_TOKEN}" \
            -H "Content-Type: application/json" \
            --data "$DATA"
    fi
}

ZONE=$(cf_request GET \
"https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" "" \
| jq -r '.result[0].id')

if [[ -z "$ZONE" || "$ZONE" == "null" ]]; then
    echo -e "${RED}Zone tidak ditemukan!${NC}"
    exit 1
fi

update_record() {

    local HOST="$1"

    echo -e "${GREEN}Updating DNS ${HOST}${NC}"

    RECORD=$(cf_request GET \
    "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${HOST}" "" \
    | jq -r '.result[0].id')

    if [[ -z "$RECORD" || "$RECORD" == "null" ]]; then

        RECORD=$(cf_request POST \
        "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
        "{\"type\":\"A\",\"name\":\"${HOST}\",\"content\":\"${IP}\",\"ttl\":120,\"proxied\":false}" \
        | jq -r '.result.id')

    fi

    cf_request PUT \
    "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
    "{\"type\":\"A\",\"name\":\"${HOST}\",\"content\":\"${IP}\",\"ttl\":120,\"proxied\":false}" >/dev/null

}

update_record "$SUB_DOMAIN"
update_record "$WILD_DOMAIN"

echo "$SUB_DOMAIN" >/root/domain

mkdir -p /usr/bin/xray
mkdir -p /etc/xray

cp /root/domain /etc/xray

echo -e "${GREEN}Host : ${SUB_DOMAIN}${NC}"

rm -f /root/cf.sh