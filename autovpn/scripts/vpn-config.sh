#!/bin/bash

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


DIR=$(dirname $0)
cd $DIR

exiterr()  { echo "Error: $1" >&2; exit 1; }
exiterr2() { exiterr "'sudo apt-get install' failed."; }
bigecho() { echo; echo "##### $1"; echo; }
conf_bk() { /bin/cp -f "$1" "$1.old-$SYS_DT" 2>/dev/null; }

check_ip() {
  IP_REGEX='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
  printf '%s' "$1" | tr -d '\n' | grep -Eq "$IP_REGEX"
}

if [ ! -e ./vpn-config.vars ]
then
        exiterr "Ldap Vars is not defined; ./vpn-config.vars doesn't exist"
fi

source $DIR/vpn-config.vars

# In case auto IP discovery fails, enter server's public IP here.
PUBLIC_IP=${VPN_PUBLIC_IP:-''}
[ -z "$PUBLIC_IP" ] && PUBLIC_IP=$(dig @resolver1.opendns.com -t A -4 myip.opendns.com +short)
check_ip "$PUBLIC_IP" || PUBLIC_IP=$(wget -t 3 -T 15 -qO- http://ipv4.icanhazip.com)
check_ip "$PUBLIC_IP" || exiterr "Cannot detect this server's public IP. Edit the script and manually enter it."


def_iface=$(route 2>/dev/null | grep -m 1 '^default' | grep -o '[^ ]*$')
[ -z "$def_iface" ] && def_iface=$(ip -4 route list 0/0 2>/dev/null | grep -m 1 -Po '(?<=dev )(\S+)')
def_state=$(cat "/sys/class/net/$def_iface/operstate" 2>/dev/null)
if [ -n "$def_state" ] && [ "$def_state" != "down" ]; then
  if ! uname -m | grep -qi '^arm'; then
    case "$def_iface" in
      wl*)
        exiterr "Wireless interface '$def_iface' detected. DO NOT run this script on your PC or Mac!"
        ;;
    esac
  fi
  NET_IFACE="$def_iface"
else
  eth0_state=$(cat "/sys/class/net/eth0/operstate" 2>/dev/null)
  if [ -z "$eth0_state" ] || [ "$eth0_state" = "down" ]; then
    exiterr "Could not detect the default network interface."
  fi
  NET_IFACE=eth0
fi

RADIUS=${RADIUS:-"false"}
YOUR_IPSEC_PSK=${IPSEC_PSK:-'HelloVPN1!'}
L2TP_NET=${VPN_L2TP_NET:-'192.168.42.0/24'}
L2TP_LOCAL=${VPN_L2TP_LOCAL:-'192.168.42.1'}
L2TP_POOL=${VPN_L2TP_POOL:-'192.168.42.10-192.168.42.250'}
XAUTH_NET=${VPN_XAUTH_NET:-'192.168.43.0/24'}
XAUTH_POOL=${VPN_XAUTH_POOL:-'192.168.43.10-192.168.43.250'}
DNS_SRV1=${VPN_DNS_SRV1:-'8.8.8.8'}
DNS_SRV2=${VPN_DNS_SRV2:-'8.8.4.4'}
DNS_SRVS="\"$DNS_SRV1 $DNS_SRV2\""
[ -n "$VPN_DNS_SRV1" ] && [ -z "$VPN_DNS_SRV2" ] && DNS_SRVS="$DNS_SRV1"


bigecho "Checking credentials"

[ -n "$YOUR_IPSEC_PSK" ] && VPN_IPSEC_PSK="$YOUR_IPSEC_PSK"

