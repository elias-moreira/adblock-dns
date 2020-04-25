#!/bin/bash
apt update
apt install bind9 dnsutils -y
mkdir /var/cache/bind/rpz/
ln -s /var/cache/bind/rpz/ /etc/bind/
cp -r bind/* /etc/bind
chmod +x /etc/bind/script-rpz/gera.sh
/etc/bind/script-rpz/gera.sh
echo "FIM"
