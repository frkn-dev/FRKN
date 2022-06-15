#!/bin/bash
#
#  Install packages for VPN service and pre-configuration


export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

exiterr()  { echo "Error: $1" >&2; exit 1; }
exiterr2() { exiterr "' apt-get install' failed."; }
bigecho() { echo; echo "## $1"; echo; }

install() {
    
  bigecho "VPN setup in progress... "
  
  # Pre-Install Checks
  os_type=$(lsb_release -si 2>/dev/null)
  if [ -z "$os_type" ]; then
    [ -f /etc/os-release  ] && os_type=$(. /etc/os-release  && printf '%s' "$ID")
    [ -f /etc/lsb-release ] && os_type=$(. /etc/lsb-release && printf '%s' "$DISTRIB_ID")
  fi
  if ! printf '%s' "$os_type" | head -n 1 | grep -qiF -e ubuntu -e debian -e raspbian; then
    exiterr "This script only supports Ubuntu and Debian."
  fi
  
  if [ "$(sed 's/\..*//' /etc/debian_version)" = "7" ]; then
    exiterr "Debian 7 is not supported."
  fi
  
  if [ -f /proc/user_beancounters ]; then
    exiterr "OpenVZ VPS is not supported."
  fi
  

  # Create and change to working dir
  mkdir -p /opt/src
  cd /opt/src || exit 1
  
  count=0
  APT_LK=/var/lib/apt/lists/lock
  PKG_LK=/var/lib/dpkg/lock
  while fuser "$APT_LK" "$PKG_LK" >/dev/null 2>&1 \
    || lsof "$APT_LK" >/dev/null 2>&1 || lsof "$PKG_LK" >/dev/null 2>&1; do
    [ "$count" = "0" ] && bigecho "Waiting for apt to be available..."
    [ "$count" -ge "60" ] && exiterr "Could not get apt/dpkg lock."
    count=$((count+1))
    printf '%s' '.'
    sleep 3
  done
  
  bigecho "Populating apt-get cache..."
  
  export DEBIAN_FRONTEND=noninteractive
   apt-get -yq update || exiterr "'apt-get update' failed."
  
  bigecho "Installing packages required for setup..."
  apt-get -yq install wget dnsutils openssl \
    iptables iproute2 gawk grep sed net-tools || exiterr2
  

  bigecho "Installing packages required for the VPN..."
  
  apt-get -yq install libnss3-dev libnspr4-dev pkg-config \
    libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev \
    libcurl4-nss-dev flex bison gcc make libnss3-tools \
    libevent-dev ppp xl2tpd || exiterr2

  bigecho "Installing packages required for the FreeRadius..."    
   apt-get -yq install freeradius freeradius-ldap
  
  case "$(uname -r)" in
    4.1[456]*)
      if ! printf '%s' "$os_type" | head -n 1 | grep -qiF ubuntu; then
        L2TP_VER=1.3.12
        l2tp_dir="xl2tpd-$L2TP_VER"
        l2tp_file="$l2tp_dir.tar.gz"
        l2tp_url="https://github.com/xelerance/xl2tpd/archive/v$L2TP_VER.tar.gz"
         apt-get -yq install libpcap0.8-dev || exiterr2
        wget -t 3 -T 30 -nv -O "$l2tp_file" "$l2tp_url" || exit 1
         /bin/rm -rf "/opt/src/$l2tp_dir"
         tar xzf "$l2tp_file" &&  /bin/rm -f "$l2tp_file"
        cd "$l2tp_dir" && make -s 2>/dev/null && PREFIX=/usr  make -s install
        cd /opt/src || exit 1
         /bin/rm -rf "/opt/src/$l2tp_dir"
      fi
      ;;
  esac
  
  bigecho "Installing Fail2Ban to protect SSH..."
  
  apt-get -yq install fail2ban || exiterr2
  
  bigecho "Compiling and installing Libreswan..."
  
  SWAN_VER=3.27
  swan_file="libreswan-$SWAN_VER.tar.gz"
  swan_url1="https://github.com/libreswan/libreswan/archive/v$SWAN_VER.tar.gz"
  swan_url2="https://download.libreswan.org/$swan_file"
  if ! { wget -t 3 -T 30 -nv -O "$swan_file" "$swan_url1" || wget -t 3 -T 30 -nv -O "$swan_file" "$swan_url2"; }; then
    exit 1
  fi
  /bin/rm -rf "/opt/src/libreswan-$SWAN_VER"
  tar xzf "$swan_file" &&  /bin/rm -f "$swan_file"
  chmod -R 744 /opt/src/
  cd "libreswan-$SWAN_VER" || exit 1
  cat > Makefile.inc.local <<'EOF'
WERROR_CFLAGS =
USE_DNSSEC = false
USE_DH31 = false
USE_GLIBC_KERN_FLIP_HEADERS = true  
EOF

  if [ "$(packaging/utils/lswan_detect.sh init)" = "systemd" ]; then
     apt-get -yq install libsystemd-dev || exiterr2
  fi
  NPROCS=$(grep -c ^processor /proc/cpuinfo)
  [ -z "$NPROCS" ] && NPROCS=1
  make "-j$((NPROCS+1))" -s base &&  make -s install-base
  
  cd /opt/src || exit 1
   /bin/rm -rf "/opt/src/libreswan-$SWAN_VER"
  if ! /usr/local/sbin/ipsec --version 2>/dev/null | grep -qF "$SWAN_VER"; then
    exiterr "Libreswan $SWAN_VER failed to build."
  fi
}


install

bigecho "AMI for VPN service has been prepared" 
exit 0
 