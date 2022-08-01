### Oculus VR

1. In order to install applications, you need to activate developer mode on oq2 (see activation guide
   [**here**](https://developer.oculus.com/documentation/native/android/mobile-device-setup/)). After this step you can install third-party applications (i.e. sideloading). Then you need to transfer
   `vpnclient.sswan` to your device (the process of installation is the same as on Android). This can be done via internal
   browser or by using `adb`. Download the file to your PC, then push it to the device:
   `adb push vpnclient.sswan /sdcard/`

3. The next step is strong swan installation. Download `apk`
   from [**here**](https://download.strongswan.org/Android/) and install it with the
   next command: 
   
   ```console
   adb install -g -r strongSwan-2.3.3.apk
   ```

Unfortunately, the built-in file manager is quite truncated, so when you click on `import vpn profile` nothing will
happen (that’s why strong swan is installed via `adb`). Therefore, a couple of additional steps need to be taken.

4. Download any decent file manager (I personally use
   [**Mixplorer**](https://4pda.to/forum/index.php?showtopic=318294)) and
   install it with the command:
   
   ```console
   adb install -g -r mixplorer.apk
   `

5. Put on your VR headset and repeat the remaining steps as when installing on android (see [**above**](#android)). Now when you click
   on `import VPN profile` Mixplorer will be used to navigate and select a file.
