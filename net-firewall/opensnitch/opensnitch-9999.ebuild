# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 git-r3 linux-info systemd xdg-utils

DESCRIPTION="GNU/Linux interactive application firewall inspired by Little Snitch"
HOMEPAGE="https://github.com/evilsocket/opensnitch"

# Live git checkout: clone full repo to ${WORKDIR}/${P},
# but S points to ui/ so distutils-r1 finds setup.py
EGIT_REPO_URI="https://github.com/evilsocket/opensnitch.git"
EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"
S="${WORKDIR}/${P}/ui"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
PROPERTIES="live"

IUSE="+audit bpf +iptables +nftables systemd"
REQUIRED_USE="|| ( iptables nftables )"

# daemon (Go) - links via cgo against libnetfilter_queue
DEPEND="
	net-libs/libnetfilter_queue
"
RDEPEND="
	${DEPEND}
	dev-python/pyqt6[gui,network,sql,widgets,${PYTHON_USEDEP}]
	dev-python/protobuf[${PYTHON_USEDEP}]
	dev-python/grpcio[${PYTHON_USEDEP}]
	dev-python/python-slugify[${PYTHON_USEDEP}]
	dev-python/pyinotify[${PYTHON_USEDEP}]
	dev-python/notify2[${PYTHON_USEDEP}]
"
# Go proto generation needs protoc + plugins; translations need qttools
BDEPEND="
	>=dev-lang/go-1.23
	virtual/pkgconfig
	dev-libs/protobuf
	dev-go/protobuf-go
	dev-go/protoc-gen-go-grpc
	dev-qt/qttools:6
"

RESTRICT="network-sandbox test"

pkg_setup() {
	# https://github.com/evilsocket/opensnitch/discussions/978
	local CONFIG_CHECK="~INET_TCP_DIAG ~INET_UDP_DIAG ~INET_RAW_DIAG
		~INET_DIAG_DESTROY ~NETFILTER_NETLINK_ACCT ~NETFILTER_NETLINK_QUEUE
		~NF_CONNTRACK ~NF_CT_NETLINK ~PROC_FS"

	use audit && CONFIG_CHECK+=" ~AUDIT"
	use iptables && CONFIG_CHECK+=" ~NETFILTER_XT_MATCH_CONNTRACK ~NETFILTER_XT_TARGET_NFQUEUE"
	use nftables && CONFIG_CHECK+=" ~NFT_CT ~NFT_QUEUE"
	use bpf && CONFIG_CHECK+=" ~BPF ~BPF_SYSCALL ~XDP_SOCKETS"

	linux-info_pkg_setup
}

