#!/bin/bash

#----------------------
# Simple APK scanner
# Developed by n3k00n3
#----------------------

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
fi

# search for Sensitive information
# TODO: Create a wordlist file 
#ag IvParameterSpec
#ag SecretKeySpec
#ag aes
#ag iv

# TODO: possible IPS

# TODO: URLs

# Enables Backup?
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
cat resources/AndroidManifest.xml | grep "activity" | grep 'exported="true"' --color | sed 's/^ //g'
echo ""

# Firebaseio

#Use this link to tests: https://swapcard-android-app-2014.firebaseio.com
#ag https*://(.+?)\.firebaseio.com 

