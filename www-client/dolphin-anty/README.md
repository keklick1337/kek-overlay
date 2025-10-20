# Dolphin Anty - Live Package

This is a live ebuild (9999) that always tracks the latest version from the vendor's CDN.

## Installation

Since this package always fetches the latest binary, you need to manually download and update the Manifest:

```bash
# 1. Download the latest .deb file
cd /var/cache/distfiles
sudo wget -O dolphin-anty-9999.deb \
  'https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb'

# 2. Update the Manifest
cd /var/db/repos/kek-overlay/www-client/dolphin-anty
sudo ebuild dolphin-anty-9999.ebuild manifest

# 3. Install the package
sudo emerge www-client/dolphin-anty
```

## Updating

To update to the latest version, simply repeat the installation steps above. The `PROPERTIES="live"` flag ensures Portage knows this package always fetches the latest version.

## Notes

- The package installs to `/opt/Dolphin Anty/`
- Launch with: `dolphin-anty`
- Desktop entry is automatically created
