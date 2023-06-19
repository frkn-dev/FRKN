#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

declare -r NORMAL_COLOR="\e[0;39m"  # Сброс цвета
declare -r GREEN_COLOR="\e[0;32m"   # Зеленый цвет
declare -r BLUE_COLOR="\e[1;34m"    # Синий цвет
declare -r YELLOW_COLOR="\e[0;33m"  # Желтый цвет

declare -r DST_DIR=$HOME/.pki/fuckRKN1
declare -r DST_DIR_RU=$HOME/.pki/fuckRKN1_RU
declare -r SRC_URL="https://github.com/nezavisimost/FuckRKN1/raw/main/client-conf/"
declare -r LT_CONFIG="vpnclient.p12"
declare -r RU_CONFIG="ru-vpnclient.p12"
declare -r LT_ADDRESS="lt.fuckrkn1.xyz"
declare -r RU_ADDRESS="ru.fuckrkn1.xyz"
declare -r NM_CONN_ID='FuckRKN1'
declare -r NM_CONN_ID_RU='FuckRKN1_RU'
declare _OPTION
declare -A TYPES

TYPES[Debian]="apt-get update && apt-get install -y network-manager-strongswan"
TYPES[Ubuntu]="apt-get update && apt-get install -y network-manager-strongswan"
TYPES[Arch]="pacman -Syu && pacman -S networkmanager-strongswan"
TYPES[Fedora]="dnf install NetworkManager-strongswan"
TYPES[Gentoo]="emerge --sync && emerge net-vpn/networkmanager-strongswan"
TYPES[CentOS]="yum install epel-release && yum --enablerepo=epel install NetworkManager-strongswan"

main() {
    _draw_menu_root
}

_draw_menu_root() {
    tput civis # Скрываем курсор, чтобы не было видно его мелькания
    tput clear # Очищаем экран для перерисовки
    printf "
    $(echo -e "${GREEN_COLOR}Select OS:${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}1)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Debian${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}2)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Ubuntu${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}3)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Arch${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}4)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Fedora${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}5)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Gentoo${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}6)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}CentOS${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}X)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Exit${NORMAL_COLOR}")

    $(echo -e "${BLUE_COLOR}My OS =>${NORMAL_COLOR}") "
    # Обработчик событий главного меню
    tput rc          # Удаление текущей позиции курсора
    tput cup 10 13   # Переместить курсор
    tput cnorm       # Отобразить курсор
    read _OPTION     # Ждем ввод пользователя
    case "${_OPTION}" in
        [1]) _draw_second_menu "Debian" ;;
        [2]) _draw_second_menu "Ubuntu" ;;
        [3]) _draw_second_menu "Arch" ;;
        [4]) _draw_second_menu "Fedora" ;;
        [5]) _draw_second_menu "Gentoo" ;;
        [6]) _draw_second_menu "CentOS" ;;
        [Xx]) tput clear; exit 0 ;;
           *)
                echo -e "\n${YELLOW_COLOR}    Invalid Option: ${_OPTION}\c${NORMAL_COLOR}"
                sleep 1 # Задержка для отображения сообщения об ошибке
            ;;
    esac
    unset _OPTION
}

_draw_second_menu() {
    tput clear
    printf "
    $(echo -e "${GREEN_COLOR}Select VPN country:${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}1)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Latvia${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}2)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Russia${NORMAL_COLOR}")
        $(echo -e "${BLUE_COLOR}X)${NORMAL_COLOR}") $(echo -e "${YELLOW_COLOR}Exit${NORMAL_COLOR}")

    $(echo -e "${BLUE_COLOR}Country =>${NORMAL_COLOR}") "
    tput rc
    tput cup 6 15
    tput cnorm
    read _OPTION
    case "${_OPTION}" in
        [1]) _install $1 $NM_CONN_ID $LT_CONFIG $LT_ADDRESS $DST_DIR ;;
        [2]) _install $1 $NM_CONN_ID_RU $RU_CONFIG $RU_ADDRESS $DST_DIR_RU ;;
        [Xx]) tput clear; exit 0 ;;
           *)
                echo -e "\n${YELLOW_COLOR}    Invalid Option: ${_OPTION}\c${NORMAL_COLOR}"
                sleep 1
            ;;
    esac
    unset _OPTION
}

_install() {
    tput clear
    tput cup 0 0
    printf "
    $(echo -e "${GREEN_COLOR}Install...${NORMAL_COLOR}")
    "

    local type="$1"
    local conn_id="$2"
    local config="$3"
    local address="$4"
    local dist="$5"
    local url="$SRC_URL/$config"
    local conf_path="/tmp/$config"
    local ca_cert="$dist/ca.cer"
    local client_cert="$dist/client.cer"
    local client_key="$dist/client.key"

    eval "${TYPES[$type]}"
    wget $url -P /tmp

    if [ $? != 0 ]; then
      echo "Failed to download $url"
      exit
    fi

    mkdir -p $dist > /dev/null

    local openssl_has_legacy=$(openssl pkcs12 -help 2>&1 | grep legacy)

    if [ -z "$openssl_has_legacy" ]
    then
      openssl_legacy_opt=''
    else
      openssl_legacy_opt='-legacy'
    fi

    openssl pkcs12 -in $conf_path -cacerts -nokeys -out $ca_cert $openssl_legacy_opt -password "pass:"
    if [ $? != 0 ]; then
        rm $conf_path
        exit
    fi
    openssl pkcs12 -in $conf_path -clcerts -nokeys -out $client_cert $openssl_legacy_opt  -password "pass:"
    if [ $? != 0 ]; then
        rm $conf_path
        exit
    fi
    openssl pkcs12 -in $conf_path -nocerts -nodes  -out $client_key $openssl_legacy_opt  -password "pass:"
    if [ $? != 0 ]; then
        rm $conf_path
        exit
    fi

    rm $conf_path

     chown $USER.$USER $ca_cert $client_cert $client_key
     chmod 600 $ca_cert $client_cert $client_key

    nmcli c delete $conn_id > /dev/null 2>&1

    printf "$(echo -e "${GREEN_COLOR}")"
    nmcli c add type vpn ifname -- vpn-type strongswan connection.id $conn_id connection.autoconnect no vpn.data 'address = '$address', certificate = '$ca_cert', encap = no, esp = aes128gcm16, ipcomp = no, method = key, proposal = yes, usercert = '$client_cert', userkey = '$client_key', virtual = yes'
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"