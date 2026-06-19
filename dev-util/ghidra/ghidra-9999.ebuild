# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..14} )
inherit java-pkg-2 desktop git-r3 python-single-r1

GRADLE_DEP_VER="20260606"
GRADLE_VER="8.5"
RELEASE_VERSION="12.1"

DESCRIPTION="Ghidra is a software reverse engineering (SRE) framework created and
		maintained by the National Security Agency Research Directorate. This
		framework includes a suite of full-featured, high-end software analysis
		tools that enable users to analyze compiled code on a variety of platforms
		simply and efficiently."
HOMEPAGE="https://github.com/NationalSecurityAgency/ghidra"

# Live git source; external deps still fetched as tarballs
EGIT_REPO_URI="https://github.com/NationalSecurityAgency/ghidra.git"
EGIT_CHECKOUT_DIR="${WORKDIR}/ghidra-Ghidra_${PV}_build"
S="${EGIT_CHECKOUT_DIR}"

FIDB_FILES="vs2012_x86.fidb vs2012_x64.fidb vs2015_x86.fidb vs2015_x64.fidb \
	vs2017_x86.fidb vs2017_x64.fidb vs2019_x86.fidb vs2019_x64.fidb vsOlder_x86.fidb vsOlder_x64.fidb"

SRC_URI="https://dev.pentoo.ch/~blshkv/distfiles/${PN}-dependencies-${GRADLE_DEP_VER}.tar.gz
	https://github.com/pxb1988/dex2jar/releases/download/v2.4/dex-tools-v2.4.zip
	https://github.com/digitalsleuth/AXMLPrinter2/raw/691036a3caf84950fbb0df6f1fa98d7eaa92f2a0/AXMLPrinter2.jar
	https://github.com/unsound/hfsexplorer/releases/download/hfsexplorer-0.21/hfsexplorer-0_21-bin.zip
	https://downloads.sourceforge.net/yajsw/yajsw/yajsw-stable-13.12.zip
	https://ftp.postgresql.org/pub/source/v15.10/postgresql-15.10.tar.gz
	https://archive.eclipse.org/tools/cdt/releases/8.6/cdt-8.6.0.zip
	https://sourceforge.net/projects/pydev/files/pydev/PyDev%209.3.0/PyDev%209.3.0.zip -> PyDev-9.3.0.zip
	https://github.com/NationalSecurityAgency/ghidra-data/raw/Ghidra_${RELEASE_VERSION}/lib/java-sarif-2.1-modified.jar
"
for FIDB in ${FIDB_FILES}; do
	SRC_URI+=" https://github.com/NationalSecurityAgency/ghidra-data/raw/Ghidra_${RELEASE_VERSION}/FunctionID/${FIDB}"
done

SRC_URI+=" https://files.pythonhosted.org/packages/8d/14/619e24a4c70df2901e1f4dbc50a6291eb63a759172558df326347dce1f0d/protobuf-3.20.3-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/90/c7/6dc0a455d111f68ee43f27793971cf03fe29b6ef972042549db29eec39a2/psutil-5.9.8.tar.gz
	https://files.pythonhosted.org/packages/c7/42/be1c7bbdd83e1bfb160c94b9cafd8e25efc7400346cf7ccdbdb452c467fa/setuptools-68.0.0-py3-none-any.whl
	https://files.pythonhosted.org/packages/27/d6/003e593296a85fd6ed616ed962795b2f87709c3eee2bca4f6d0fe55c6d00/wheel-0.37.1-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/ce/78/91db67e7fe1546dc8b02c38591b7732980373d2d252372f7358054031dd4/Pybag-2.2.12-py3-none-any.whl
	https://files.pythonhosted.org/packages/d0/dd/b28df50316ca193dd1275a4c47115a720796d9e1501c1888c4bfa5dc2260/capstone-5.0.1-py3-none-win_amd64.whl
	https://files.pythonhosted.org/packages/50/8f/518a37381e55a8857a638afa86143efa5508434613541402d20611a1b322/comtypes-1.4.1-py3-none-any.whl
	https://files.pythonhosted.org/packages/83/1c/25b79fc3ec99b19b0a0730cc47356f7e2959863bf9f3cd314332bddb4f68/pywin32-306-cp312-cp312-win_amd64.whl"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
