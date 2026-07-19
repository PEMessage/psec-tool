#!/usr/bin/env bash
# Usage examples for: psec-tool tr31 padding / unpadding
set -x

# === padding ===

# TDES block size (8 bytes): 16-byte key -> 6 pad bytes
./psec-tool tr31 padding -v B 43434343434343434444444444444444

# AES block size (16 bytes): 16-byte key -> 14 pad bytes
./psec-tool tr31 padding -v D 43434343434343434444444444444444

# Short payload
./psec-tool tr31 padding -v A 1122

# Masked key length: 16-byte key masked as 32 bytes (16 extra_pad)
./psec-tool tr31 padding -v B -m 32 43434343434343434444444444444444

# AES-CTR: no block-alignment padding, but extra_pad if masked
./psec-tool tr31 padding -v E 43434343434343434444444444444444

# === unpadding ===

# Roundtrip: pad then unpad
./psec-tool tr31 unpadding -v B 008043434343434343434444444444444444000000000000

# Unpad with masked key
./psec-tool tr31 unpadding -v B 00804343434343434343444444444444444400000000000000000000000000000000000000000000
