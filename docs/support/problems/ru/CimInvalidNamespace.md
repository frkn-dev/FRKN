# Ошибка: "Не удается подключиться к CIM-серверу. Неправильное пространство имен."

Если вы получаете эту ошибку при попытке создания VPN профиля, попробуйте следующее решение:

  1. Запустите PowerShell от имени администратора
  2. Перезапустите службу **winmgmt**:
  
  ```shell
  sc config winmgmt start=disabled
  net stop winmgmt
  Winmgmt /salvagerepository %windir%\System32\wbem
  Winmgmt /resetrepository %windir%\System32\wbem
  sc config winmgmt start=auto
  Get-NetIPInterface
  ```