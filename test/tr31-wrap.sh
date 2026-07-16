#!/usr/bin/env bash
# Test: psec-tool tr31 wrap
set -euo pipefail

KBPK="ABABABABABABABABABABABABABABABAB"
HEADER="B0096P0TE00N0000"
KEY="CDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCD"

# Wrap the key
RESULT=$(./psec-tool tr31 wrap -k "$KBPK" "$HEADER" "$KEY")
echo "wrapped: $RESULT"

# Verify roundtrip: unwrap with same KBPK should give back the original key
UNWRAPPED=$(./psec-tool tr31 unwrap -k "$KBPK" "$RESULT" 2>/dev/null | grep '^key:' | awk '{print $2}')
echo "unwrapped key: $UNWRAPPED"

if [ "$UNWRAPPED" != "$KEY" ]; then
    echo "FAIL: roundtrip mismatch. Expected $KEY, got $UNWRAPPED"
    exit 1
fi
echo "PASS: roundtrip OK"

# Wrap with --masked-key-len
RESULT2=$(./psec-tool tr31 wrap -k "$KBPK" -m 32 "$HEADER" "$KEY")
echo "wrapped (masked=32): $RESULT2"
UNWRAPPED2=$(./psec-tool tr31 unwrap -k "$KBPK" "$RESULT2" 2>/dev/null | grep '^key:' | awk '{print $2}')
echo "unwrapped key: $UNWRAPPED2"

if [ "$UNWRAPPED2" != "$KEY" ]; then
    echo "FAIL: roundtrip mismatch with masked_key_len. Expected $KEY, got $UNWRAPPED2"
    exit 1
fi
echo "PASS: masked_key_len roundtrip OK"

# Test error: invalid header
set +eo pipefail
./psec-tool tr31 wrap -k "$KBPK" "invalid" "$KEY" 2>&1 | grep -q "error:"
if [ $? -ne 0 ]; then
    echo "FAIL: expected error for invalid header"
    exit 1
fi
set -eo pipefail
echo "PASS: invalid header error"
