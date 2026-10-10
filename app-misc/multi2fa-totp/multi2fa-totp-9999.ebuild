# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature xdg

MY_PN="Multi2FA-TOTP"

DESCRIPTION="Encrypted TOTP/HOTP two-factor authenticator with a GUI and a CLI"
HOMEPAGE="https://github.com/keklick1337/Multi2FA-TOTP"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/keklick1337/${MY_PN}.git"
	PROPERTIES="live"
else
	SRC_URI="https://github.com/keklick1337/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${MY_PN}-${PV}"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="MIT"
# Statically linked Go dependencies
LICENSE+=" Apache-2.0 BSD BSD-2 MIT ZLIB"
SLOT="0"
IUSE="+gui"

# Go modules are downloaded during the build.
RESTRICT="network-sandbox"

DEPEND="
	gui? (
		dev-libs/wayland
		media-libs/libglvnd[X]
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXxf86vm
		x11-libs/libxkbcommon
	)
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-lang/go-1.26.0
	gui? (
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
		virtual/pkgconfig
	)
"

DOCS=( README.md CHANGELOG.md docs/cli.md )

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	else
		default
	fi
}

src_prepare() {
	default
	# The shipped entry starts the binary next to the .desktop file; system installs use PATH.
	sed -i 's|^Exec=.*|Exec=multi2fa %f|' packaging/linux/io.github.keklick1337.multi2fa.desktop || die
}

src_configure() {
	export GOFLAGS="-buildvcs=false -trimpath -modcacherw"
	export GOMODCACHE="${T}/go-mod" GOCACHE="${T}/go-cache"
	export CGO_CFLAGS="${CFLAGS}" CGO_CXXFLAGS="${CXXFLAGS}" CGO_LDFLAGS="${LDFLAGS}"
}

src_compile() {
	# The version comes from the VERSION file embedded at build time.
	CGO_ENABLED=0 go build -o multi2fa-cli ./cmd/multi2fa-cli || die
	if use gui; then
		CGO_ENABLED=1 go build -o multi2fa ./cmd/multi2fa || die
	fi
}

src_test() {
	local pkgs=( ./internal/otp/... ./internal/vault/... ./internal/i18n/... ./cmd/multi2fa-cli/... )
	use gui && pkgs+=( ./internal/... )
	go test "${pkgs[@]}" || die
}

src_install() {
	dobin multi2fa-cli
	if use gui; then
		dobin multi2fa

		local size
		for size in 16 24 32 48 64 128 256 512; do
			newicon -s ${size} assets/hicolor/${size}x${size}/apps/multi2fa.png multi2fa.png
		done
		domenu packaging/linux/io.github.keklick1337.multi2fa.desktop
		insinto /usr/share/metainfo
		doins packaging/linux/io.github.keklick1337.multi2fa.metainfo.xml
		insinto /usr/share/mime/packages
		doins packaging/linux/io.github.keklick1337.multi2fa.xml
	fi

	einstalldocs
}

pkg_postinst() {
	if use gui; then
		xdg_pkg_postinst
		optfeature "scanning QR codes with a camera" media-video/ffmpeg
	fi
	optfeature "copying codes with multi2fa-cli -copy" gui-apps/wl-clipboard x11-misc/xclip x11-misc/xsel
}

pkg_postrm() {
	use gui && xdg_pkg_postrm
}
