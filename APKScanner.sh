#!/bin/bash

echo "----------------------"
echo "      APKScanner      "
echo " Developed by n3k00n3 "
echo "-----------------------"
echo ""

echo "Decompiling the APK..."
echo ""
jadx -d app $1 > /dev/null
cd app

echo "[+] File Information"
echo "--------------------"
echo ""

cat resources/AndroidManifest.xml | grep package | tr " " "\n" | grep package | sed 's/=/: /' | sed 's/"//g'
cat resources/AndroidManifest.xml | grep minSdkVersion | tr " " "\n" | grep minSdkVersion | sed 's/android://'
cat resources/AndroidManifest.xml | grep minSdkVersion | tr " " "\n" | grep targetSdkVersion | sed 's/android://' | sed 's/\/>//'

echo ""

MinVersion=$(cat resources/AndroidManifest.xml | grep minSdkVersion | tr " " "\n" | grep minSdkVersion | cut -d "=" -f2 | sed 's/"//g')
if [ $MinVersion -le 16 ]; then
	echo "[!!! Warning] Activity exported=TRUE by default"
	exported=1
fi

# search for Sensitive information
# TODO: Create a wordlist file 
#ag IvParameterSpec
#ag SecretKeySpec
#ag aes
#ag iv

# TODO: possible IPS

# TODO: URLs

# Enabled Backup?
# This is considered a security issue because people could backup your app via ADB and then get private data of your app into their PC.
echo "[+] Backup Enabled"
echo "------------------"
echo ""
cat resources/AndroidManifest.xml | grep 'android:allowBackup="true"' --color
echo ""

# Debugable
# Debugging was enabled on the app which makes it easier for reverse engineers to hook a debugger to it. This allows dumping a stack trace and accessing debugging helper classes.

echo "[+] Debugable App"
echo "-----------------"
echo ""
cat resources/AndroidManifest.xml | grep 'android:debuggable="true"' --color
echo ""

# Exported activities
echo "[+] Exported activities"
echo "-----------------------"
echo ""
cat resources/AndroidManifest.xml | grep "activity" | grep 'exported="true"' --color
if [ $exported == 1 ]; then
	cat resources/AndroidManifest.xml | grep activity | grep -v 'exported="false"' | sed 's/<\/activity>//g'
fi
echo ""

echo "[+] Firebase URL"
echo "------------"
echo "" 
URL=$(grep -r firebaseio.com . | grep -o 'https://[a-zA-Z0-9.-]*')
echo $URL
echo "" 
echo -e "[+] Testing $URL/.json"
curl $URL/.json
echo ""

# Anti-Vm codes
echo "[+] Anti-VM"
echo "-----------"
echo ""
grep -rw Emulator --color .


# URL finder
echo "[+] URLS"
echo "-----------"
echo "    HTTP:"
egrep -orw 'http://[a-zA-Z0-9.-]*' . | grep -o 'http://[a-zA-Z0-9.-]*' | egrep -v '(google.com|apache.org|w3.org|xml.org|xml.org|play.google.com|java.sun.com|outube.com|openstreetmap.org)' | sort | uniq
echo "    HTTPS:"
egrep -orw 'https://[a-zA-Z0-9.-]*' . | grep -o 'https://[a-zA-Z0-9.-]*' | egrep -v '(google.com|apache.org|w3.org|xml.org|xml.org|play.google.com|java.sun.com|outube.com|openstreetmap.org)' | sort | uniq

