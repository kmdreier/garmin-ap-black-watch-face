#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

task_garmin_root="$HOME/Library/Application Support/Garmin/ConnectIQ"
if [[ -f "$task_garmin_root/current-sdk.cfg" ]]; then
    task_sdk="$(tr -d '\r\n' < "$task_garmin_root/current-sdk.cfg")"
else
    task_sdk="$PWD/.tools/sdk"
fi

if [[ ! -d "$task_garmin_root/Devices/fr265s" ]]; then
    echo 'In Garmin SDK Manager, download Forerunner 265S under Devices, then run this again.'
    exit 1
fi

task_java="$PWD/.tools/jdk-17.0.20.1+1-jre/Contents/Home/bin/java"
if [[ ! -x "$task_java" ]]; then
    task_java="$(/usr/libexec/java_home)/bin/java"
fi

mkdir -p .keys bin
if [[ ! -f .keys/developer_key.der ]]; then
    (umask 077; openssl genrsa -out .keys/developer_key.pem 4096 2>/dev/null)
    openssl pkcs8 -topk8 -inform PEM -outform DER -in .keys/developer_key.pem \
        -out .keys/developer_key.der -nocrypt
    chmod 600 .keys/developer_key.der
fi

"$task_java" -Xms256m -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true \
    -classpath "$task_sdk/bin/monkeybrains.jar" com.garmin.monkeybrains.Monkeybrains \
    -f monkey.jungle -d fr265s -y .keys/developer_key.der \
    -o bin/APBlack-fr265s.prg -r -w -l 1

echo 'Built: bin/APBlack-fr265s.prg'
