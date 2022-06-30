[**English**](README.md) | [**Русский**](README-ru.md)

## IPSec 

Configuration files are based on https://github.com/hwdsl2/setup-ipsec-vpn.git


## Sponsors 

## Client Configuration Files

UPDATE: Currently we need only one configuration files, you don't need to manually choose server 

**Windows:**

Config import script: [**ikev2_config_import**](/client-conf/ikev2_config_import.cmd) (Copyright (C) 2022 Lin Song)
- [**p12**](/client-conf/vpnclient.p12) / Server: lt.fuckrkn1.xyz

**iOS:**
- [**mobile**](/client-conf/vpnclient.mobileconfig)

**Android:**
- [**swan**](/client-conf/vpnclient.sswan)


## Installation

* [**Windows 7, 8, 10 and 11**](#windows-7-8-10-and-11)
* [**OS X (macOS)**](#os-x-macos)
* [**iOS (iPhone/iPad)**](#ios-iphoneipad)
* [**Android**](#android)
* [**Linux**](#linux)

### Windows 7, 8, 10 and 11
1. Download the **``vpnclient.p12``** file to your device.
2. Download **``config import script``** and put it in the same folder as p12 file.
3. Right-click on the saved script, select **``Properties``**. Click on **``Unblock``** at the bottom, then click on **``OK``**.
4. Right-click on the saved script, select **``Run as administrator``**.
5. Choose the VPN client name (or just press Enter, it will choose the file's name)
6. Enter IP of the server, you can find it in the [**here**](#client-configuration-files)
7. Choose the VPN connection name (or just press Enter, script will choose default name)
8. Press any key to finish script.
To connect to the VPN: Right-click on the **``wireless/network``** icon in your system tray, open settings, go to the **``VPN``**, select the new entry, and click **``Connect``**.

### OS X (macOS)
1. Download the **``vpnclient.mobileconfig``** file to your device.
2. Double-click it, you'll get a OS notification.
3. Open **`` → System Preferences → Profiles``** and install the profile.
4. Open **`` → System Preferences → Network``** and connect.

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
