#!/bin/bash

# get APK
APP=$1

function splash() {
	echo "----------------------"
	echo "      APKScanner      "
	echo " Developed by n3k00n3 "
	echo "----------------------"
	echo ""
}

function fileInfo() {
	MD5_info=$(md5 $APP | cut -d " " -f 4)
	size=$(du -h $APP)
	echo "MD5: $MD5_info"
	echo "Size: $size"
}

function decompileAPK() {
	echo "Decompiling the APK..."
	echo ""
	jadx -d app $APP > /dev/null
	cd app
}

function applicationInformation() {
	echo "[+] Application Information"
	echo "---------------------------"
	echo ""

	cat resources/AndroidManifest.xml | grep package | tr " " "\n" | grep package | sed 's/=/: /' | sed 's/[">]//g' 
	cat resources/AndroidManifest.xml | grep minSdkVersion | tr " " "\n" | grep minSdkVersion | sed 's/android://' | tr "=" ":" | sed 's/"/ /g'
	cat resources/AndroidManifest.xml | grep minSdkVersion | tr " " "\n" | sed 's/[/>]//g' | grep targetSdkVersion | sed 's/android://' | sed 's/=/:/g' | sed 's/"/ /g'
	fileInfo

	echo ""
}

function getMinSDKVersion() {
	MinVersion=$(cat resources/AndroidManifest.xml | grep minSdkVersion | tr " " "\n" | grep minSdkVersion | cut -d "=" -f2 | sed 's/"//g')

	if [ $MinVersion -le 16 ]; then
		echo "	[!!! Warning] Activity exported=TRUE by default"
		echo ""
		exported=1
	fi
}

# Enabled Backup?
# This is considered a security issue because people could backup your app via ADB and then
# get private data of your app into their PC.
function checkBackup() {
	echo "[+] Backup Enabled"
	echo "------------------"
	echo ""
	cat resources/AndroidManifest.xml | grep 'android:allowBackup="true"' --color
	echo ""
}

function checkPermissions() {
	echo "[+] Dangerous Permissions"
	echo "-------------------------"
	echo ""
	cat resources/AndroidManifest.xml | egrep '(READ_CALENDAR|WRITE_CALENDAR|CAMERA|READ_CONTACTS|WRITE_CONTACTS|GET_ACCOUNTS|ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|RECORD_AUDIO|READ_PHONE_STATE|READ_PHONE_NUMBERS |CALL_PHONE|ANSWER_PHONE_CALLS|READ_CALL_LOG|WRITE_CALL_LOG|ADD_VOICEMAIL|USE_SIP|PROCESS_OUTGOING_CALLS|BODY_SENSORS|SEND_SMS|RECEIVE_SMS|READ_SMS|RECEIVE_WAP_PUSH|RECEIVE_MMS|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE|ACCESS_MEDIA_LOCATION|ACCEPT_HANDOVER|ACCESS_BACKGROUND_LOCATION|ACTIVITY_RECOGNITION)' --color
	echo ""
}

# Debugable
# Debugging was enabled on the app which makes it easier for reverse engineers to hook a debugger to it.
# This allows dumping a stack trace and accessing debugging helper classes.
function checkDebug() {
	echo "[+] Debugable App"
	echo "-----------------"
	echo ""
	cat resources/AndroidManifest.xml | grep 'android:debuggable="true"' --color
	echo ""
}

function checkPIN() {
	echo "[+] Missing PIN Check"
	echo "---------------------"
	echo ""

	isDeviceSecure=$(grep -owr 'isDeviceSecure' .)
	isKeyguardSecure=$(grep -owr 'isKeyguardSecure' .)

	if [ \( "$isDeviceSecure" = "" -a  "$isKeyguardSecure" = "" \) ]; then
		echo "	[!!!] The App does not check for PIN Protection"
		echo ""
	fi
}

function jsEnabled() {
	echo "[+] JavaScript enabled"
	echo "----------------------"
	echo ""
	grep -rn setJavaScriptEnabled . | grep "setJavaScriptEnabled(true)" --color
	echo ""
}

function checkActivities() {
	echo "[+] Exported activities"
	echo "-----------------------"
	echo ""
	cat resources/AndroidManifest.xml | grep "activity" | grep 'exported="true"' --color | sed "s/<activity//g" | sed "s/\/>//g" | sed "s/<\/activity>//g" | sed '/^[[:space:]]*$/d'
	if [[ $exported == 1 ]]; then
		cat resources/AndroidManifest.xml | grep activity | grep -v 'exported="false"' | sed "s/<activity//g" | sed "s/\/>//g" | sed "s/<\/activity>//g" | sed '/^[[:space:]]*$/d'
	fi
	echo ""
}

function checkLaunchMode() {
	echo "[+] Insecure Launch mode"
	echo "------------------------"
	echo ""
	cat resources/AndroidManifest.xml | grep "activity" | egrep '(singleTask|singleInstance)' --color
	echo ""
}

function checkProviders() {
	echo "[+] Exported providers"
	echo "-----------------------"
	echo ""
	cat resources/AndroidManifest.xml | grep "provider" | grep 'exported="true"' --color | sed "s/<provider//g" | sed "s/\/>//g" | sed "s/<\/provider>//g" | sed '/^[[:space:]]*$/d'
	if [[ $exported == 1 ]]; then
		cat resources/AndroidManifest.xml | grep provider | grep -v 'exported="false"' | sed "s/<provider//g" | sed "s/\/>//g" | sed "s/<\/provider>//g" | sed '/^[[:space:]]*$/d'
	fi
	echo ""
}


function checkContentPath() {
	echo "[+] Content Path"
	echo "----------------"
	echo ""
	grep -or 'content://[a-zA-Z0-9.-]*' . | grep -o 'content://[a-zA-Z0-9.-]*'
	echo ""
}

function checkFirebase() {
	echo -e "  [++] Testing $URL/.json"
	curl $URL/.json
	echo ""
}

function findFirebaseURL() {
	echo "[+] Firebase URL"
	echo "----------------"
	echo ""

	URL=$(grep -r firebaseio.com . | grep -o 'https://[a-zA-Z0-9.-]*')	
	if [[ $URL != "" ]];then
		echo $URL
		echo ""
		checkFirebase
	fi
}

function FindAntiVM() {
	echo "[+] Anti-VM"
	echo "-----------"
	echo ""
	grep -rw Emulator --color .
	echo ""
}

function findURLs() {
	echo "[+] URLS"
	echo "--------"
	echo "    HTTP:"
	egrep -orw 'http://[a-zA-Z0-9.-]*' . | grep -o 'http://[a-zA-Z0-9.-]*' | egrep -v '(google.com|apache.org|w3.org|xml.org|xml.org|play.google.com|java.sun.com|outube.com|openstreetmap.org)' | sort | uniq
	echo "    HTTPS:"
	egrep -orw 'https://[a-zA-Z0-9.-]*' . | grep -o 'https://[a-zA-Z0-9.-]*' | egrep -v '(google|apache|w3.org|xml.org|java.sun.com|youtube.com|openstreetmap.org|viadeo.com|pinterest.com|travis-ci.org|facebook	|linkedin.com|googleapis|gnu.org|vimeo.com|paypal|publicsuffix|realm|soundcloud|twitter|crashlytics|flickr|instagram|mozilla)' | sort | uniq
	echo ""
}

splash
decompileAPK
applicationInformation
getMinSDKVersion
checkPermissions
checkBackup
checkDebug
checkPIN
jsEnabled
checkActivities
checkLaunchMode
checkProviders
checkContentPath
findFirebaseURL
FindAntiVM
findURLs
