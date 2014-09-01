network_switcher
================

Automatically query clear-guest password from intranet and apply it to clear-guest wifi network

**************************************
tushi@ubuntu:~/Projects/network_switcher$ ./setup.sh 
```
You have already setup network switcher, continue(Y/n)?
```
```
Available networks:
1 : TP-LINK_jerry
2 : clear-guest
3 : clear
4 : Wired connection 1
```
```
Please select name of your Wired Network:?
4
```
```
Please select name of your Wireless(clear-guest) Network:
2
```
```
Please enter email address of your Oracle SSO login:
tuo.shi@oracle.com
```
```
Please enter password of your Oracle SSO login:
!!!! Password of your Oracle SSO login is safe as it will be encrypted with Base64
********
```
```
Setup is complete!
```

**************************************
tushi@ubuntu:~/Projects/network_switcher$ ./run.sh 
```
2014-01-13 12:37:32 +0800: Connected to network "Wired connection 1"
2014-01-13 12:37:41 +0800: Accessing https://gmp.oracle.com/captcha/ to get today's wifi password
2014-01-13 12:37:53 +0800: Filling in SSO login to access the real page
2014-01-13 12:37:54 +0800: Unpacking JAPAC clear-guest password
2014-01-13 12:37:54 +0800: Password of JAPAC clear-guest is : gUq2smTQ
2014-01-13 12:38:02 +0800: Connected to network "clear-guest"
2014-01-13 12:38:10 +0800: Accessing random URL to let browser redirect to web authentication page
2014-01-13 12:38:10 +0800: You've already authenticated
2014-01-13 12:38:10 +0800: Enjoy!
```

