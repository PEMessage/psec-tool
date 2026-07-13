#!/usr/bin/env bash
# Usage examples for: psec-tool tr31 cmac-k1k2
# Copy any line below to run it directly.
set -x

# CMAC subkeys K1/K2 for both DES (8-byte) and AES (16-byte) from a key
./psec-tool tr31 cmac-k1k2 89E88CF7931444F334BD7547FC3F380C
