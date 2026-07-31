#!/usr/bin/env bash
set -euo pipefail

# Removes leftover Google Drive migration safeguards/symlinks that were used while
# moving data from thor.schott to Atender3. The script is intentionally
# conservative: it only touches paths that explicitly match the migration labels.

PATTERN='(thor\.schott|Atender3|google.?drive|rclone|cloud.?migration|drive.?guard|cloud.?guard)'

remove_matching_file() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    echo "Removing $path"
    rm -f -- "$path"
  fi
}

stop_disable_matching_services() {
  local scope="$1"
  local systemctl_args=()
  if [[ "$scope" == "user" ]]; then
    systemctl_args=(--user)
  fi

  if ! command -v systemctl >/dev/null 2>&1; then
    return 0
  fi

  mapfile -t units < <(systemctl "${systemctl_args[@]}" list-unit-files --type=service --no-legend --no-pager 2>/dev/null \
    | awk '{print $1}' \
    | grep -Ei "$PATTERN" || true)

  for unit in "${units[@]}"; do
    echo "Stopping/disabling ${scope} service $unit"
    systemctl "${systemctl_args[@]}" stop "$unit" 2>/dev/null || true
    systemctl "${systemctl_args[@]}" disable "$unit" 2>/dev/null || true
    systemctl "${systemctl_args[@]}" reset-failed "$unit" 2>/dev/null || true
  done
}

remove_matching_service_files() {
  local dir
  for dir in \
    /etc/systemd/system \
    /usr/local/lib/systemd/system \
    "$HOME/.config/systemd/user"; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r -d '' file; do
      if [[ "$(basename "$file")" =~ $PATTERN ]] || grep -Eiq "$PATTERN" "$file"; then
        remove_matching_file "$file"
      fi
    done < <(find "$dir" -maxdepth 1 \( -type f -o -type l \) -name '*.service' -print0)
  done
}

remove_matching_symlinks() {
  local root
  for root in "$PWD" "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/GoogleDrive" "$HOME/Google Drive" "$HOME/Drive"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r -d '' link; do
      local target
      target="$(readlink -- "$link" || true)"
      if [[ "$link" =~ $PATTERN || "$target" =~ $PATTERN ]]; then
        remove_matching_file "$link"
      fi
    done < <(find "$root" -xdev -type l -print0 2>/dev/null)
  done
}

stop_disable_matching_services system
stop_disable_matching_services user
remove_matching_service_files
remove_matching_symlinks

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload 2>/dev/null || true
  systemctl --user daemon-reload 2>/dev/null || true
fi

echo "Cloud migration cleanup finished."
