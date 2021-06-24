# Surfshark Clash Generator
### Simple bash script to generate clash config files from SurfShark VPN Shadowsocks servers.

![Header](https://github.com/lonelyglitch/surfshark-clash-generator/raw/main/src/header.png)

### **_As of now this script won't work in Termux due to the lack of "getent" command._**

## Guide

- Visit Shadowsocks activation page in your Surfshark profile at **VPN -> Manual setup -> Shadowsocks** or via [this link](https://my.surfshark.com/vpn/manual-setup/shadowsocks)
- If you have not activated Shadowsocks, please do so by clicking on **Activate Shadowsocks**.

    ![Activate Shadowsocks](https://github.com/lonelyglitch/surfshark-clash-generator/raw/main/src/guide1.png)

- Now copy the **Port** and the **Password**, then save it in a text file with the format given below. (Note that you can include multiple ports and passwords from diffrent accounts to generate multiple config files)

    > portpass.txt:
    ```
    port|password
    ```

    ![Shadowsocks port and password](https://github.com/lonelyglitch/surfshark-clash-generator/raw/main/src/guide2.png)

- Click on the Locations tab. You will see the list of all Surfshark server locations on this page. Copy the hostname of the locations you like and store them in a text file with the format given below.

    > servers.txt:
    ```
    name|hostname
    ```

    ![Shadowsocks locations](https://github.com/lonelyglitch/surfshark-clash-generator/raw/main/src//guide3.png)

- Clone this repository to your computer

    ```bash
    $ git clone https://github.com/lonelyglitch/surfshark-clash-generator.git
    ```

- Place **servers.txt** and **portpass.txt** in the same folder as the script. 

- Execute the script with **servers.txt** and **portpass.txt** as arguments.

    ```bash
    $ ./cnfgen.sh servers.txt portpass.txt 
    ```
    The first argument should be location of the file in which you've stored the server hostnames (in this case *servers.txt*) and the second one should be the location of the file in which you've stored ports and passwords (in this case *portpass.txt*)

    - Alternatively if you've previously executed the script and have a cached version of server IP addresses stored in the auto-generated **_pinged.txt_** file you can use the "-e" switch to use that local version instead of fetching IPs again via internet.

        ```bash
        $ ./cnfgen.sh -e portpass.txt
        ```
    
    **If you live in a country in which Surfshark hostnames are blocked you would have to use a VPN temporarily for script to ping the hostnames and store server IPs.**

    **Once you've executed the script successfully once, you can generate configs without the need of Internet connection.**

- After the successful execution of the script, generated **.yml** clash config files will be stored in **export folder**

## Configuration Files

**Some configurations required to generate clash .yml files are stored in text files in the same directory as the script. You may alter them based on your prefrences**

### profile-set.txt

This file contains basic information about generated profile's behavior in Clash.

Default file contains following:

```
port: 1050
socks-port: 1080
allow-lan: true
mode: Rule
log-level: silent
external-controller: 127.0.0.1:9090
```

### rules.txt

This file contains clash profile rules.

Default file contains following:

```
IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
IP-CIDR,100.64.0.0/10,DIRECT,no-resolve
IP-CIDR6,::1/128,DIRECT,no-resolve
IP-CIDR6,fc00::/7,DIRECT,no-resolve
IP-CIDR6,fe80::/10,DIRECT,no-resolve
IP-CIDR6,fd00::/8,DIRECT,no-resolve
DOMAIN-SUFFIX,ad.com,REJECT
SRC-IP-CIDR,192.168.1.201/32,DIRECT
MATCH,,🔰 Select,dns-failed
```

You can add `GEOIP,{Your Country's GEOIP},DIRECT` before the last line to make proxy ineffective on local websites as given in the Example below for China:

```
IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
IP-CIDR,100.64.0.0/10,DIRECT,no-resolve
IP-CIDR6,::1/128,DIRECT,no-resolve
IP-CIDR6,fc00::/7,DIRECT,no-resolve
IP-CIDR6,fe80::/10,DIRECT,no-resolve
IP-CIDR6,fd00::/8,DIRECT,no-resolve
DOMAIN-SUFFIX,ad.com,REJECT
SRC-IP-CIDR,192.168.1.201/32,DIRECT
GEOIP,CN,DIRECT
MATCH,,🔰 Select,dns-failed
```