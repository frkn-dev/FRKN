## Error: Parameter is set incorrecly

If you get this error after trying to connect to the VPN, try the following solution: 
   
   1. Run cmd as administrator 
   2. Run those commands: 
   
   ```
   netsh int ip reset
   netsh int ipv6 reset
   netsh winsock reset
   ```                        
   
   3. Restart the computer
   4. Open Device Manager 
   5. find Network Adapters
   6. uninstall all WAN Miniport devices (IKEv2, IP, IPv6, etc)
   7. click Action > scan for hardware changes the adapters you just uninstalled should come back
   8. set VPN connection
