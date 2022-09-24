### NixOS

**Конфиг:**
[**vpnclient.p12**](https://s.fuckrkn1.xyz/client-conf/0.0.2/vpnclient.p12)

Через NetworkManager:

1. Добавьте поддержку Strongswan в Networkmanager. Для этого добавьте следующие строчки в файл `/etc/nixos/configuration.nix` (например, после `# List services that you want to enable:`):

```nix
services.dbus.packages = [ pkgs.networkmanager pkgs.strongswanNM ];
networking.networkmanager = {
  enable = true;
  plugins = [ pkgs.networkmanager_strongswan ];
};
```

затем выполните

```bash
# nixos-rebuild switch
```

2. Загрузите **``vpnclient.p12``**.

3. Перейдите в директорию, в которой находится файл `vpnclient.p12` (например, `~/Downloads/`), и получите CA сертификат, клиентский сертификат и закрытый ключ с помощью команд:

```bash
# используйте nix-shell если openssl не установлен
nix-shell -p openssl
# press Enter if a password is requested
openssl pkcs12 -in vpnclient.p12 -cacerts -nokeys -out ikev2vpnca.cer
openssl pkcs12 -in vpnclient.p12 -clcerts -nokeys -out vpnclient.cer
openssl pkcs12 -in vpnclient.p12 -nocerts -nodes  -out vpnclient.key
```

4. Сохраните файлы `ikev2vpnca.cer`, `vpnclient.cer` и `vpnclient.key` в подходящее место
   (например, в `~/.config/fuckrkn1/`) и защитите их:

```bash
mkdir ~/.config/fuckrkn1
cp ikev2vpnca.cer ~/.config/fuckrkn1/
cp vpnclient.cer ~/.config/fuckrkn1/
cp vpnclient.key ~/.config/fuckrkn1/
cd ~/.config/fuckrkn1/
# рекомендуется
sudo chown root.root ikev2vpnca.cer vpnclient.cer vpnclient.key
sudo chmod 600 ikev2vpnca.cer vpnclient.cer vpnclient.key
```

5. Теперь можно настроить и включить VPN через графическую оболочку системы:

- Перейдите в Настройки -> Сеть -> VPN. Нажмите на кнопку `+`.
- Выберите **IPsec/IKEv2 (strongswan)**.
- Вписывайте что-угодно в поле **Название**.
- In the **Server/Address** section, enter domain name **``lt.fuckrkn1.xyz``**.
- В секции **Server/Address** введите адрес **``lt.fuckrkn1.xyz``**.
- Выберите `ikev2vpnca.cer` файл для **Certificate**.
- В поле **Client/Authentication** выберете **Certificate** в выпадающем меню.
- В поле **Client/Certificate** выберете **Certificate/private key**.
- Выберите `vpnclient.cer` файл в поле **Certificate file**.
- Выберите `vpnclient.key` файл в поле **Private key**.
- В секции **Options**, поставьте галочку **Request an inner IP address**.
- В секции **Algorithms** (кликните на неё!), отметьте **Enable custom algorithm proposals**.
- Оставьте пустым поле **IKE**.
- Введите `aes128gcm16` в поле **ESP**.
- Нажмите **Добавить** чтобы сохранить информацию о VPN подключении.
- Включите переключатель **VPN**.

