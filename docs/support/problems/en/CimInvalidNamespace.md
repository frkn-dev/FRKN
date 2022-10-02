# Error: "Cannot connect to CIM server. Invalid namespace."

If you get this type of error while trying to add VPN profile on Windows, try the following solution:

  1. Run PowerShell as administrator
  2. Restart **winmgmt** service:
  
  ```shell
  sc config winmgmt start=disabled
  net stop winmgmt
  Winmgmt /salvagerepository %windir%\System32\wbem
  Winmgmt /resetrepository %windir%\System32\wbem
  sc config winmgmt start=auto
  Get-NetIPInterface
  ```