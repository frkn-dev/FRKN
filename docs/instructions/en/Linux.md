# Linux

**Good luck with it!**

## Via the bash-script and network manager

We have a script for auto-installation of VPN profile. 
Download [**the script**](https://github.com/nezavisimost/FuckRKN1/blob/main/client-conf/install.sh) and run it (script doesn't work for NixOS yet)

## Via the UI and network manager

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
sudo dnf install NetworkManager-strongswan
```

###### CentOS
```bash
sudo yum install epel-release
sudo yum --enablerepo=epel install NetworkManager-strongswan
```

###### NixOS
Add the following lines to `/etc/nixos/configuration.nix` (for example, to the section `# List services that you want to enable:`):
```nix
services.dbus.packages = [ pkgs.networkmanager pkgs.strongswanNM ];
networking.networkmanager = {
  enable = true;
  plugins = [ pkgs.networkmanager_strongswan ];
};
```
and then run
```bash
# nixos-rebuild switch
```

Download [**vpnclient.p12** 🇱🇻](https://s.fuckrkn1.xyz/client-conf/0.0.2/vpnclient.p12) or [**vpnclient.p12** 🇷🇺](https://s.fuckrkn1.xyz/client-conf/0.0.2/ru-vpnclient.p12) according to required location. After that go to directory of `vpnclient.p12` file and extract the CA certificate, client certificate and private key.

```bash
# Example: Extract CA certificate, client certificate and private key.
#          You may delete the .p12 file when finished.
# Note: You may need to enter the import password, which can be found
#       in the output of the IKEv2 helper script. If the output does not
#       contain an import password, press Enter to continue.
# Note: If you have unsupported error, add -legacy flag
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
4. In the **Gateway (Server)** section, enter **`Your VPN Server IP`** (or DNS name) for the **Address**. (**``lt.fuckrkn1.xyz``**)
5. Select the **`ikev2vpnca.cer`** file for the **Certificate**.
6. In the **Client** section, select **Certificate(/private key)** in the **Authentication** drop-down menu.
7. Select **Certificate/private key** in the **Certificate** drop-down menu (if exists).
8. Select the **`vpnclient.cer`** file for the **Certificate (file)**.
9. Select the **`vpnclient.key`** file for the **Private key**.
10. In the **Options** section, check the **Request an inner IP address** checkbox.
11. In the **Cipher proposals (Algorithms)** section, check the **Enable custom proposals** checkbox.
12. Leave the **IKE** field blank.
13. Enter **`aes128gcm16`** in the **ESP** field.
14. Click **Add** to save the VPN connection information.
15. Turn the **VPN** switch ON.
