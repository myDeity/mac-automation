#!/bin/bash

# mac_cleanup.sh - simple macOS maintenance script
# Clears caches, removes old logs, checks for duplicate files,
# runs optional malware scan with ClamAV and cleans Homebrew.

set -e

print_usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]
Options:
  --all            Run all tasks
  --cache          Clear user and system caches
  --logs           Remove log files older than 7 days
  --duplicates DIR Scan DIR for duplicate files (based on md5)
  --malware DIR    Scan DIR recursively for malware using clamscan
  --brew           Run 'brew cleanup' if Homebrew is installed
  --update         Run softwareupdate to install all updates
  -h, --help       Show this help
USAGE
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

clear_user_cache() {
  echo "Clearing user cache..."
  rm -rf "$HOME/Library/Caches"/*
}

clear_system_cache() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "System cache requires sudo. Skipping."
    return
  fi
  echo "Clearing system cache..."
  rm -rf /Library/Caches/*
}

clear_logs() {
  echo "Removing log files older than 7 days..."
  sudo find /var/log -type f -mtime +7 -delete 2>/dev/null || true
}

find_duplicates() {
  local search_dir="$1"
  if [ -z "$search_dir" ]; then
    echo "find_duplicates: directory argument required" >&2
    return 1
  fi
  echo "Scanning for duplicate files in $search_dir ..."
  declare -A seen
  while IFS= read -r -d '' file; do
    hash=$(md5 -q "$file")
    if [[ -n "${seen[$hash]}" ]]; then
      echo "Duplicate found: $file -> ${seen[$hash]}"
    else
      seen[$hash]="$file"
    fi
  done < <(find "$search_dir" -type f -print0)
}

malware_scan() {
  local scan_dir="$1"
  if ! check_command clamscan; then
    echo "clamscan not found. Install clamav first." >&2
    return 1
  fi
  echo "Running clamscan on $scan_dir ..."
  clamscan -r "$scan_dir"
}

brew_cleanup() {
  if check_command brew; then
    brew cleanup
  else
    echo "Homebrew not found. Skipping brew cleanup."
  fi
}

software_update() {
  echo "Running softwareupdate ..."
  softwareupdate -i -a
}

run_all() {
  clear_user_cache
  clear_system_cache
  clear_logs
  brew_cleanup
  software_update
}

if [ $# -eq 0 ]; then
  print_usage
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --all)
      run_all
      ;;
    --cache)
      clear_user_cache
      clear_system_cache
      ;;
    --logs)
      clear_logs
      ;;
    --duplicates)
      shift
      find_duplicates "$1"
      ;;
    --malware)
      shift
      malware_scan "$1"
      ;;
    --brew)
      brew_cleanup
      ;;
    --update)
      software_update
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
  esac
  shift
done

exit 0