if [ "x$RADIUS" != "xyes" ]
then
   [ -n "$YOUR_IPSEC_PSK" ] && VPN_IPSEC_PSK="$YOUR_IPSEC_PSK"
   [ -n "$YOUR_USERNAME"  ] && VPN_USER="$YOUR_USERNAME"
   [ -n "$YOUR_PASSWORD"  ] && VPN_PASSWORD="$YOUR_PASSWORD"

   if [ -z "$VPN_IPSEC_PSK" ] && [ -z "$VPN_USER" ] && [ -z "$VPN_PASSWORD" ]
   then
       bigecho "VPN credentials not set by user. Generating random PSK and password..."
       VPN_IPSEC_PSK=$(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 20)
       VPN_USER=vpnuser
       VPN_PASSWORD=$(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 16)
   fi

   if [ -z "$VPN_IPSEC_PSK" ] || [ -z "$VPN_USER" ] || [ -z "$VPN_PASSWORD" ]
   then
      exiterr "All VPN credentials must be specified. Edit the script and re-enter them."
   fi
else 
if [ -z "$VPN_IPSEC_PSK" ] 
   then
       bigecho "VPN credentials not set by user. Generating random PSK and password..."
       VPN_IPSEC_PSK=$(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 20)      
   fi
fi


bigecho "Creating VPN configuration..."

config-ipsec(){
    bigecho "Configure Ipsec"
    conf_bk "/etc/ipsec.conf"
    sed -e "s|#L2TP_NET#|$L2TP_NET|;s|#XAUTH_NET#|$XAUTH_NET|;s|#PUBLIC_IP#|$PUBLIC_IP|;s|#XAUTH_POOL#|$XAUTH_POOL|;s|#DNS_SRVS#|$DNS_SRVS|" /opt/vpn-conf/libreswan/ipsec.conf.template > /etc/ipsec.conf

    if uname -m | grep -qi '^arm'
    then
      sed -i '/phase2alg/s/,aes256-sha2_512//' /etc/ipsec.conf
    fi

    conf_bk "/etc/ipsec.secrets"
    sed -e "s|#VPN_IPSEC_PSK#|$VPN_IPSEC_PSK|" /opt/vpn-conf/libreswan/ipsec.secrets.template > /etc/ipsec.secrets

    bigecho "IPSEC has been configured"

}

config-l2tp(){
    bigecho "Create xl2tpd config"
    conf_bk "/etc/xl2tpd/xl2tpd.conf"
    sed -e "s|#L2TP_POOL#|$L2TP_POOL|;s|#L2TP_LOCAL#|$L2TP_LOCAL|" /opt/vpn-conf/xl2tpd/xl2tpd.conf.template > /etc/xl2tpd/xl2tpd.conf

    conf_bk "/etc/ppp/options.xl2tpd"
    sed -e "s|#DNS_SRV1#|$DNS_SRV1|;s|#DNS_SRV2#|$DNS_SRV2|;"  /opt/vpn-conf/ppp/options.xl2tpd.template > /etc/ppp/options.xl2tpd

    if [ "x$RADIUS" == "xyes" ]
    then
       echo "plugin radius.so" >> /etc/ppp/options.xl2tpd
       echo "plugin radattr.so" >> /etc/ppp/options.xl2tpd
    else
       # Create VPN credentials
       conf_bk "/etc/ppp/chap-secrets"
       echo  "$VPN_USER l2tpd $VPN_PASSWORD *" > /etc/ppp/chap-secrets

       conf_bk "/etc/ipsec.d/passwd"
       VPN_PASSWORD_ENC=$(openssl passwd -1 "$VPN_PASSWORD")
       echo "$VPN_USER:$VPN_PASSWORD_ENC:xauth-psk"> /etc/ipsec.d/passwd
    fi

    bigecho "l2tp has been configured"

}

config-sysctl(){
    bigecho "Updating sysctl settings..."

    if ! grep -qs "hwdsl2 VPN script" /etc/sysctl.conf; then
      conf_bk "/etc/sysctl.conf"
      if [ "$(getconf LONG_BIT)" = "64" ]; then
        SHM_MAX=68719476736
        SHM_ALL=4294967296
      else
        SHM_MAX=4294967295
        SHM_ALL=268435456
      fi
      sed -e "s|#SHM_MAX#|$SHM_MAX|; s|#SHM_ALL#|$SHM_ALL|" /opt/vpn-conf/sysctl.conf.template >> /etc/sysctl.conf
    fi

    bigecho "Sysctl has been updated"
}


