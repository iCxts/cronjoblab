#!/usr/bin/env bash
# setup.sh — Cronjob Abuse Lab (Safe, Bash-only)
# Purpose: demonstrate cron misconfiguration via a harmless local payload.
# Run this in a disposable VM you control.
set -euo pipefail

# ---------- config ----------
LAB_DIR="/opt/cronlab"
CRON_FILE="/etc/cron.d/cronlab"
LOG_FILE="/var/log/cronlab.log"
STUDENTS_GROUP="students"
DEFAULT_STUDENT_USER="student"   # if present, will be added to the group
SHELL_BIN="/bin/bash"
# ----------------------------

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "[!] Please run as root: sudo bash setup.sh" >&2
    exit 1
  fi
}

need_bin() {
  command -v "$1" >/dev/null 2>&1 || { echo "[!] Missing dependency: $1" >&2; exit 1; }
}

restart_cron() {
  if command -v systemctl >/dev/null 2>&1; then
    systemctl restart cron 2>/dev/null || systemctl restart crond 2>/dev/null || true
  else
    service cron restart 2>/dev/null || service crond restart 2>/dev/null || true
  fi
}

write_task_sh() {
  cat > "${LAB_DIR}/task.sh" <<'BASH_EOF'
#!/usr/bin/env bash
# Cronjob Abuse Lab — Safe Task (Bash)
# Intentionally group-writable to simulate a misconfiguration.
# Students may modify ONLY the marked block to produce harmless, local effects.

set -euo pipefail

PROOF_FILE="/tmp/cronlab_proof.txt"
MARKERS_LOG="/tmp/cronlab_markers.log"

log_line() {
  printf "%s | %s\n" "$(date -u +%FT%TZ)" "$*" >> "$MARKERS_LOG"
}

write_proof() {
  local ts uid cwd path
  ts="$(date -u +%FT%TZ)"
  uid="$(id -u)"
  cwd="$(pwd)"
  path="${PATH:-<unset>}"
  printf "time=%s uid=%s cwd=%s PATH=%s\n" "$ts" "$uid" "$cwd" "$path" >> "$PROOF_FILE"
}

# === student area start ===
# Example harmless action students can edit/extend:
name="${USER:-student}"
marker="/tmp/pwned-${name}.txt"
printf "owned-by=%s at %s\n" "$name" "$(date -u +%FT%TZ)" >> "$marker"
# === student area end ===

main() {
  write_proof
  log_line "task.sh executed successfully"
}
main "$@"
BASH_EOF

  chmod 0664 "${LAB_DIR}/task.sh"   # intentional misconfig: group-writable
  chown root:"${STUDENTS_GROUP}" "${LAB_DIR}/task.sh"
}

install_cron() {
  cat > "${CRON_FILE}" <<EOF
# ${CRON_FILE} — runs a safe, demonstrative task every minute
* * * * * root ${SHELL_BIN} ${LAB_DIR}/task.sh >> ${LOG_FILE} 2>&1
EOF
  chmod 0644 "${CRON_FILE}"
}

main() {
  need_root
  need_bin "${SHELL_BIN}"
  need_bin crontab

  # Ensure students group
  if ! getent group "${STUDENTS_GROUP}" >/dev/null; then
    groupadd "${STUDENTS_GROUP}"
    echo "[+] Created group: ${STUDENTS_GROUP}"
  fi

  # Optionally add a default 'student' user to the group if it exists
  if id -u "${DEFAULT_STUDENT_USER}" >/dev/null 2>&1; then
    usermod -aG "${STUDENTS_GROUP}" "${DEFAULT_STUDENT_USER}"
    echo "[+] Added '${DEFAULT_STUDENT_USER}' to ${STUDENTS_GROUP}"
  fi

  # Prepare lab dir (root-owned, group students; dir group-writable - intentional)
  mkdir -p "${LAB_DIR}"
  chown root:"${STUDENTS_GROUP}" "${LAB_DIR}"
  chmod 0775 "${LAB_DIR}"  # intentional misconfig: group can write into dir

  # Install task.sh (group-writable - intentional)
  write_task_sh

  # Prepare log
  : > "${LOG_FILE}"
  chmod 0644 "${LOG_FILE}"

  # Install cron definition
  install_cron

  # Restart cron to pick up /etc/cron.d changes
  restart_cron

  echo
  echo "[+] Setup complete."
  echo "[i] Cron now runs: ${SHELL_BIN} ${LAB_DIR}/task.sh every minute (as root)."
  echo "[i] Tail logs: sudo tail -f ${LOG_FILE}"
  echo "[i] Students can edit: ${LAB_DIR}/task.sh (group '${STUDENTS_GROUP}')"
  echo "[i] Proof files: /tmp/cronlab_proof.txt, /tmp/pwned-<user>.txt, /tmp/cronlab_markers.log"
  echo
  echo "[!] Post-lab hardening (for debrief):"
  echo "    chown -R root:root ${LAB_DIR} && chmod 0755 ${LAB_DIR} && chmod 0644 ${LAB_DIR}/task.sh"
  echo "    # or migrate to a systemd timer with a restricted service account."
}

main "$@"
