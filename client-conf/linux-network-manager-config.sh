#!/bin/bash

DST_DIR=$HOME/.pki/FuckRKN1

sudo apt-get update
sudo apt-get install -y network-manager-strongswan

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

openssl pkcs12 -in vpnclient.p12 -cacerts -nokeys -out $CACERT $openssl_legacy_opt -password "pass:" 
openssl pkcs12 -in vpnclient.p12 -clcerts -nokeys -out $CLIENT_CERT $openssl_legacy_opt  -password "pass:"
openssl pkcs12 -in vpnclient.p12 -nocerts -nodes  -out $CLIENT_KEY $openssl_legacy_opt  -password "pass:"

sudo chown $USER.$USER $CACERT $CLIENT_CERT $CLIENT_KEY
sudo chmod 600 $CACERT $CLIENT_CERT $CLIENT_KEY 

nmcli c add type vpn ifname -- vpn-type strongswan connection.id 'fuckRKN1' connection.autoconnect no vpn.data 'address = lt.fuckrkn1.xyz, certificate = '$CACERT', encap = no, esp = aes128gcm16, ipcomp = no, method = key, proposal = yes, usercert = '$CLIENT_CERT', userkey = '$CLIENT_KEY', virtual = yes'
