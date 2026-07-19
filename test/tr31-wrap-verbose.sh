#!/usr/bin/env bash
# Test: psec-tool tr31 wrap-verbose
set -euo pipefail

KBPK_TDES="ABABABABABABABABABABABABABABABAB"
KBPK_AES="ABABABABABABABABABABABABABABABABABABABABABABABABABABABABABABABAB"
KEY="CDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCD"

for ver in A B C; do
  header="${ver}0016P0TE00N0000"
  RESULT=$(./psec-tool tr31 wrap-verbose -k "$KBPK_TDES" -H "$header" "$KEY" 2>/dev/null)
  echo "$RESULT" | grep -q "Self-unwrap:.*(OK)" || { echo "FAIL: V$ver self-unwrap not OK"; exit 1; }
  KEY_BLOCK=$(echo "$RESULT" | grep "^  ${ver}" | tail -1 | tr -d ' ')
  UNWRAPPED=$(./psec-tool tr31 unwrap -k "$KBPK_TDES" "$KEY_BLOCK" 2>/dev/null | grep '^key:' | awk '{print $2}')
  if [ "$UNWRAPPED" != "$KEY" ]; then
    echo "FAIL: V$ver roundtrip mismatch. Expected $KEY, got $UNWRAPPED"
    exit 1
  fi
  echo "PASS: V$ver self-unwrap + roundtrip OK"
done

for ver in D E; do
  header="${ver}0016P0AE00N0000"
  RESULT=$(./psec-tool tr31 wrap-verbose -k "$KBPK_AES" -H "$header" "$KEY" 2>/dev/null)
  echo "$RESULT" | grep -q "Self-unwrap:.*(OK)" || { echo "FAIL: V$ver self-unwrap not OK"; exit 1; }
  KEY_BLOCK=$(echo "$RESULT" | grep "^  ${ver}" | tail -1 | tr -d ' ')
  UNWRAPPED=$(./psec-tool tr31 unwrap -k "$KBPK_AES" "$KEY_BLOCK" 2>/dev/null | grep '^key:' | awk '{print $2}')
  if [ "$UNWRAPPED" != "$KEY" ]; then
    echo "FAIL: V$ver roundtrip mismatch. Expected $KEY, got $UNWRAPPED"
    exit 1
  fi
  echo "PASS: V$ver self-unwrap + roundtrip OK"
done

# Wrap with --masked-key-len
RESULT_M=$(./psec-tool tr31 wrap-verbose -k "$KBPK_TDES" -m 32 -H "C0016P0TE00N0000" "$KEY" 2>/dev/null)
echo "$RESULT_M" | grep -q "Self-unwrap:.*(OK)" || { echo "FAIL: masked self-unwrap not OK"; exit 1; }
KEY_BLOCK_M=$(echo "$RESULT_M" | grep "^  C" | tail -1 | tr -d ' ')
UNWRAPPED_M=$(./psec-tool tr31 unwrap -k "$KBPK_TDES" "$KEY_BLOCK_M" 2>/dev/null | grep '^key:' | awk '{print $2}')
if [ "$UNWRAPPED_M" != "$KEY" ]; then
  echo "FAIL: masked roundtrip mismatch. Expected $KEY, got $UNWRAPPED_M"
  exit 1
fi
echo "PASS: masked_key_len roundtrip OK"

# Test error: unsupported version
set +eo pipefail
./psec-tool tr31 wrap-verbose -k "$KBPK_TDES" -H "X0016P0TE00N0000" "$KEY" 2>&1 | grep -q "Version ID.*not supported"
if [ $? -ne 0 ]; then
  echo "FAIL: expected error for unsupported version"
  exit 1
fi
set -eo pipefail
echo "PASS: unsupported version error"

# Test error: invalid header
set +eo pipefail
./psec-tool tr31 wrap-verbose -k "$KBPK_TDES" -H "invalid" "$KEY" 2>&1 | grep -q "error:"
if [ $? -ne 0 ]; then
  echo "FAIL: expected error for invalid header"
  exit 1
fi
set -eo pipefail
echo "PASS: invalid header error"

echo "=== All tests passed ==="
