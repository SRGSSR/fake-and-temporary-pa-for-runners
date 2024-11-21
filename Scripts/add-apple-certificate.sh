#!/bin/bash

apple_certificate_b64="$1"

if [[ -z $apple_certificate_b64 ]]
then
    echo "[!] Usage: $0 <apple_certificate_b64 (base64)>"
    exit 1
fi

apple_certificate_password=""
apple_certificate_decoded_path="/tmp/certificate.p12"

keychain_password="admin"
keychain_path="$HOME/Library/Keychains/login.keychain-db"

echo "$apple_certificate_b64" | base64 --decode > "$apple_certificate_decoded_path"

# Import certificate
security import "$apple_certificate_decoded_path" -k "$keychain_path" -P "$apple_certificate_password" -T /usr/bin/security -T /usr/bin/codesign
# Authorize access to certificate private key
security set-key-partition-list -S apple-tool:,apple: -s -k "$keychain_password" "$keychain_path"