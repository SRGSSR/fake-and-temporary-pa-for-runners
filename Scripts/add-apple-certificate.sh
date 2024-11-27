#!/bin/bash

root_dir="$1"
keychain_password="$2"
apple_certificate_base64="$3"
apple_certificate_password="$4"


if [[ -z $root_dir || -z $keychain_password || -z $apple_certificate_base64 || -z $apple_certificate_password ]]
then
    echo "[!] Usage: $0 <root_dir> <keychain_password> <apple_certificate_base64 (base64)> <apple_certificate_password>"
    exit 1
fi

keychain_path="$root_dir/app-signing.keychain-db"
apple_certificate="$root_dir/certificate.p12"

echo -n "$apple_certificate_base64" | base64 --decode -o "$apple_certificate"

# Create a temporary keychain (https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners)
security create-keychain -p "$keychain_password" "$keychain_path"
security set-keychain-settings -lut 21600 "$keychain_path"
security unlock-keychain -p "$keychain_password" "$keychain_path"

# Import certificate
security import "$apple_certificate" -k "$keychain_path" -P "$apple_certificate_password" -A -t cert -f pkcs12
# Authorize access to certificate private key
security set-key-partition-list -S apple-tool:,apple: -k "$keychain_password" "$keychain_path"
# Set the default keychain
security list-keychain -d user -s "$keychain_path"