#!/usr/bin/env bash
# Usage examples for: psec-tool tr31 kbpk
# Copy any line below to run it directly.
set -x

# Print derived intermediate keys (KBEK/KBAK) for all versions
./psec-tool tr31 kbpk --kbpk 89E88CF7931444F334BD7547FC3F380C