config-iptables(){
    bigecho "Updating IPTables rules..."

    # Check if rules need updating
    ipt_flag=0
    IPT_FILE="/etc/iptables.rules"
    IPT_FILE2="/etc/iptables/rules.v4"
    if ! grep -qs "hwdsl2 VPN script" "$IPT_FILE" \
       || ! iptables -t nat -C POSTROUTING -s "$L2TP_NET" -o "$NET_IFACE" -j MASQUERADE 2>/dev/null \
       || ! iptables -t nat -C POSTROUTING -s "$XAUTH_NET" -o "$NET_IFACE" -m policy --dir out --pol none -j MASQUERADE 2>/dev/null; then
    ipt_flag=1
    fi

    # Add IPTables rules for VPN
    if [ "$ipt_flag" = "1" ]; then
        service fail2ban stop >/dev/null 2>&1
        iptables-save > "$IPT_FILE.old-$SYS_DT"
        iptables -I INPUT 1 -p udp --dport 1701 -m policy --dir in --pol none -j DROP
        iptables -I INPUT 2 -m conntrack --ctstate INVALID -j DROP
        iptables -I INPUT 3 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        iptables -I INPUT 4 -p udp -m multiport --dports 500,4500 -j ACCEPT
        iptables -I INPUT 5 -p udp --dport 1701 -m policy --dir in --pol ipsec -j ACCEPT
        iptables -I INPUT 6 -p udp --dport 1701 -j DROP
        iptables -I FORWARD 1 -m conntrack --ctstate INVALID -j DROP
        iptables -I FORWARD 2 -i "$NET_IFACE" -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        iptables -I FORWARD 3 -i ppp+ -o "$NET_IFACE" -j ACCEPT
        iptables -I FORWARD 4 -i ppp+ -o ppp+ -s "$L2TP_NET" -d "$L2TP_NET" -j ACCEPT
        iptables -I FORWARD 5 -i "$NET_IFACE" -d "$XAUTH_NET" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        iptables -I FORWARD 6 -s "$XAUTH_NET" -o "$NET_IFACE" -j ACCEPT
        # Uncomment if you wish to disallow traffic between VPN clients themselves
        # iptables -I FORWARD 2 -i ppp+ -o ppp+ -s "$L2TP_NET" -d "$L2TP_NET" -j DROP
        # iptables -I FORWARD 3 -s "$XAUTH_NET" -d "$XAUTH_NET" -j DROP
        iptables -A FORWARD -j DROP
        iptables -t nat -I POSTROUTING -s "$XAUTH_NET" -o "$NET_IFACE" -m policy --dir out --pol none -j MASQUERADE
        iptables -t nat -I POSTROUTING -s "$L2TP_NET" -o "$NET_IFACE" -j MASQUERADE
        echo "# Modified by hwdsl2 VPN script" > "$IPT_FILE"
        iptables-save >> "$IPT_FILE"

        if [ -f "$IPT_FILE2" ]; then
          conf_bk "$IPT_FILE2"
          /bin/cp -f "$IPT_FILE" "$IPT_FILE2"
        fi
      fi



  bigecho "Iptables has been configured"
}

