[**English**](README.md) | [**Русский**](README-ru.md)

## Client Configuration Files 
**Windows**
Config import script: [**ikev2_config_import**](/client-conf/ikev2_config_import.cmd) (Copyright (C) 2022 Lin Song)
- [**Server 1 p12**](/client-conf/vpnclient1.p12)

**iOS:**
- [**Server1 mobile**](/client-conf/vpnclient1.mobileconfig)
- [**Server2 mobile**](/client-conf/vpnclient2.mobileconfig)
- [**Server3 mobile**](/client-conf/vpnclient3.mobileconfig)

**Android:**
- [**Server1 swan**](/client-conf/vpnclient1.sswan)
- [**Server2 swan**](/client-conf/vpnclient2.sswan)
- [**Server3 swan**](/client-conf/vpnclient3.sswan)

## Installation

* [**Windows 7, 8, 10 and 11**](#windows-7-8-10-and-11)
* [**OS X (macOS)**](#os-x-macos)
* [**iOS (iPhone/iPad)**](#ios-iphoneipad)
* [**Android**](#android)
* [**Linux**](#linux)

### Windows 7, 8, 10 and 11
1. Download the **``vpnclient.p12``** file to your device.
2. Download config import script and put it in the same folder as p12 file.
3. Right-click on the saved script, select Properties. Click on Unblock at the bottom, then click on OK.
4. Right-click on the saved script, select Run as administrator.
5. Choose the VPN client name (or just press Enter, it will choose the file's name)
6. Enter IP of the server, you can find it in the [**here**](#client-configuration-files)
7. Choose the VPN connection name (or just press Enter)
8. Press any key to finish script.
To connect to the VPN: Click on the wireless/network icon in your system tray, select the new VPN entry, and click Connect.

### OS X (macOS)
- In progress 

### iOS (iPhone/iPad)
1. Download the **``vpnclient.mobileconfig``** file to your device.
2. Move the file to the "On my iPhone" folder.
3. Open **``Settings``** and **install** the profile.
4. Go to **``Settings``** > **``VPN``** and connect.

### Android
1. Download [**strongSwan VPN Client**](https://play.google.com/store/apps/details?id=org.strongswan.android) from Google Play.
2. Download **``vpnclient.sswan``** file to your device.
3. Press the button in the top right corner > **``Import VPN profile``** > **``Choose the file``**.
4. Choose the **``VPN certificate``**. 
5. Connect to the **``VPN``**.

### Linux
- In progress 
