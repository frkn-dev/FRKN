#!/bin/bash

DST_DIR=$HOME/.pki/fuckRKN1
SRC_URL="https://github.com/nezavisimost/FuckRKN1/raw/main/client-conf/vpnclient.p12"
NM_CONN_ID='FuckRKN1'

sudo apt-get update 2> /dev/null && sudo apt-get install -y network-manager-strongswan 2> /dev/null \
|| sudo pacman -Syu 2> /dev/null && sudo pacman -S networkmanager-strongswan 2> /dev/null \
|| sudo yum install NetworkManager-strongswan-gnome 2> /dev/null \
|| sudo emerge --sync 2> /dev/null && sudo emerge net-vpn/networkmanager-strongswan 2> /dev/null \
|| sudo yum install epel-release && sudo yum --enablerepo=epel install NetworkManager-strongswan-gnome

wget $SRC_URL -P /tmp

if [ $? != 0 ]; then
  echo "Failed to download $SRC_URL"
  exit
fi

mkdir -p $DST_DIR > /dev/null

CACERT="$DST_DIR/ca.cer"
CLIENT_CERT="$DST_DIR/client.cer"
CLIENT_KEY="$DST_DIR/client.key"

openssl_has_legacy=$(openssl pkcs12 -help 2>&1 | grep legacy)

if [ -z "$openssl_has_legacy" ]
then
  openssl_legacy_opt=''

else
  openssl_legacy_opt='-legacy'
fi

openssl pkcs12 -in /tmp/vpnclient.p12 -cacerts -nokeys -out $CACERT $openssl_legacy_opt -password "pass:" 
openssl pkcs12 -in /tmp/vpnclient.p12 -clcerts -nokeys -out $CLIENT_CERT $openssl_legacy_opt  -password "pass:"
openssl pkcs12 -in /tmp/vpnclient.p12 -nocerts -nodes  -out $CLIENT_KEY $openssl_legacy_opt  -password "pass:"

rm /tmp/vpnclient.p12

sudo chown $USER.$USER $CACERT $CLIENT_CERT $CLIENT_KEY
sudo chmod 600 $CACERT $CLIENT_CERT $CLIENT_KEY

nmcli c delete $NM_CONN_ID > /dev/null 2>&1

nmcli c add type vpn ifname -- vpn-type strongswan connection.id $NM_CONN_ID connection.autoconnect no vpn.data 'address = lt.fuckrkn1.xyz, certificate = '$CACERT', encap = no, esp = aes128gcm16, ipcomp = no, method = key, proposal = yes, usercert = '$CLIENT_CERT', userkey = '$CLIENT_KEY', virtual = yes'
