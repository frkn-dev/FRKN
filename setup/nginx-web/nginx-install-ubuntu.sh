#!/bin/bash

apt update > /dev/null 2>&1
if ! $(apt list --installed 2>/dev/null | grep -q -w curl); then 
    printf "Installing curl..."
    apt install -y curl > /dev/null 2>&1
    echo "Done"
fi
if ! $(apt list --installed 2>/dev/null | grep -q -w gnupg2); then
    printf "Installing gnupg2..."
    apt install -y gnupg2 > /dev/null 2>&1
    echo "Done"
fi
if ! $(apt list --installed 2>/dev/null | grep -q -w ca-certificates); then
    printf "Installing ca-certificates..."
    apt install -y ca-certificates > /dev/null 2>&1
    echo "Done"
fi
if ! $(apt list --installed 2>/dev/null | grep -q -w lsb-release); then
    printf "Installing lsb-release..."
    apt install -y lsb-release > /dev/null 2>&1
    echo "Done"
fi
if ! $(apt list --installed 2>/dev/null | grep -q -w ubuntu-keyring); then
    printf "Installing ubuntu-keyring..."
    apt install -y ubuntu-keyring > /dev/null 2>&1
    echo "Done"
fi
if ! $(apt list --installed 2>/dev/null | grep -q -w nginx); then
    printf "Installing nginx..."
    curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
        http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
            | > /etc/apt/sources.list.d/nginx.list
    apt update > /dev/null 2>&1
    apt install -y nginx > /dev/null 2>&1
    echo "Done"
fi

export SITE_NGINX_CONFIG=web-server.conf
if [ ! -f "/etc/nginx/sites-available/${SITE_NGINX_CONFIG}" ]; then
    printf "Adding Nginx site config: ${SITE_NGINX_CONFIG} "
    mkdir -p /etc/nginx/sites-available/
    mkdir -p /etc/nginx/sites-enabled/
    cp $SITE_NGINX_CONFIG /etc/nginx/sites-available/
    ln -sf /etc/nginx/sites-available/$SITE_NGINX_CONFIG /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    echo "Done"

    printf "Checking config syntax..."
    if ! $(nginx -qt); then
        echo "Config syntax check failed. Exit."
        exit
    fi
    echo "Done"
    printf "Reloading nginx..."
    if ! $((service nginx status > /dev/null 2>&1) || service nginx start > /dev/null 2>&1); then
        echo "Failed to start nginx service. Exit."
        exit
    fi
    if ! $(nginx -s reload); then
        echo "Failed to reload nginx service. Exit."
        exit
    fi
    echo "Done"
fi


if [ ! -d /etc/letsencrypt/live/s.fuckrkn1.xyz ]; then
    printf "Installing certbot and configuring SSL certificates..."
    DOMAINS='s.fuckrkn1.xyz'
    EMAIL='the2pizza@proton.me'

    ln -fs /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata > /dev/null 2>&1
    apt install -y certbot python3-certbot-nginx > /dev/null 2>&1

    certbot run -n --nginx --agree-tos -d "$DOMAINS" -m "$EMAIL" --redirect
    
    echo "Done"
fi

if [ ! -f /etc/cron.d/certbot ]; then
    apt install cron
    printf "Configuring cron..."
    cat > /etc/cron.d/certbot <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew
EOF
    service cron restart
    [ "$?" == "0" ] || ( echo "Failed to restart cron. Exit"; exit 1 )
    echo "Done"
fi
