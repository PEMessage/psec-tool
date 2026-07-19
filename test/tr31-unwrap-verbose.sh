#!/usr/bin/env bash
# Test: psec-tool tr31 unwrap-verbose
set -euo pipefail

K_TDES="ABABABABABABABABABABABABABABABAB"
K_AES="ABABABABABABABABABABABABABABABABABABABABABABABABABABABABABABABAB"
KEY="CDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCD"

for ver in A B C; do
  header="${ver}0016P0TE00N0000"
  KB=$(./psec-tool tr31 wrap -k "$K_TDES" "$header" "$KEY" 2>/dev/null)
  RESULT=$(./psec-tool tr31 unwrap-verbose -k "$K_TDES" "$KB" 2>/dev/null)
  echo "$RESULT" | grep -q "MAC match:.*OK" || { echo "FAIL: V$ver MAC not OK"; exit 1; }
  KEY_OUT=$(echo "$RESULT" | grep "key:" | head -1 | awk '{print $2}')
  if [ "$KEY_OUT" != "$KEY" ]; then
    echo "FAIL: V$ver key mismatch. Expected $KEY, got $KEY_OUT"
    exit 1
  fi
  echo "$RESULT" | grep -q "Library unwrap:.*${KEY}.*(OK)" || { echo "FAIL: V$ver library mismatch"; exit 1; }
  echo "PASS: V$ver unwrap-verbose OK"
done

for ver in D E; do
  header="${ver}0016P0AE00N0000"
  KB=$(./psec-tool tr31 wrap -k "$K_AES" "$header" "$KEY" 2>/dev/null)
  RESULT=$(./psec-tool tr31 unwrap-verbose -k "$K_AES" "$KB" 2>/dev/null)
  echo "$RESULT" | grep -q "MAC match:.*OK" || { echo "FAIL: V$ver MAC not OK"; exit 1; }
  KEY_OUT=$(echo "$RESULT" | grep "key:" | head -1 | awk '{print $2}')
  if [ "$KEY_OUT" != "$KEY" ]; then
    echo "FAIL: V$ver key mismatch. Expected $KEY, got $KEY_OUT"
    exit 1
  fi
  echo "$RESULT" | grep -q "Library unwrap:.*${KEY}.*(OK)" || { echo "FAIL: V$ver library mismatch"; exit 1; }
  echo "PASS: V$ver unwrap-verbose OK"
done

# Test: header-only (no KBPK)
RESULT_H=$(./psec-tool tr31 unwrap-verbose "B0096P0TE00N0000A800A7D1A4C0C1BE762177E1CC59D84844EB67C9F6432B2CA34187AE2E0385EBEE2231697BC5DAE8" 2>/dev/null)
echo "$RESULT_H" | grep -q "No KBPK provided" || { echo "FAIL: header-only message missing"; exit 1; }
echo "$RESULT_H" | grep -q "version_id:.*B" || { echo "FAIL: header-only version_id missing"; exit 1; }
echo "PASS: header-only mode"

# Test error: invalid KBPK (wrong key)
set +eo pipefail
./psec-tool tr31 unwrap-verbose -k "11111111111111111111111111111111" "B0096P0TE00N0000A800A7D1A4C0C1BE762177E1CC59D84844EB67C9F6432B2CA34187AE2E0385EBEE2231697BC5DAE8" 2>&1 | grep -q "Key block MAC doesn't match"
if [ $? -ne 0 ]; then
  echo "FAIL: expected MAC mismatch error for invalid KBPK"
  exit 1
fi
set -eo pipefail
echo "PASS: invalid KBPK (MAC mismatch) error"

# Test error: wrong-length KBPK
set +eo pipefail
./psec-tool tr31 unwrap-verbose -k "0000000000000000" "B0096P0TE00N0000A800A7D1A4C0C1BE762177E1CC59D84844EB67C9F6432B2CA34187AE2E0385EBEE2231697BC5DAE8" 2>&1 | grep -q "KBPK length"
if [ $? -ne 0 ]; then
  echo "FAIL: expected KBPK length error"
  exit 1
fi
set -eo pipefail
echo "PASS: wrong-length KBPK error"

# Test error: unsupported version
set +eo pipefail
./psec-tool tr31 unwrap-verbose -k "$K_TDES" "X0016P0TE00N0000A800A7D1A4C0C1BE762177E1CC59D84844" 2>&1 | grep -q "Version ID.*not supported"
if [ $? -ne 0 ]; then
  echo "FAIL: expected error for unsupported version"
  exit 1
fi
set -eo pipefail
echo "PASS: unsupported version error"

echo "=== All tests passed ==="