config-autoload(){
    bigecho "Enabling services on boot..."

    # Check for iptables-persistent
    IPT_PST="/etc/init.d/iptables-persistent"
    IPT_PST2="/usr/share/netfilter-persistent/plugins.d/15-ip4tables"
    ipt_load=1
    if [ -f "$IPT_FILE2" ] && { [ -f "$IPT_PST" ] || [ -f "$IPT_PST2" ]; }; then
      ipt_load=0
    fi

    if [ "$ipt_load" = "1" ]; then
      mkdir -p /etc/network/if-pre-up.d
      cat /opt/vpn-conf/iptablesload.template > /etc/network/if-pre-up.d/iptablesload
      chmod +x /etc/network/if-pre-up.d/iptablesload

      if [ -f /usr/sbin/netplan ]; then
        mkdir -p /etc/systemd/system
        cat /opt/vpn-conf/load-iptables-rules.service.template > /etc/systemd/system/load-iptables-rules.service
        systemctl enable load-iptables-rules 2>/dev/null
      fi
    fi

    for svc in fail2ban ipsec xl2tpd; do
      update-rc.d "$svc" enable >/dev/null 2>&1
      systemctl enable "$svc" 2>/dev/null
    done

    if ! grep -qs "hwdsl2 VPN script" /etc/rc.local; then
      if [ -f /etc/rc.local ]; then
        conf_bk "/etc/rc.local"
        sed --follow-symlinks -i '/^exit 0/d' /etc/rc.local
      else
        echo '#!/bin/sh' > /etc/rc.local
      fi

      cat /opt/vpn-conf/rc.local.template > /etc/rc.local
    fi

    bigecho "Starting services..."

    # Reload sysctl.conf
    sysctl -e -q -p
    # Update file attributes
    chmod +x /etc/rc.local
    chmod 600 /etc/ipsec.secrets*
    if [ "x$RADIUS" != "xyes" ]
    then
        chmod 600 /etc/ipsec.secrets* /etc/ppp/chap-secrets* /etc/ipsec.d/passwd*
    fi

    # Apply new IPTables rules
    iptables-restore < "$IPT_FILE"

    # Restart services
    mkdir -p /run/pluto
    service fail2ban restart 2>/dev/null
    service ipsec restart 2>/dev/null
    service xl2tpd restart 2>/dev/null
    if [ "x$RADIUS" == "xyes" ]
    then
        service freeradius restart 2>/dev/null
    fi
}

config-freeradius(){
    bigecho "Configuring Rasdius+LDAP"

#    LDAP_URI=''
#    LDAP_PORT=''
#    LDAP_IDENTITY=''
#    LDAP_PASSWORD=''
#    LDAP_BASE_DN=''
#    USER_BASE_DN=''
#    GROUP_BASE_DN=''
#    GROUP_CN=''


    apt-get -yq install freeradius freeradius-ldap

    mkdir -p /etc/radiusclient

    RADIUS_CLIENT_SECRET=$(openssl passwd -1 "$VPN_PASSWORD")
    cp /opt/vpn-conf/freeradius/radiusclient/{dictionary*,port-id-map,radiusclient.conf} /etc/radiusclient
    sed -e "s|#RADIUS_CLIENT_SECRET#|$RADIUS_CLIENT_SECRET|g" /opt/vpn-conf/freeradius/radiusclient/servers.template >/etc/radiusclient/servers

    conf_bk /etc/freeradius/3.0/clients.conf

    sed -e "s|#RADIUS_CLIENT_SECRET#|$RADIUS_CLIENT_SECRET|" /opt/vpn-conf/freeradius/clients.conf.template > /etc/freeradius/3.0/clients.conf

    conf_bk /etc/freeradius/3.0/sites-available/default
    cp /opt/vpn-conf/freeradius/sites-enabled/default /etc/freeradius/3.0/sites-enabled/default

    conf_bk /etc/freeradius/3.0/sites-available/inner-tunnel
    cp /opt/vpn-conf/freeradius/sites-enabled/inner-tunnel /etc/freeradius/3.0/sites-enabled/inner-tunnel

    conf_bk /etc/freeradius/3.0/mods-available/ldap
    sed -e "s|#LDAP_URI#|$LDAP_URI|; s|#LDAP_PORT#|$LDAP_PORT|; s|#LDAP_IDENTITY#|$LDAP_IDENTITY|; s|#LDAP_PASSWORD#|$LDAP_PASSWORD|; s|#LDAP_BASE_DN#|$LDAP_BASE_DN|; s|#USER_BASE_DN#|$USER_BASE_DN|; s|#GROUP_BASE_DN#|$GROUP_BASE_DN|;s|#GROUP_CN#|$GROUP_CN|" /opt/vpn-conf/freeradius/mods-enabled/ldap.template > /etc/freeradius/3.0/mods-available/ldap
    ln -s /etc/freeradius/3.0/mods-available/ldap /etc/freeradius/3.0/mods-enabled/ldap




}

config-ipsec
config-l2tp
config-sysctl
config-iptables

if [ $"x$RADIUS" == "xyes" ]
then
    config-freeradius
fi

config-autoload



exit 0