src_prepare() {
	# Strip the tests/ dir — setuptools would otherwise install it as a stray
	# top-level package into site-packages, tripping distutils-r1's QA check.
	rm -rf "${S}/tests" || die "failed to remove tests"

	# Fix setup.py data_files: absolute /usr/share paths break sandbox install
	sed -i \
		-e "s|('/usr/share/applications'|('share/applications'|" \
		-e "s|('/usr/share/kservices5'|('share/kservices5'|" \
		-e "s|('/usr/share/icons/hicolor/scalable/apps'|('share/icons/hicolor/scalable/apps'|" \
		-e "s|('/usr/share/icons/hicolor/48x48/apps'|('share/icons/hicolor/48x48/apps'|" \
		-e "s|('/usr/share/icons/hicolor/64x64/apps'|('share/icons/hicolor/64x64/apps'|" \
		-e "s|('/usr/share/metainfo'|('share/metainfo'|" \
		"${S}/setup.py" || die "failed to patch setup.py paths"

	# Workaround namespace conflict in generated python grpc stubs
	# https://github.com/evilsocket/opensnitch/issues/496
	sed -i 's/^import ui_pb2/from . import ui_pb2/' \
		"${S}/opensnitch/proto/ui_pb2_grpc.py" || die "failed to fix proto import"

	# Fix daemon binary path in systemd unit (upstream uses /usr/local/bin)
	sed -i 's|/usr/local/bin/opensnitchd|/usr/bin/opensnitchd|g' \
		"${EGIT_CHECKOUT_DIR}/daemon/data/init/opensnitchd.service" \
		|| die "failed to patch systemd unit"

	# Compile i18n translations (.ts -> .qm) before python_copy_sources copies them.
	# .ts files ship in the repo; we only need lrelease, not pylupdate6 (which is
	# flaky under parallel make and can exit non-zero on some locales).
	cd "${S}/i18n" || die
	./generate_i18n.sh || die "lrelease translation build failed"
	# Copy compiled .qm files into the package tree (same as Makefile does)
	for lang in locales/*/ ; do
		lang="${lang%/}"
		mkdir -p "${S}/opensnitch/i18n/${lang#locales/}" || die
		cp "${lang}/opensnitch-${lang#locales/}.qm" \
			"${S}/opensnitch/i18n/${lang#locales/}/" || die
	done
	cd "${S}" || die

	default
}

src_compile() {
	# 1. Generate Go protobuf bindings (not committed in repo, only .gitkeep)
	cd "${EGIT_CHECKOUT_DIR}/proto" || die
	protoc -I. ui.proto \
		--go_out=../daemon/ui/protocol/ \
		--go-grpc_out=../daemon/ui/protocol/ \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative || die "protoc (Go) failed"

	# 2. Build Go daemon (downloads Go modules from network - needs network-sandbox lift)
	cd "${EGIT_CHECKOUT_DIR}/daemon" || die
	export GOCACHE="${T}/go-cache"
	export GOMODCACHE="${T}/go-mod"
	export GOFLAGS="-mod=mod"
	export CGO_ENABLED=1

	# protoc-gen-go-grpc on the system is newer than what go.mod pins (v1.32.0),
	# so the generated grpc stubs reference APIs not in the old version.
	# Upgrade grpc + protobuf + genproto to match the installed protoc plugins.
	go get google.golang.org/grpc@latest \
		google.golang.org/protobuf@latest \
		google.golang.org/genproto@latest || die "go get failed"

	# -buildvcs=false: git-r3 clone has dubious ownership in the sandbox
	go build -v -buildmode=pie -buildvcs=false -o opensnitchd . \
		|| die "go build failed"

	# 3. Build Python UI (per-implementation, in copied build dirs)
	cd "${S}" || die
	distutils-r1_src_compile
}

src_install() {
	# --- daemon ---
	local daemon_dir="${EGIT_CHECKOUT_DIR}/daemon"
	dobin "${daemon_dir}/opensnitchd"

	keepdir /etc/opensnitchd/rules
	keepdir /etc/opensnitchd/tasks

	insinto /etc/opensnitchd
	doins "${daemon_dir}/data/default-config.json"
	doins "${daemon_dir}/data/network_aliases.json"
	doins "${daemon_dir}/data/system-fw.json"

	insinto /etc/opensnitchd/rules
	doins "${daemon_dir}/data/rules/"*.json

	insinto /etc/opensnitchd/tasks
	doins "${daemon_dir}/data/tasks/tasks.json"

	# --- init scripts ---
	if use systemd; then
		systemd_dounit "${daemon_dir}/data/init/opensnitchd.service"
	else
		newinitd "${FILESDIR}/opensnitchd.initd" opensnitchd
	fi

	# --- Python UI ---
	cd "${S}" || die
	distutils-r1_src_install
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update

	ewarn "The OpenSnitch firewall will NOT work until the daemon service is started."
	ewarn "Without the running daemon, network traffic is NOT filtered."
	elog ""
	elog "Enable and start the daemon service:"
	if use systemd; then
		elog "  sudo systemctl enable --now opensnitchd.service"
	else
		elog "  sudo rc-update add opensnitchd default"
		elog "  sudo rc-service opensnitchd start"
	fi
	elog ""
	elog "The GUI (opensnitch-ui) should be started from your user session"
	elog "(desktop autostart entry or manually: opensnitch-ui)."
	elog "It connects to the daemon via a unix socket."
	elog ""
	elog "Note: qt-material (optional theme) is not in Gentoo repos."
	elog "  Install via pip if you want material themes: pip install qt-material"
}