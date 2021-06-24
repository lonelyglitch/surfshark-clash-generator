#! /bin/bash

if [ $# -eq 0 ]
then

    echo "Missing arguments"
    echo "Try './cnfgen.sh --help' for more information."

    exit 1

fi

while [ -n "$1" ]
do

    case "$1" in

        "-h" | "--help") 

            echo "
        Usage:

            ./cnfgen.sh SERVER-LIST PORT-PASSWORD-LIST  
            ./cnfgen.sh [OPTION] PORT-PASSWORD-LIST 

            -e, --existing      Uses already existing pinged.txt file to generate configs instead of pinging servers.

        Developed by LonelyGlitch

        repo availabe at https://github.com/lonelyglitch/surfshark-clash-generator
            "
            exit 0

        ;;

        "-e" | "--existing") 
            existing=true
            break
        ;;

        *)

            break

        ;;

    esac

done

if [ "$existing" == "true" ] 
then 


    if test ! -f ./$2 
    then 

        echo "Port and password list $2 not found."
        exit 1
    
    fi

    if test ! -f ./pinged.txt
    then
        
        echo "No existing pinged servers found."
        exit 1

    fi

else

    if test ! -f ./$1 
    then 

        echo "Server list $1 not found."
        exit 1
    
    fi

    if test ! -f ./$2 
    then 

        echo "Port and password list $2 not found."
        exit 1
    
    fi

    if test -f ./pinged.txt
    then

        > pinged.txt
    
    fi

fi

if test ! -f ./profile-set.txt
then
    
    echo "Profile settings file not found."
    
    exit 1

fi

if test ! -f ./rules.txt
then

    echo "Rules file not found!"
    
    exit 1

fi

if test -f ./template.yml
then

    > template.yml

fi

cat ./profile-set.txt >> template.yml

echo "
" >> template.yml

echo "proxies:" >> template.yml

if test -f ./select.txt
then

    > select.txt

fi

echo "
proxy-groups:
  - name: 🔰 Select
    type: select
    proxies:
      - 💠 Auto" >> select.txt

if test -f ./auto.txt
then

    > auto.txt

fi

echo "  - name: 💠 Auto
    type: url-test
    proxies:" >> auto.txt

if [ "$existing" == "true" ] 
then

    pinged="./pinged.txt"

    while IFS= read -r line || [ -n "$line" ]
    do 

        name=$(echo "$line" | grep -o -P "^(.*)(?=\|)")
        res=$(echo "$line" | grep -o -P "(?<=\|)[0-9]+.[0-9]+.[0-9]+.[0-9]+$")

        echo " - {name: $name, server: $res, port:, type: ss, cipher: aes-256-gcm, password:, udp: true}" >> template.yml
        echo "      - $name" >> select.txt
        echo "      - $name" >> auto.txt
    
    done <"$pinged"

else 

    servers="$1"

    while IFS= read -r line || [ -n "$line" ]
    do 

        name=$(echo "$line" | grep -o -P "^(.*)(?=\|)")
        address=$(echo "$line" | grep -o -P "(?<=\|)(.*)$")

        echo "Pinging $name."

        res=$(getent hosts $address | head -n1 | grep -o -P "[0-9]+.[0-9]+.[0-9]+.[0-9]+")

        if [ -z "$res" ]
        then

            echo "Could not connect to the servers. Make sure to use a valid VPN and good Internet connection."
            exit 1

        else

            echo "$name|$res" >> pinged.txt
            echo " - {name: $name, server: $res, port:, type: ss, cipher: aes-256-gcm, password:, udp: true}" >> template.yml
            echo "      - $name" >> select.txt
            echo "      - $name" >> auto.txt

        fi

    done <"$servers"

fi

cat select.txt >> template.yml

echo >> template.yml

cat auto.txt >> template.yml

echo "
    url: 'http://www.gstatic.com/generate_204'
    interval: 300" >> template.yml

echo "
rules:" >> template.yml

rules="./rules.txt"

while IFS= read -r line || [ -n "$line" ]
do

    echo "  - $line" >> template.yml

done <"$rules"

if [ -d ./export ]
then
    
    echo "All files in existing export folder will be deleted. Proceed? (y/n)"

    read option

    case $option in

        "Yes" | "yes" | "y" | "Y")
            rm -r export/*
        ;;

        "No" | "no" | "n" | "N")
            echo "Operation is canceled."

            rm select.txt
            rm auto.txt
            rm template.yml

            exit 1
        ;;

        *)
            echo "Script terminated."

            rm select.txt
            rm auto.txt
            rm template.yml

            exit 1
        ;;

    esac

else

    mkdir export

fi

userpass="$2"

while IFS= read -r line || [ -n "$line" ]
do
    port=$(echo "$line" | grep -o -P "^([0-9]*)(?=\|)")
    pass=$(echo "$line" | grep -o -P "(?<=\|)(.*)$")

    cp template.yml ./export/$port.yml

    sed -i -E "s/(port:,)/port: $port,/g" ./export/$port.yml
    sed -i -E "s/(password:,)/password: $pass,/g" ./export/$port.yml

done <"$userpass"

rm select.txt
rm auto.txt
rm template.yml

echo "Operation finished on $(date)"

exit 0