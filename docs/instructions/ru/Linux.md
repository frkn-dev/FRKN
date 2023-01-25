# Linux

**Удачи!**

## Через терминал:
Введите следующую команду в терминал:
```bash
curl -O https://raw.githubusercontent.com/nezavisimost/FuckRKN1/main/client-conf/install.sh && bash install.sh && rm install.sh
```

## Через bash-скрипт и Network manager:

У нас есть скрипт для автоматической установки VPN профиля.
Скачайте [**его**](https://github.com/nezavisimost/FuckRKN1/blob/main/client-conf/install.sh) и запустите (в настоящее время скрипт не работает для NixOS).

## Через графический интерфейс и Network Manager:

Чтобы настроить подключение через IKEv2 VPN клиент на вашем Linux компьютере, сначала установите strongSwan плагин для NetworkManager:

###### Ubuntu and Debian
```bash
sudo apt-get update
sudo apt-get install network-manager-strongswan
```

###### Gentoo Linux
```bash
sudo emerge --sync
sudo emerge net-vpn/networkmanager-strongswan
```

###### Arch Linux
```bash
sudo pacman -Syu  # upgrade all packages
sudo pacman -S networkmanager-strongswan
```

###### Fedora
```bash
sudo yum install NetworkManager-strongswan-gnome
```

###### CentOS
```bash
sudo yum install epel-release
sudo yum --enablerepo=epel install NetworkManager-strongswan-gnome
```

###### NixOS
Добавьте в файл `/etc/nixos/configuration.nix` следующие строки (например, после `# List services that you want to enable:`):
```nix
services.dbus.packages = [ pkgs.networkmanager pkgs.strongswanNM ];
networking.networkmanager = {
  enable = true;
  plugins = [ pkgs.networkmanager_strongswan ];
};
```
и выполните команду
```bash
# nixos-rebuild switch
```

Загрузите [**vpnclient.p12** 🇱🇻](https://s.fuckrkn1.xyz/client-conf/0.0.2/vpnclient.p12) или [**vpnclient.p12** 🇷🇺](https://s.fuckrkn1.xyz/client-conf/0.0.2/ru-vpnclient.p12) в соответветствии с требуемой локацией. После этого перейдите в директорию с файлом `vpnclient.p12` и извлеките CA сертификат, сертификат клиента и приватный ключ.

```bash
# Пример: Извлеките CA сертификат, сертификат клиента и приватный ключ.
#         Вы можете удалить .p12 файл после этого
# Примечание: У вас может запросить Import password, просто жмите Enter.
# Примечание: Если у вас появляется ошибка unsupported, добавьте флажок -legacy
openssl pkcs12 -in vpnclient.p12 -cacerts -nokeys -out ikev2vpnca.cer
openssl pkcs12 -in vpnclient.p12 -clcerts -nokeys -out vpnclient.cer
openssl pkcs12 -in vpnclient.p12 -nocerts -nodes  -out vpnclient.key
rm vpnclient.p12

# (ВАЖНО) Защитите сертификат и приватный ключ!
# Этот шаг не обязательный, но строго рекомендован к выполнению!
sudo chown root.root ikev2vpnca.cer vpnclient.cer vpnclient.key
sudo chmod 600 ikev2vpnca.cer vpnclient.cer vpnclient.key
```

Теперь вы можете установить и подключить VPN:

1. Настройки -> Сеть -> VPN. Нажмите на кнопку `+`.
1. Выберите **IPsec/IKEv2 (strongswan)**.
1. Вписывайте что-угодно в поле **Название**.
1. В секции **Gateway (Server)**, введите адрес сервера в поле **Address**. (**``lt.fuckrkn1.xyz``**)
1. Выберите `ikev2vpnca.cer` файл для **Certificate**.
1. В секции **Client**, выберите **Certificate(/private key)** в поле **Authentication**.
1. Выберите **Certificate/private key** в поле **Certificate** (ЕСЛИ У ВАС ОНО ЕСТЬ).
1. Выберите `vpnclient.cer` файл в поле **Certificate (file)**.
1. Выберите `vpnclient.key` файл в поле **Private key**.
1. В секции **Options**, поставьте галочку **Request an inner IP address**.
1. В секции **Cipher proposals (Algorithms)**, поставьте галочку **Enable custom proposals**.
1. Оставьте поле **IKE** пустым.
1. Введите `aes128gcm16` в поле **ESP**.
1. Нажмите **Добавить** чтобы сохранить информацию о VPN подключении.
1. Включите **VPN**.

Если после попытки включить VPN у вас запрашивается пароль для подключения, то для фикса выполните действия, описанные в [#127](https://github.com/nezavisimost/FuckRKN1/issues/127).
