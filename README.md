<p align="center">
  <img src="./media/logofckrkn.jpg" width="350" title="FuckRKN1">
</p>

[**English**](README.md) | [**Русский**](README-ru.md)

# [FuckRKN1](https://fuckrkn1.org/index-en.html): Free VPN for free humans

**We** are for freedom of speech and against any kind of censorship.

**We** are making a non-commercial VPN-service that does not collect any data.

Today, freedom of speech is especially vulnerable. Independent media are banned, people are brainwashed with propaganda, VPN services are blocked, and it is dangerous to express one's position and opinion. This is the reason why we took on this project. It is non-commercial, no profit is pursued either. We are rather small, but yet, we have a great potential.

You can support us with donations or any other contribution to improve the service. Pulling requests and creating issues also helps us a lot.

## Sponsors 
Be the first! ;)

# IPSec 

Configuration files are based on this [**reporsitory**](https://github.com/hwdsl2/setup-ipsec-vpn.git)

## Installation

* [**Windows 7, 8, 10 and 11**](#windows-7-8-10-and-11)
* [**OS X (macOS)**](#os-x-macos)
* [**iOS (iPhone/iPad)**](#ios-iphoneipad)
* [**Android**](#android)
* [**Linux**](#linux)
* [**Oculus**](#oculus-vr)

### Windows 7, 8, 10 and 11

**Configuration files:**

- [**ikev2_config_import.cmd**](/client-conf/ikev2_config_import.cmd) (Copyright (C) 2022 Lin Song)
- [**vpnclient.p12**](/client-conf/vpnclient.p12)

**NOTE: Server domain name: ``lt.fuckrkn1.xyz``**

1. Download **``vpnclient.p12``** file to your device.
2. Download **``ikev2_config_import.cmd``** file and put it in the same folder as vpnclient.p12 file.
3. Right-click on the file ikev2_config_import.cmd, select **``Properties``**. Click on **``Unblock``** at the bottom, then click on **``OK``**.
4. Right-click on the file ikev2_config_import.cmd, select **``Run as administrator``**.
5. Choose the VPN client name (or just press Enter, it will choose the file's name)
6. Enter domain name of the server - **``lt.fuckrkn1.xyz``**
7. Choose the VPN connection name (or just press Enter, script will choose default name)
8. Press any key to finish script.
To connect to the VPN: Right-click on the **``wireless/network``** icon in your system tray, open settings, go to the **``VPN``**, select the new entry, and click **``Connect``**.


https://user-images.githubusercontent.com/6414316/177270570-ef6c8eb7-363c-4586-b6ee-a522fc04f598.mov


### OS X (macOS)

**Configuration file:**
[**vpnclient.mobileconfig**](/client-conf/vpnclient.mobileconfig)


1. Download the **``vpnclient.mobileconfig``** file to your device.
2. Double-click it, you'll get a OS notification.
3. Open **`` → System Preferences → Profiles``** and install the profile.
4. Open **`` → System Preferences → Network``** and connect.



https://user-images.githubusercontent.com/6414316/177089620-2cb5aaa7-6250-4717-a614-67550b8b0b00.mov


### iOS (iPhone/iPad)

**Configuration file:**
[**vpnclient.mobileconfig**](/client-conf/vpnclient.mobileconfig)

1. Download the **``vpnclient.mobileconfig``** file to your device.
2. Move the file to the ``On my iPhone" folder``.
3. Open **``Settings``** and **install** the profile.
4. Go to **``Settings``** > **``VPN``** and connect.



https://user-images.githubusercontent.com/6414316/177091471-f2ef1a2e-0c63-41b0-9843-cf46e10c9f4e.mov



### Android

**Configuration file:**
[**vpnclient.sswan**](/client-conf/vpnclient.sswan)

1. Download [**strongSwan VPN Client**](https://play.google.com/store/apps/details?id=org.strongswan.android) from Google Play.
2. Download **``vpnclient.sswan``** file to your device.
3. Press the button in the top right corner > **``Import VPN profile``** > **``Choose the file``**.
4. Choose the **``VPN certificate``**.
5. Connect to the **``VPN``**.


https://user-images.githubusercontent.com/6414316/177091268-3815ebb3-fd10-42e6-9699-c11864ca9852.mov


### Linux

**Good luck with it!**

Via Network Manager

To configure your Linux computer to connect to IKEv2 as a VPN client, first install the strongSwan plugin for NetworkManager:

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
2. Select **IPsec/IKEv2 (strongswan)**.
3. Enter anything you like in the **Name** field.
4. In the **Gateway (Server)** section, enter `Your VPN Server IP` (or DNS name) for the **Address**. / you can find it [**here**](#client-configuration-files)
5. Select the `ikev2vpnca.cer` file for the **Certificate**.
6. In the **Client** section, select **Certificate(/private key)** in the **Authentication** drop-down menu.
7. Select **Certificate/private key** in the **Certificate** drop-down menu (if exists).
8. Select the `vpnclient.cer` file for the **Certificate (file)**.
9. Select the `vpnclient.key` file for the **Private key**.
10. In the **Options** section, check the **Request an inner IP address** checkbox.
11. In the **Cipher proposals (Algorithms)** section, check the **Enable custom proposals** checkbox.
12. Leave the **IKE** field blank.
13. Enter `aes128gcm16` in the **ESP** field.
14. Click **Add** to save the VPN connection information.
15. Turn the **VPN** switch ON.

### Oculus VR

1. In order to install applications, you need to activate developer mode on oq2 (see activation guide
   [**here**](https://developer.oculus.com/documentation/native/android/mobile-device-setup/)). After this step you can install third-party applications (i.e. sideloading). Then you need to transfer
   `vpnclient.sswan` to your device (the process of installation is the same as on Android). This can be done via internal
   browser or by using `adb`. Download the file to your PC, then push it to the device:
   `adb push vpnclient.sswan /sdcard/`

3. The next step is strong swan installation. Download `apk`
   from [**here**](https://download.strongswan.org/Android/) and install it with the
   next command: `adb install -g -r strongSwan-2.3.3.apk`

Unfortunately, the built-in file manager is quite truncated, so when you click on `import vpn profile` nothing will
happen (that’s why strong swan is installed via `adb`). Therefore, a couple of additional steps need to be taken.

4. Download any decent file manager (I personally use
   [**Mixplorer**](https://4pda.to/forum/index.php?showtopic=318294)) and
   install it with the command:
   `adb install -g -r mixplorer.apk`

5. Put on your VR headset and repeat the remaining steps as when installing on android (see [**above**](#android)). Now when you click
   on `import VPN profile` Mixplorer will be used to navigate and select a file.
