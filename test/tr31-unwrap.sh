#!/usr/bin/env bash
# Usage examples for: psec-tool tr31 unwrap
# Copy any line below to run it directly.
set -x

# KBPK = b"FFFFFFFFEEEEEEEE" (hex), key block from psec.tr31 docstring
./psec-tool tr31 unwrap --kbpk 46464646464646464545454545454545 B0096P0TE00N0000A800A7D1A4C0C1BE762177E1CC59D84844EB67C9F6432B2CA34187AE2E0385EBEE2231697BC5DAE8

# Without --kbpk: parse header only (no decryption or MAC check)
./psec-tool tr31 unwrap B0096P0TE00N0000A800A7D1A4C0C1BE762177E1CC59D84844EB67C9F6432B2CA34187AE2E0385EBEE2231697BC5DAE8
