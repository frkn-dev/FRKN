#!/bin/bash

 if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

country_list=$(curl https://api.fuckrkn1.org/locations)
values=$(jq -r '.[].code' <<< $country_list)

PS3="Change VPN country: "
select character in $( IFS=$' '; echo "${values[*]}" ); do
  if [[ $character ]]; then
    break
  fi
done

name="Frkn_$character"
conf_path="/etc/NetworkManager/system-connections/$name.nmconnection"

nmcli c delete $name >/dev/null 2>&1

json=$(curl https://api.fuckrkn1.org/peer\?location\=$character)

iface=$(echo "$json" | jq -r ".iface")
key=$(echo "$iface" | jq -r ".key")
address=$(echo "$iface" | jq -r ".address")
dns=$(echo "$iface" | jq -r ".dns")

sudo nmcli connection add type wireguard \
  connection.id "$name" connection.interface-name "$name" connection.autoconnect 0 \
  wireguard.private-key "$key" \
  ipv4.method manual ipv4.dns "$dns" ipv4.address "$address"

peer=$(echo "$json" | jq -r ".peer")
pubkey=$(echo "$peer" | jq -r ".pubkey")
allowed_ips=$(echo "$peer" | jq -r ".allowed_ips")
endpoint=$(echo "$peer" | jq -r ".endpoint")

bash -c "echo  >> $conf_path"
bash -c "echo '[wireguard-peer.$pubkey]' >> $conf_path"
bash -c "echo 'endpoint=$endpoint' >> $conf_path"
bash -c "echo 'persistent-keepalive=25' >> $conf_path"
bash -c "echo 'allowed-ips=$allowed_ips;' >> $conf_path"

nmcli connection load "$conf_path"
