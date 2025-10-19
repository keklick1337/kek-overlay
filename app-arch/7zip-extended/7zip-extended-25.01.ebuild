# Copyright 2025 Vladislav Tislenko (keklick1337)
# Distributed under the terms of the GNU General Public License v2
EAPI=8

COMMIT="0426ac8d58695d9a00ce85cf2ea734d333fcb495"

inherit edos2unix flag-o-matic toolchain-funcs

DESCRIPTION="A Patched Version of 7-Zip for Improved Mask Handling"
HOMEPAGE="https://github.com/keklick1337/7zip-extended https://www.7-zip.org/ https://sourceforge.net/projects/sevenzip/"

SRC_URI="https://github.com/keklick1337/7zip-extended/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT}.tar.gz"

S="${WORKDIR}/7zip-extended-${COMMIT}"

LICENSE="LGPL-2 BSD rar? ( unRAR )"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="uasm jwasm +rar +symlink"
REQUIRED_USE="?? ( uasm jwasm )"

DOCS=( README.md )
HTML_DOCS=( )

BDEPEND="
	app-arch/xz-utils[extra-filters(+)]
	uasm? ( dev-lang/uasm )
	jwasm? ( dev-lang/jwasm )
"
RDEPEND="
	symlink? ( !app-arch/p7zip )
"

PATCHES=( )

pkg_setup() {
	mfile="cmpl"
	if tc-is-clang; then
		mfile="${mfile}_clang"
		bdir=c
	elif tc-is-gcc; then
		mfile="${mfile}_gcc"
		bdir=g
	else
		die "Unsupported compiler: $(tc-getCC)"
	fi
	if use jwasm || use uasm ; then
		mfile="${mfile}_x64"
		bdir="${bdir}_x64"
	fi
	export mfile="${mfile}.mak"
	export bdir
}

src_prepare() {
	pushd "./CPP/7zip" || die "Unable to switch directory"
	edos2unix ./7zip_gcc.mak ./var_gcc{,_x64}.mak ./var_clang{,_x64}.mak
	sed -i -e 's/-Werror //g' ./7zip_gcc.mak || die "Error removing -Werror"
	popd >/dev/null || die "Unable to switch directory"

	default
}

src_compile() {
	pushd "./CPP/7zip/Bundles/Alone2" || die "Unable to switch directory"

	append-ldflags -Wl,-z,noexecstack
	export G_CFLAGS=${CFLAGS}
	export G_CXXFLAGS=${CXXFLAGS}
	export G_LDFLAGS=${LDFLAGS}

	local args=(
		-f "../../${mfile}"
		CC=$(tc-getCC)
		CXX=$(tc-getCXX)
	)

	if ! use rar; then
		args+=( DISABLE_RAR_COMPRESS=1 )
	fi
	if use jwasm; then
		args+=( USE_JWASM=1 )
	elif use uasm; then
		args+=( MY_ASM=uasm )
	fi

	mkdir -p "${bdir}" || die  # Bug: https://bugs.gentoo.org/933619
	emake ${args[@]}
	popd > /dev/null || die "Unable to switch directory"
}

src_install() {
	dobin "./CPP/7zip/Bundles/Alone2/b/${bdir}/7zz"
	if use symlink; then
		dosym 7zz /usr/bin/7z
		dosym 7zz /usr/bin/7za
		dosym 7zz /usr/bin/7zr
	fi
	einstalldocs
}
