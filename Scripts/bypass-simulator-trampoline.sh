#!/bin/bash

# The manipulation of the following database is only possible if the System Integraty Protection (SIP) is disabled.
# SIP can only be updated (enabled/disabled) in recovery mode.
# Check the status of SIP: csrutil status
 
## Simulator Trampoline (access to microphone)
## When using freshly cloned virtual machines, running our tests leads to a popup asking for access to the microphone. To avoid that popup, we can preventively write to the database.
sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "INSERT INTO 'main'.'access' ('service', 'client', 'client_type', 'auth_value', 'auth_reason', 'auth_version', 'csreq', 'policy_id', 'indirect_object_identifier_type', 'indirect_object_identifier', 'indirect_object_code_identity', 'flags', 'last_modified', 'pid', 'pid_version', 'boot_uuid', 'last_reminded') VALUES ('kTCCServiceMicrophone', 'com.apple.CoreSimulator.SimulatorTrampoline', '0', '2', '2', '1', X'fade0c00000000480000000100000006000000020000002b636f6d2e6170706c652e436f726553696d756c61746f722e53696d756c61746f725472616d706f6c696e650000000003', NULL, NULL, 'UNUSED', NULL, '0', strftime('%s','now'), NULL, NULL, 'UNUSED', '0');"
