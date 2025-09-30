#!/bin/bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="${REPO_DIR}/backup.sh"
CRON_LOG="${REPO_DIR}/cron.log"

# Ensure script is executable
chmod +x "$SCRIPT"

# Detect bash absolute path and create a safe PATH for cron
BASH_BIN="$(command -v bash || echo /bin/bash)"

# Build cron line (note: absolute paths; cron has minimal env)
CRON_LINE="* * * * * SHELL=${BASH_BIN} PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ${BASH_BIN} ${SCRIPT} >> ${CRON_LOG} 2>&1"

# Install (idempotent): remove any prior identical line, then add
( crontab -l 2>/dev/null | grep -vF "${SCRIPT}" ; echo "${CRON_LINE}" ) | crontab -

echo "[+] Cronjob installed for user: $(whoami)"
echo "[+] Runs: ${SCRIPT} every minute"
echo "[+] Output logged to: ${CRON_LOG}"
echo "[i] View crontab with: crontab -l"
