#!/usr/bin/env bash
# Test: psec-tool tr31 cmac
set -euo pipefail

KEY="89E88CF7931444F334BD7547FC3F380C"

# TDES CMAC over derivation block (version B, counter=1, usage_enc)
# = known value from kbek-kbak derivation
DATA_TDES="0100000000000080"
EXPECTED_TDES="12802065300D49CA"
RESULT_TDES=$(./psec-tool tr31 cmac "$KEY" "$DATA_TDES" TDES 2>/dev/null)
echo "TDES CMAC: $RESULT_TDES"
if [ "$RESULT_TDES" != "$EXPECTED_TDES" ]; then
    echo "FAIL: TDES CMAC mismatch. Expected $EXPECTED_TDES, got $RESULT_TDES"
    exit 1
fi
echo "PASS: TDES CMAC"

# AES CMAC over derivation block (version D, counter=1, usage_enc)
# = known value from kbek-kbak derivation
DATA_AES="0100000000020080"
EXPECTED_AES="C06D84225E449BBDA4398894112FBE11"
RESULT_AES=$(./psec-tool tr31 cmac "$KEY" "$DATA_AES" AES 2>/dev/null)
echo "AES CMAC: $RESULT_AES"
if [ "$RESULT_AES" != "$EXPECTED_AES" ]; then
    echo "FAIL: AES CMAC mismatch. Expected $EXPECTED_AES, got $RESULT_AES"
    exit 1
fi
echo "PASS: AES CMAC"

# Test error: invalid algo
set +eo pipefail
./psec-tool tr31 cmac "$KEY" "$DATA_TDES" BAD 2>&1 | grep -q "invalid choice"
if [ $? -ne 0 ]; then
    echo "FAIL: expected error for invalid algo"
    exit 1
fi
set -eo pipefail
echo "PASS: invalid algo error"
