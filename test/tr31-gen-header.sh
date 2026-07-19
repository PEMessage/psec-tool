#!/usr/bin/env bash
# Test: psec-tool tr31 gen-header
set -euo pipefail

# Basic header: version B, PIN encryption, TDES, encrypt only, non-exportable
HEADER=$(./psec-tool tr31 gen-header -v B -u P0 -a T -m E -n 00 -e N | tail -1)
echo "header: $HEADER"

if [ "$HEADER" != "B0016P0TE00N0000" ]; then
    echo "FAIL: expected B0016P0TE00N0000, got $HEADER"
    exit 1
fi
echo "PASS: basic header"

# With optional block and key length (AES key block, 24-byte key)
HEADER2=$(./psec-tool tr31 gen-header -v D -u P0 -a A -m E -b KS=00604B120F9292800000 -l 24 | tail -1)
echo "header: $HEADER2"

if [ "$HEADER2" != "D0144P0AE00N0200KS1800604B120F9292800000PB080000" ]; then
    echo "FAIL: unexpected header with block, got $HEADER2"
    exit 1
fi
echo "PASS: optional block + key-len"

# Roundtrip: generated header must be accepted by wrap/unwrap
KBPK="ABABABABABABABABABABABABABABABAB"
KEY="CDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCD"
WRAPPED=$(./psec-tool tr31 wrap -k "$KBPK" -H "$HEADER" "$KEY")
echo "wrapped: $WRAPPED"
UNWRAPPED=$(./psec-tool tr31 unwrap -k "$KBPK" "$WRAPPED" 2>/dev/null | grep '^key:' | awk '{print $2}')

if [ "$UNWRAPPED" != "$KEY" ]; then
    echo "FAIL: roundtrip mismatch. Expected $KEY, got $UNWRAPPED"
    exit 1
fi
echo "PASS: wrap/unwrap roundtrip"

# Test error: invalid algorithm field
set +eo pipefail
./psec-tool tr31 gen-header -a '??' 2>&1 | grep -q "error:"
if [ $? -ne 0 ]; then
    echo "FAIL: expected error for invalid algorithm"
    exit 1
fi
set -eo pipefail
echo "PASS: invalid algorithm error"

# Test error: invalid block spec (missing '=')
set +eo pipefail
./psec-tool tr31 gen-header -b KS 2>&1 | grep -q "error:"
if [ $? -ne 0 ]; then
    echo "FAIL: expected error for invalid block spec"
    exit 1
fi
set -eo pipefail
echo "PASS: invalid block spec error"

# Interactive mode: fields answered via stdin, empty answers keep defaults
HEADER3=$(printf 'D\nP0\nA\nE\n\nE\nKS=00604B120F9292800000\n\n24\n' \
    | ./psec-tool tr31 gen-header -i | tail -1)
echo "header: $HEADER3"

if [ "$HEADER3" != "D0144P0AE00E0200KS1800604B120F9292800000PB080000" ]; then
    echo "FAIL: unexpected interactive header, got $HEADER3"
    exit 1
fi
echo "PASS: interactive mode"

# Interactive mode: empty answers fall back to CLI option defaults
HEADER4=$(printf '\n\n\n\n\n\n\n\n' \
    | ./psec-tool tr31 gen-header -i -v B -u P0 -a T -m E | tail -1)
echo "header: $HEADER4"

if [ "$HEADER4" != "B0016P0TE00N0000" ]; then
    echo "FAIL: unexpected interactive default header, got $HEADER4"
    exit 1
fi
echo "PASS: interactive defaults from CLI options"

# Interactive mode: select by menu number (4=D, 29=P0, 1=A, 3=E, 2=N)
HEADER5=$(printf '4\n29\n1\n3\n\n2\n\n\n' \
    | ./psec-tool tr31 gen-header -i | tail -1)
echo "header: $HEADER5"

if [ "$HEADER5" != "D0016P0AE00N0000" ]; then
    echo "FAIL: unexpected numbered-selection header, got $HEADER5"
    exit 1
fi
echo "PASS: interactive numbered selection"

# Interactive mode: invalid choice is rejected and re-prompted
HEADER6=$(printf 'Z\nD\nP0\nA\nE\n\nE\n\n\n' \
    | ./psec-tool tr31 gen-header -i | tail -1)
echo "header: $HEADER6"

if [ "$HEADER6" != "D0016P0AE00E0000" ]; then
    echo "FAIL: unexpected header after invalid choice, got $HEADER6"
    exit 1
fi
echo "PASS: interactive invalid choice re-prompt"
