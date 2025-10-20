# Copyright 2024 Vladislav Tislenko (aka keklick1337)
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit unpacker xdg desktop

DESCRIPTION="Dolphin Anty - multi-account antidetect browser (binary from .deb)"
HOMEPAGE="https://dolphin-anty.com"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror strip fetch"   # Binary package, no mirroring; manual fetch to always get latest
PROPERTIES="live"               # Always fetches latest version

# CDN URL for latest version - always updated, so manual download required
SRC_URI="https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb -> dolphin-anty-${PV}.deb"

S="${WORKDIR}"

# Basic runtime dependencies for Electron binary
RDEPEND="
  dev-libs/glib:2
  dev-libs/nss
  media-libs/alsa-lib
  net-print/cups
  x11-libs/libX11
  x11-libs/libXext
  x11-libs/libXrender
  x11-libs/libXtst
  x11-libs/libXrandr
  x11-libs/libxcb
  x11-libs/libxkbcommon
  x11-libs/libXdamage
  x11-libs/libXfixes
  x11-libs/libXcomposite
  x11-libs/libXi
  x11-misc/xdg-utils
"

QA_PREBUILT="*"

pkg_nofetch() {
  einfo "This is a live package that always fetches the latest version from the vendor."
  einfo ""
  einfo "Please download the latest .deb file manually:"
  einfo "  wget -O '${DISTDIR}/${A}' \\"
  einfo "    'https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb'"
  einfo ""
  einfo "Then update the Manifest:"
  einfo "  cd '${EBUILD%/*}' && ebuild '${EBUILD##*/}' manifest"
  einfo ""
  einfo "Finally, re-run emerge."
}

src_unpack() {
  unpack "${A}"
  # Unpack the data.tar.xz from the .deb package
  cd "${S}" || die
  unpack ./data.tar.xz
}

src_install() {
  cd "${S}" || die

  # 1) Deploy .deb contents as-is (preserving executable bits)
  if [[ -d opt ]]; then
    dodir /opt
    cp -a "opt/"* "${D}/opt/" || die
  fi

  # 2) Set executable permission and create symlink to main binary
  fperms +x "/opt/Dolphin Anty/dolphin_anty"
  fperms +x "/opt/Dolphin Anty/chrome-sandbox"
  dosym "/opt/Dolphin Anty/dolphin_anty" /usr/bin/dolphin-anty

  # 3) .desktop from package: install and adjust Exec/TryExec/Icon paths
  if [[ -f usr/share/applications/dolphin_anty.desktop ]]; then
    insinto /usr/share/applications
    doins usr/share/applications/dolphin_anty.desktop
    sed -i \
      -e 's|^Exec=.*|Exec=dolphin-anty %U|g' \
      -e 's|^TryExec=.*|TryExec=dolphin-anty|g' \
      -e 's|^Icon=.*|Icon=dolphin_anty|g' \
      "${ED}/usr/share/applications/dolphin_anty.desktop" || die
  else
    # fallback if .desktop is not included
    cat > "${T}/dolphin-anty.desktop" <<'EOF'
[Desktop Entry]
Name=Dolphin Anty
Comment=Multi-account antidetect browser
Exec=dolphin-anty %U
Icon=dolphin_anty
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF
    domenu "${T}/dolphin-anty.desktop"
  fi

  if [[ -d usr/share/icons ]]; then
    insinto /usr/share/icons
    doins -r usr/share/icons/*
  fi

  # 5) Documentation - changelog is already compressed, so exclude from docompress
  if [[ -d usr/share/doc/dolphin-anty ]]; then
    docompress -x /usr/share/doc/${PF}
    dodoc usr/share/doc/dolphin-anty/changelog.gz 2>/dev/null || true
  fi
}

pkg_postinst() {
  xdg_desktop_database_update
  xdg_icon_cache_update
  einfo "Installed in /opt/Dolphin Anty; launch with: dolphin-anty"
  einfo ""
  einfo "This is a live package (9999). To update to the latest version:"
  einfo "  1. Download: wget -O /var/cache/distfiles/dolphin-anty-9999.deb \\"
  einfo "       'https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb'"
  einfo "  2. Update Manifest: cd ${EROOT}/var/db/repos/kek-overlay/www-client/dolphin-anty"
  einfo "       && ebuild dolphin-anty-9999.ebuild manifest"
  einfo "  3. Re-emerge: emerge www-client/dolphin-anty"
}

pkg_postrm() {
  xdg_desktop_database_update
  xdg_icon_cache_update
}
