# Copyright 2024 Vladislav Tislenko (aka keklick1337)
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit unpacker xdg desktop

DESCRIPTION="Donut Browser - open source anti-detect browser (prebuilt binary)"
HOMEPAGE="https://donutbrowser.com https://github.com/zhom/donutbrowser"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror strip"

SRC_URI="
	amd64? ( https://github.com/zhom/donutbrowser/releases/download/v${PV}/Donut_${PV}_amd64.deb -> ${P}-amd64.deb )
	arm64? ( https://github.com/zhom/donutbrowser/releases/download/v${PV}/Donut_${PV}_arm64.deb -> ${P}-arm64.deb )
"

S="${WORKDIR}"

# Tauri-based browser: needs webkit2gtk-4.1, gtk3, libsoup-3, xdotool (libxdo) at runtime
RDEPEND="
	dev-libs/glib:2
	dev-libs/openssl:0/3
	net-libs/webkit-gtk:4.1
	net-libs/libsoup:3.0
	sys-apps/dbus
	x11-libs/gtk+:3
	x11-libs/cairo
	x11-libs/pango
	x11-libs/gdk-pixbuf:2
	<x11-misc/xdotool-4
	x11-misc/xdg-utils
"

QA_PREBUILT="*"

pkg_pretend() {
	ewarn ""
	ewarn "Donut Browser is a prebuilt binary based on webkit2gtk-4.1."
	ewarn "Under Wayland, the DMA-BUF renderer in webkit2gtk can crash with:"
	ewarn "  Gdk-Message: Error 71 (Protocol error) dispatching to Wayland display"
	ewarn ""
	ewarn "Workarounds (the .desktop entry already applies the first one):"
	ewarn "  WEBKIT_DISABLE_DMABUF_RENDERER=1 donutbrowser   # recommended"
	ewarn "  GDK_BACKEND=x11 donutbrowser                   # XWayland fallback"
	ewarn "  Note: GDK_BACKEND=x11 may render the app as a black screen"
	ewarn "  on some setups; prefer WEBKIT_DISABLE_DMABUF_RENDERER=1."
	ewarn ""
}

src_install() {
	cd "${S}" || die

	# Binaries: donutbrowser, donut-proxy, donut-daemon
	if [[ -d usr/bin ]]; then
		exeinto /usr/bin
		doexe usr/bin/donutbrowser
		doexe usr/bin/donut-proxy
		doexe usr/bin/donut-daemon
	fi

	# .desktop file - install with WEBKIT_DISABLE_DMABUF_RENDERER=1 wrapper
	# to work around webkit2gtk Wayland DMA-BUF renderer protocol errors
	# (Gdk-Message: Error 71 (Protocol error) dispatching to Wayland display).
	if [[ -f usr/share/applications/Donut.desktop ]]; then
		sed -i \
			-e 's|^Exec=donutbrowser|Exec=env WEBKIT_DISABLE_DMABUF_RENDERER=1 donutbrowser|' \
			usr/share/applications/Donut.desktop || die
		insinto /usr/share/applications
		doins usr/share/applications/Donut.desktop
	fi

	# Icons
	if [[ -d usr/share/icons ]]; then
		insinto /usr/share/icons
		doins -r usr/share/icons/.
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	einfo "Donut Browser installed. Launch with: donutbrowser"
	einfo "Homepage: https://donutbrowser.com"
	elog ""
	elog "Wayland note:"
	elog "  webkit2gtk's DMA-BUF renderer can crash with"
	elog "  'Gdk-Message: Error 71 (Protocol error) dispatching to Wayland display'."
	elog "  The bundled .desktop entry already starts donutbrowser with"
	elog "  WEBKIT_DISABLE_DMABUF_RENDERER=1 as a workaround."
	elog ""
	elog "  When launching from a terminal under Wayland, run:"
	elog "    WEBKIT_DISABLE_DMABUF_RENDERER=1 donutbrowser"
	elog ""
	elog "  GDK_BACKEND=x11 donutbrowser also forces XWayland, but on some"
	elog "  setups it produces a black/blank application window - prefer"
	elog "  the WEBKIT_DISABLE_DMABUF_RENDERER=1 workaround."
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}
