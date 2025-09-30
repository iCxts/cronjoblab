#!/bin/bash
set -euo pipefail

# --- Configuration (students may tweak these) ---
SRC_DIR="${HOME}/labdata"                 # directory to back up (create if missing)
DEST_DIR="${HOME}/backups"                # where to store backups
LOG_FILE="${DEST_DIR}/backup.log"         # log of backup activity

# Absolute paths for cron (cron has a minimal PATH)
DATE_BIN="/bin/date"
MKDIR_BIN="/bin/mkdir"
TAR_BIN="/usr/bin/tar"
ECHO_BIN="/bin/echo"
TEST_BIN="/usr/bin/test"

# --- Ensure dirs exist ---
$MKDIR_BIN -p "$SRC_DIR" "$DEST_DIR"

# --- Do a lightweight “backup” every minute ---
TS="$($DATE_BIN +%Y%m%d-%H%M)"
ARCHIVE="${DEST_DIR}/labdata-${TS}.tar.gz"

# If SRC_DIR empty, create a sample file to show activity
if ! $TEST_BIN -e "${SRC_DIR}/README.txt"; then
  $ECHO_BIN "Sample file created at $TS" > "${SRC_DIR}/README.txt"
fi

# Make a tiny rolling backup (to avoid disk growth, keep last 5)
$TAR_BIN -czf "$ARCHIVE" -C "$SRC_DIR" .
$ECHO_BIN "[$TS] backup created: $ARCHIVE" >> "$LOG_FILE"

# Keep only the 5 most recent archives
ls -1t "${DEST_DIR}"/labdata-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f


