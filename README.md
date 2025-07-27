# mac-automation

This repository contains a simple macOS maintenance script called `mac_cleanup.sh`.
The script helps clean caches, remove old log files, detect duplicate files, optionally
run a malware scan using ClamAV, and perform other routine tasks.

## Usage
```
./mac_cleanup.sh [options]
```

Run `./mac_cleanup.sh --help` to see all available options. Some actions may
require `sudo` privileges.

## Disclaimer
The script is provided as-is and does not replicate all features of commercial
products like CleanMyMac. Review the code and ensure you understand its actions
before running it on your system.
