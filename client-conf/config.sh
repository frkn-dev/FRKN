#!/bin/bash

sudo apt-get update
sudo apt-get install network-manager-strongswan

echo -e '\e[33m''Если запрашивает пароль, просто нажать Enter''\e[0m'

openssl_has_legacy=$(openssl pkcs12 -help 2>&1 | grep legacy)

if [ -z "$openssl_has_legacy" ]
then
  openssl_legacy_opt=''
  
else
  openssl_legacy_opt='-legacy'
fi

openssl pkcs12 -in vpnclient.p12 -cacerts -nokeys -out ikev2vpnca.cer $openssl_legacy_opt 
openssl pkcs12 -in vpnclient.p12 -clcerts -nokeys -out vpnclient.cer $openssl_legacy_opt
openssl pkcs12 -in vpnclient.p12 -nocerts -nodes  -out vpnclient.key $openssl_legacy_opt

rm vpnclient.p12

sudo chown root.root ikev2vpnca.cer vpnclient.cer vpnclient.key
sudo chmod 600 ikev2vpnca.cer vpnclient.cer vpnclient.key

pwd=$(pwd)
sert=$pwd"/ikev2vpnca.cer"
usert=$pwd"/vpnclient.cer"
ukey=$pwd"/vpnclient.key"

nmcli c add type vpn ifname -- vpn-type strongswan connection.id 'fuckRKN1' connection.autoconnect no vpn.data 'address = lt.fuckrkn1.xyz, certificate = '$sert', encap = no, esp = aes128gcm16, ipcomp = no, method = key, proposal = yes, usercert = '$usert', userkey = '$ukey', virtual = yes'
