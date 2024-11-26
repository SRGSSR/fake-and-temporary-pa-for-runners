#!/bin/bash

apple_api_key_b64="$1"
apple_account_info_b64="$2"

if [[ -z $apple_api_key_b64 || -z $apple_account_info_b64 ]]
then
    echo "[!] Usage: $0 <apple_api_key_b64> <apple_account_info_b64>"
    exit 1
fi

mkdir -p Configuration
echo "$apple_account_info_b64" | base64 --decode > Configuration/.env
echo "$apple_api_key_b64" | base64 --decode > Configuration/AppStoreConnect_API_Key.p8
