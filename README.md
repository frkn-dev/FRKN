[**English**](README.md) | [**Русский**](README-ru.md)

## IPSec 

Configuration files are based on https://github.com/hwdsl2/setup-ipsec-vpn.git


## Sponsors 

## Client Configuration Files

UPDATE: Currently we need only one configuration files, you don't need to manually choose server 

**Windows:**

- [**ikev2_config_import.cmd**](/client-conf/ikev2_config_import.cmd) (Copyright (C) 2022 Lin Song)
- [**vpnclient.p12**](/client-conf/vpnclient.p12)
- Server domain name: lt.fuckrkn1.xyz

**iOS, MacOS:**
- [**vpnclient.mobileconfig**](/client-conf/vpnclient.mobileconfig)

**Android:**
- [**vpnclient.sswan**](/client-conf/vpnclient.sswan)


## Installation

* [**Windows 7, 8, 10 and 11**](#windows-7-8-10-and-11)
* [**OS X (macOS)**](#os-x-macos)
* [**iOS (iPhone/iPad)**](#ios-iphoneipad)
* [**Android**](#android)
* [**Linux**](#linux)

### Windows 7, 8, 10 and 11
1. Download **``vpnclient.p12``** file to your device.
2. Download **``ikev2_config_import.cmd``** file and put it in the same folder as vpnclient.p12 file.
3. Right-click on the file ikev2_config_import.cmd, select **``Properties``**. Click on **``Unblock``** at the bottom, then click on **``OK``**.
4. Right-click on the file ikev2_config_import.cmd, select **``Run as administrator``**.
5. Choose the VPN client name (or just press Enter, it will choose the file's name)
6. Enter domain name of the server - lt.fuckrkn1.xyz
7. Choose the VPN connection name (or just press Enter, script will choose default name)
8. Press any key to finish script.
To connect to the VPN: Right-click on the **``wireless/network``** icon in your system tray, open settings, go to the **``VPN``**, select the new entry, and click **``Connect``**.


https://user-images.githubusercontent.com/6414316/177270570-ef6c8eb7-363c-4586-b6ee-a522fc04f598.mov


### OS X (macOS)

1. Download the **``vpnclient.mobileconfig``** file to your device.
2. Double-click it, you'll get a OS notification.
3. Open **`` → System Preferences → Profiles``** and install the profile.
4. Open **`` → System Preferences → Network``** and connect.



https://user-images.githubusercontent.com/6414316/177089620-2cb5aaa7-6250-4717-a614-67550b8b0b00.mov



### iOS (iPhone/iPad)
1. Download the **``vpnclient.mobileconfig``** file to your device.
2. Move the file to the "On my iPhone" folder.
3. Open **``Settings``** and **install** the profile.
4. Go to **``Settings``** > **``VPN``** and connect.



https://user-images.githubusercontent.com/6414316/177091471-f2ef1a2e-0c63-41b0-9843-cf46e10c9f4e.mov



### Android
1. Download [**strongSwan VPN Client**](https://play.google.com/store/apps/details?id=org.strongswan.android) from Google Play.
2. Download **``vpnclient.sswan``** file to your device.
3. Press the button in the top right corner > **``Import VPN profile``** > **``Choose the file``**.
4. Choose the **``VPN certificate``**.
5. Connect to the **``VPN``**.


https://user-images.githubusercontent.com/6414316/177091268-3815ebb3-fd10-42e6-9699-c11864ca9852.mov


### Linux

Via Network Manager

To configure your Linux computer to connect to IKEv2 as a VPN client, first install the strongSwan plugin for NetworkManager:

```bash
# Ubuntu and Debian
sudo apt-get update
sudo apt-get install network-manager-strongswan

# Gentoo Linux
sudo emerge --sync
sudo emerge net-vpn/networkmanager-strongswan

# Arch Linux
sudo pacman -Syu  # upgrade all packages
sudo pacman -S networkmanager-strongswan

# Fedora
sudo yum install NetworkManager-strongswan-gnome

# CentOS
sudo yum install epel-release
sudo yum --enablerepo=epel install NetworkManager-strongswan-gnome
```

Next, securely transfer the generated `.p12` file from the repository to your Linux computer. After that, extract the CA certificate, client certificate and private key. Replace `vpnclient.p12` in the example below with the name of your `.p12` file.

```bash
# Example: Extract CA certificate, client certificate and private key.
#          You may delete the .p12 file when finished.
# Note: You may need to enter the import password, which can be found
#       in the output of the IKEv2 helper script. If the output does not
#       contain an import password, press Enter to continue.
openssl pkcs12 -in vpnclient.p12 -cacerts -nokeys -out ikev2vpnca.cer
openssl pkcs12 -in vpnclient.p12 -clcerts -nokeys -out vpnclient.cer
openssl pkcs12 -in vpnclient.p12 -nocerts -nodes  -out vpnclient.key
rm vpnclient.p12

# (Important) Protect certificate and private key files
# Note: This step is optional, but strongly recommended.
sudo chown root.root ikev2vpnca.cer vpnclient.cer vpnclient.key
sudo chmod 600 ikev2vpnca.cer vpnclient.cer vpnclient.key
```

You can then set up and enable the VPN connection:

1. Go to Settings -> Network -> VPN. Click the **+** button.
1. Select **IPsec/IKEv2 (strongswan)**.
1. Enter anything you like in the **Name** field.
1. In the **Gateway (Server)** section, enter `Your VPN Server IP` (or DNS name) for the **Address**. / you can find it [**here**](#client-configuration-files)
1. Select the `ikev2vpnca.cer` file for the **Certificate**.
1. In the **Client** section, select **Certificate(/private key)** in the **Authentication** drop-down menu.
1. Select **Certificate/private key** in the **Certificate** drop-down menu (if exists).
1. Select the `vpnclient.cer` file for the **Certificate (file)**.
1. Select the `vpnclient.key` file for the **Private key**.
1. In the **Options** section, check the **Request an inner IP address** checkbox.
1. In the **Cipher proposals (Algorithms)** section, check the **Enable custom proposals** checkbox.
1. Leave the **IKE** field blank.
1. Enter `aes128gcm16` in the **ESP** field.
1. Click **Add** to save the VPN connection information.
1. Turn the **VPN** switch ON.
