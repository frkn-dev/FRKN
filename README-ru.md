[**English**](README.md) | [**Русский**](README-ru.md)

## Файлы конфигурации
**Windows**
Config import script: [**ikev2_config_import**](/client-conf/ikev2_config_import.cmd) (Copyright (C) 2022 Lin Song)
- [**Server 1 p12**](/client-conf/vpnclient1.p12) / Server IP: 89.40.1.114

**iOS:**
- [**Server1 mobile**](/client-conf/vpnclient1.mobileconfig)
- [**Server2 mobile**](/client-conf/vpnclient2.mobileconfig)
- [**Server3 mobile**](/client-conf/vpnclient3.mobileconfig)

**Android:**
- [**Server1 swan**](/client-conf/vpnclient1.sswan)
- [**Server2 swan**](/client-conf/vpnclient2.sswan)
- [**Server3 swan**](/client-conf/vpnclient3.sswan)

## Установка

* [**Windows 7, 8, 10 and 11**](#windows-7-8-10-and-11)
* [**OS X (macOS)**](#os-x-macos)
* [**iOS (iPhone/iPad)**](#ios-iphoneipad)
* [**Android**](#android)
* [**Linux**](#linux)

### Windows 7, 8, 10 and 11
1. Сохраните файл **``vpnclient.p12``** на ваше устройство.
2. Сохраните **``config import script``** и положите в ту же папку, что и p12 файл.
3. Нажмите правой кнопкой мыши на скрипт, выберите **Свойства**. Поставьте галочку **Разблокировать** и нажмите ОК.
4. Нажмите правой кнопкой мыши на скрипт, выберите **Запустить от имени администратора**.
5. Введите имя VPN клиента (или нажмите Enter, скрипт выберет имя файла)
6. Введите IP сервера, вы можете найти его [**тут**](#client-configuration-files)
7. Выберите имя для VPN подключения (или нажмите Enter, установится стандартное имя)
8. Нажмите любую кнопку для завершения скрипта.
Для подключения к VPN: Нажмите на иконку **Сеть** в трее вашей системы правой кнопкой мыши, откройте **Параметры сети и Интернет**, зайдите в VPN и подключайтесь к новому профилю.

### OS X (macOS)
- В работе 

### iOS (iPhone/iPad)
1. Сохраните файл **``vpnclient.mobileconfig``** на ваше устройство.
2. Переместите файл в папку **``iPhone``**.
3. Зайдите в **``настройки``** и **``установите``** профиль.
4. Зайдите в **``Настройки``** > **``VPN``** и подключайтесь. 

### Android
1. Загрузите [**strongSwan VPN Client**](https://play.google.com/store/apps/details?id=org.strongswan.android) из **Google Play**.
2. Сохраните файл **``vpnclient.sswan``** на ваше устройство.
3. Нажмите на кнопку в верхнем-правом углу > **``Import VPN profile``** > **``Выберите файл``**.
4. Выберите **``сертификат VPN``**. 
5. Подключайтесь к **``VPN``**.

### Linux
- В работе 
