#!/bin/bash

# Path to read dynamic DB credentials from
srcpath=database/creds/db1-5s

# KV path to write DB credentials to
dstpath=secret/app1/db1-5s

# Capture dyn creds in JSON format
dynjson=`vault read -format=json $srcpath 2>&1`

if [ $? -ne 0 ]; then
  code=$?
  echo "Error reading from Vault $srcpath: $dynjson"
  exit $code
fi

# Parse JSON
username=`echo $dynjson | jq -r .data.username`
password=`echo $dynjson | jq -r .data.password`
lease_id=`echo $dynjson | jq -r .lease_id`
warnings=`echo $dynjson | jq -r .warnings`

# Write to KV path
output=`vault kv put $dstpath username="$username" password="$password" lease_id="$lease_id" warnings="$warnings" 2>&1`

if [ $? -ne 0 ]; then
  code=$?
  echo "Error writing to Vault $dstpath: $output"
  exit $code
fi

#vault kv get $dstpath
