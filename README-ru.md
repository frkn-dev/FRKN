[**English**](README.md) | [**Русский**](README-ru.md)

## Файлы конфигурации

UPD: В данный момент больше нет необходимости выбирать сервер вручную.

**Windows:**

Config import script: [**ikev2_config_import**](/client-conf/ikev2_config_import.cmd) (Copyright (C) 2022 Lin Song)
- [**p12**](/client-conf/vpnclient.p12) / Сервер: lt.fuckrkn1.xyz

**iOS:**
- [**mobile**](/client-conf/vpnclient.mobileconfig)

**Android:**
- [**Sswan**](/client-conf/vpnclient.sswan)


## Установка

* [**Windows 7, 8, 10 and 11**](#windows-7-8-10-and-11)
* [**OS X (macOS)**](#os-x-macos)
* [**iOS (iPhone/iPad)**](#ios-iphoneipad)
* [**Android**](#android)
* [**Linux**](#linux)

### Windows 7, 8, 10 and 11
1. Сохраните файл **``vpnclient.p12``** на ваше устройство.
2. Сохраните **``config import script``** и положите в ту же папку, что и p12 файл.
3. Нажмите правой кнопкой мыши на скрипт, выберите **``Свойства``**. Поставьте галочку **``Разблокировать``** и нажмите ОК.
4. Нажмите правой кнопкой мыши на скрипт, выберите **``Запустить от имени администратора``**.
5. Введите имя VPN клиента (или нажмите Enter, скрипт выберет имя файла)
6. Введите IP сервера, вы можете найти его [**тут**](#файлы-конфигурации)
7. Выберите имя для VPN подключения (или нажмите Enter, установится стандартное имя)
8. Нажмите любую кнопку для завершения скрипта.
Для подключения к VPN: Нажмите на иконку **``Сеть``** в трее вашей системы правой кнопкой мыши, откройте **``Параметры сети и Интернет``**, зайдите в **``VPN``** и подключайтесь к новому профилю.

### OS X (macOS)
1. Сохраните файл **``vpnclient.mobileconfig``**.
2. Откройте его двойным щелчком, появится уведомление.
3. Откройте **`` → System Preferences → Profiles``** и **``установите``** профиль.
4. Откройте **`` → System Preferences → Network``** и подключайтесь.


https://user-images.githubusercontent.com/6414316/177089620-2cb5aaa7-6250-4717-a614-67550b8b0b00.mov


### iOS (iPhone/iPad)
1. Сохраните файл **``vpnclient.mobileconfig``** на ваше устройство.
2. Переместите файл в папку **``iPhone``**.
3. Зайдите в **``настройки``** и **``установите``** профиль.
4. Зайдите в **``Настройки``** > **``VPN``** и подключайтесь.


https://user-images.githubusercontent.com/6414316/177091471-f2ef1a2e-0c63-41b0-9843-cf46e10c9f4e.mov


### Android
1. Загрузите [**strongSwan VPN Client**](https://play.google.com/store/apps/details?id=org.strongswan.android) из **Google Play**.
2. Сохраните файл **``vpnclient.sswan``** на ваше устройство.
3. Нажмите на кнопку в верхнем-правом углу > **``Import VPN profile``** > **``Выберите файл``**.
4. Выберите **``сертификат VPN``**.
5. Подключайтесь к **``VPN``**.


https://user-images.githubusercontent.com/6414316/177091268-3815ebb3-fd10-42e6-9699-c11864ca9852.mov



### Linux

Через Network Manager:

Чтобы настроить подключение через IKEv2 VPN клиент на вашем Linux компьютере, сначала установите strongSwan плагин для NetworkManager:

```bash
# Ubuntu и Debian
sudo apt-get update
sudo apt-get install network-manager-strongswan

# Arch Linux
sudo pacman -Syu  # upgrade all packages
sudo pacman -S networkmanager-strongswan

# Fedora
sudo yum install NetworkManager-strongswan-gnome

# CentOS
sudo yum install epel-release
sudo yum --enablerepo=epel install NetworkManager-strongswan-gnome
```

Далее сохраните `.p12` файл из репозитория на ваш Linux компьютер. После этого, извлеките CA сертификат, сертификат клиента и приватный ключ. Замените `vpnclient.p12` в примере ниже на имя вашего `.p12` файла (если вы его не переименовывали, то имя заменять не придется).

```bash
# Пример: Извлеките CA сертификат, сертификат клиента и приватный ключ.
#         Вы можете удалить .p12 файл после этого
# Примечание: У вас может запросить Import password, просто жмите Enter.
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
1. В секции **Gateway (Server)**, введите адрес сервера в поле **Address**. / Можете найти адрес  [**тут**](#файлы-конфигурации)
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

