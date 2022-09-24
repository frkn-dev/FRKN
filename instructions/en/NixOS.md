### NixOS

**Configuration file:**
[**vpnclient.p12**](https://s.fuckrkn1.xyz/client-conf/0.0.2/vpnclient.p12)

Via NetworkManager:

1. Add support of Strongswan to Networkmanager. For this add the following lines to `/etc/nixos/configuration.nix` (for example, to the section `# List services that you want to enable:`):

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

2. Download **``vpnclient.p12``**.

3. Go to directory of `vpnclient.p12` file (say, `~/Downloads/`), and extract CA certificate, client certificate and private key with the following commands:

```bash
# use nix-shell if openssl not installed
nix-shell -p openssl
# press Enter if a password is requested
openssl pkcs12 -in vpnclient.p12 -cacerts -nokeys -out ikev2vpnca.cer
openssl pkcs12 -in vpnclient.p12 -clcerts -nokeys -out vpnclient.cer
openssl pkcs12 -in vpnclient.p12 -nocerts -nodes  -out vpnclient.key
```

4. Save `ikev2vpnca.cer`, `vpnclient.cer` and `vpnclient.key` files to a proper place (say,
   `~/.config/fuckrkn1/`) and protect them:

```bash
mkdir ~/.config/fuckrkn1
cp ikev2vpnca.cer ~/.config/fuckrkn1/
cp vpnclient.cer ~/.config/fuckrkn1/
cp vpnclient.key ~/.config/fuckrkn1/
cd ~/.config/fuckrkn1/
# recommended
sudo chown root.root ikev2vpnca.cer vpnclient.cer vpnclient.key
sudo chmod 600 ikev2vpnca.cer vpnclient.cer vpnclient.key
```

5. You can then set up and enable the VPN connection in the System settings GUI:

- Go to Settings -> Network -> VPN. Click the `+` button.
- Select **IPsec/IKEv2 (strongswan)**.
- Enter anything you like in the **Name** field.
- In the **Server/Address** section, enter domain name **``lt.fuckrkn1.xyz``**.
- Select the `ikev2vpnca.cer` file for the **Certificate**.
- For the **Client/Authentication**, select **Certificate** in the drop-down menu.
- For the **Client/Certificate**, select **Certificate/private key**.
- Select the `vpnclient.cer` file for the **Certificate file**.
- Select the `vpnclient.key` file for the **Private key**.
- In the **Options** section, check the **Request an inner IP address** checkbox.
- In the **Algorithms** section (click on it!), check the **Enable custom algorithm proposals** checkbox.
- Leave the **IKE** field blank.
- Enter `aes128gcm16` in the **ESP** field.
- Click **Add** to save the VPN connection information.
- Turn the **VPN** switch ON.

