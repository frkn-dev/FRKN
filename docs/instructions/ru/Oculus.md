### Oculus VR

Шаги установки :

Необходимо активировать developer mode на oq2 что бы можно было устанавливать приложения самостоятельно, гайд по активации с офф. сайта: (https://developer.oculus.com/documentation/native/android/mobile-device-setup/)
Теперь когда мы можем устанавливать сторонние приложения (так называемый sideloading) нам необходимо перенести на шлем файл vpnclient.sswan (по аналогии с установкой на android). Это можно сделать через встроенный в шлем браузер либо используя adb, скачиваем файл на пк и пушим его на шлем:
    
    adb push vpnclient.sswan /sdcard/
Следующим шагом установим strong swan скачав apk с https://download.strongswan.org/Android/ и установив его на шлем командой:

    adb install -g -r strongSwan-2.3.3.apk

И вот теперь казалось бы можно надеть шлем и повторить шаги с андройда но есть одна хитрость. По умолчанию встроенный файловый менеджер достаточно урезан и при нажатии на "import vpn profile" просто ничего не произойдет (по аналогичной причине strong swan устанавливается через adb) поэтому переходим к следующему шагу

Скачиваем и устанавливаем кастомный file manager, например Mixplorer (у меня установлен он) с 4pda :
    https://4pda.to/forum/index.php?showtopic=318294
    и устанавливаем его командой
    
    adb install -g -r mixplorer.apk

Теперь можно надеть шлем и оставшиеся шаги повторить как при установке на anroid т.к. теперь по нажатию на "import VPN profile" для навигации и выбора файла будет использоваться mixplorer.