PROPERTIES="live"

REQUIRED_USE=${PYTHON_REQUIRED_USE}

RDEPEND="
	>=virtual/jre-21:*
	${PYTHON_DEPS}
"
DEPEND="${RDEPEND}
	>=virtual/jdk-21:*
	sys-devel/bison
	dev-java/jflex
	app-arch/unzip
"
BDEPEND="
	>=dev-java/gradle-bin-${GRADLE_VER}:*
	dev-python/pip
"

check_gradle_binary() {
	local gradle_link_target=$(readlink -n /usr/bin/gradle)
	local currentver="${gradle_link_target/gradle-bin-/}"
	local requiredver="${GRADLE_VER}"

	einfo "Gradle version ${currentver} currently set."
	if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
		einfo "Gradle version ${currentver} is >= ${requiredver}, proceeding with build..."
	else
		eerror "Gradle version ${requiredver} or higher must be eselected before building ${PN}."
		die "Please run 'eselect gradle set gradle-bin-XX' when XX >= ${requiredver}"
	fi
}

pkg_setup() {
	java-pkg-2_pkg_setup
	python-single-r1_pkg_setup
}

src_unpack() {
	git-r3_src_unpack

	# Unpack the external dependencies tarball (not in the git repo)
	cd "${WORKDIR}" || die
	tar xzf "${DISTDIR}/${PN}-dependencies-${GRADLE_DEP_VER}.tar.gz" || die "unpack deps failed"

	mkdir -p "${S}/.gradle/flatRepo" || die "mkdir failed"
	cd "${S}/.gradle" || die

	unpack dex-tools-v2.4.zip
	cp dex-tools-v2.4/lib/dex-*.jar ./flatRepo || die "cp dex jar failed"

	cp "${DISTDIR}/AXMLPrinter2.jar" ./flatRepo || die "cp AXMLPrinter failed"
	cp "${DISTDIR}/java-sarif-2.1-modified.jar" ./flatRepo || die "cp sarif failed"

	unpack hfsexplorer-0_21-bin.zip
	cp lib/*.jar ./flatRepo || die "cp hfsexplorer failed"

	mkdir -p "${WORKDIR}/ghidra.bin/Ghidra/Features/GhidraServer/" || die "mkdir server failed"
	cp "${DISTDIR}/yajsw-stable-13.12.zip" "${WORKDIR}/ghidra.bin/Ghidra/Features/GhidraServer/" || die "cp yajsw failed"

	local plugin_dep_path="ghidra.bin/GhidraBuild/EclipsePlugins/GhidraDev/buildDependencies"
	mkdir -p "${WORKDIR}/${plugin_dep_path}/" || die "mkdir plugin deps failed"
	cp "${DISTDIR}/PyDev-9.3.0.zip" "${WORKDIR}/${plugin_dep_path}/PyDev 9.3.0.zip" || die "cp PyDev failed"
	cp "${DISTDIR}/cdt-8.6.0.zip" "${WORKDIR}/${plugin_dep_path}/" || die "cp cdt failed"
	cp "${DISTDIR}/postgresql-15.10.tar.gz" "${WORKDIR}/${plugin_dep_path}/" || die "cp postgresql failed"

	cd "${S}" || die
	mv ../dependencies . || die "mv dependencies failed"

	mkdir ./dependencies/fidb || die "mkdir fidb failed"
	local fidb
	for fidb in ${FIDB_FILES}; do
		cp "${DISTDIR}/${fidb}" ./dependencies/fidb/ || die "cp ${fidb} failed"
	done

	mkdir -p ./dependencies/{Debugger-rmi-trace,Debugger-agent-dbgeng} || die "mkdir Debugger dirs failed"

	cp "${DISTDIR}/protobuf-3.20.3-py2.py3-none-any.whl" ./dependencies/Debugger-rmi-trace/ || die
	cp "${DISTDIR}/psutil-5.9.8.tar.gz" ./dependencies/Debugger-rmi-trace/ || die
	cp "${DISTDIR}/setuptools-68.0.0-py3-none-any.whl" ./dependencies/Debugger-rmi-trace/ || die
	cp "${DISTDIR}/wheel-0.37.1-py2.py3-none-any.whl" ./dependencies/Debugger-rmi-trace/ || die

	cp "${DISTDIR}/Pybag-2.2.12-py3-none-any.whl" ./dependencies/Debugger-agent-dbgeng/ || die
	cp "${DISTDIR}/capstone-5.0.1-py3-none-win_amd64.whl" ./dependencies/Debugger-agent-dbgeng/ || die
	cp "${DISTDIR}/comtypes-1.4.1-py3-none-any.whl" ./dependencies/Debugger-agent-dbgeng/ || die
	cp "${DISTDIR}/pywin32-306-cp312-cp312-win_amd64.whl" ./dependencies/Debugger-agent-dbgeng/ || die
}

src_prepare() {
	mkdir -p ".gradle/init.d" || die "mkdir init.d failed"
	cp "${FILESDIR}/repos.gradle" .gradle/init.d || die "cp repos.gradle failed"
	sed -i "s|S_DIR|${S}|g" .gradle/init.d/repos.gradle || die "sed repos.gradle failed"
	sed -i "s|_\${rootProject.BUILD_DATE_SHORT}||g" gradle/root/distribution.gradle || die "sed distribution.gradle failed"
	ln -s ../.gradle/flatRepo ./dependencies/flatRepo || die "ln flatRepo failed"
	sed -i "s/findPython3(true)/\"${EPYTHON}\"/" build.gradle || die "sed python failed"

	eapply_user
}

src_compile() {
	check_gradle_binary
	export _JAVA_OPTIONS="$_JAVA_OPTIONS -Duser.home=$HOME -Djava.io.tmpdir=${T}"

	local gradle_opts="--gradle-user-home .gradle --console rich --no-daemon --offline --parallel --max-workers $(nproc)"
	unset TERM
	gradle ${gradle_opts} prepDev -x check -x test || die "prepDev failed"
	gradle ${gradle_opts} assembleAll -x check -x test --parallel || die "assembleAll failed"
}

src_install() {
	# Live builds use "DEV" suffix; find the actual dist directory
	local dist_dir
	dist_dir=$(find build/dist/ -maxdepth 1 -type d -name 'ghidra_*' | head -1)
	[[ -z "${dist_dir}" ]] && die "could not find ghidra build dist directory"
	local dist_ver="${dist_dir#build/dist/ghidra_}"

	find "${dist_dir}" -type f -name '*.zip' -exec rm -f {} + || die "rm zip files failed"
	rm -r "${dist_dir}/docs/" || die "rm docs failed"

	insinto /usr/share/ghidra
	doins -r "${dist_dir}"/*

	fperms +x /usr/share/ghidra/ghidraRun
	fperms +x /usr/share/ghidra/support/launch.sh
	fperms +x /usr/share/ghidra/GPL/DemanglerGnu/os/linux_x86_64/demangler_gnu_v2_41
	fperms +x /usr/share/ghidra/Ghidra/Features/Decompiler/os/linux_x86_64/decompile

	# Set executable permissions for debugger scripts if they exist
	local script
	for script in "${ED}"/usr/share/ghidra/Ghidra/Debug/Debugger-*/data/debugger-launchers/*.sh \
	              "${ED}"/usr/share/ghidra/Ghidra/Debug/Debugger-*/data/support/*.sh; do
		[[ -f "${script}" ]] && fperms +x "${script#${ED}}"
	done

	dosym -r /usr/share/ghidra/ghidraRun /usr/bin/ghidra

	doicon GhidraDocs/GhidraClass/Beginner/Images/GhidraLogo64.png
	make_desktop_entry ${PN} "Ghidra" /usr/share/pixmaps/GhidraLogo64.png "Utility"
}