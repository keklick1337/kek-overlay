# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..14} )
inherit java-pkg-2 desktop python-single-r1

GRADLE_DEP_VER="20260606"
GRADLE_VER="8.5"
RELEASE_VERSION="${PV}"
YAJSW_VER="13.18"
POSTGRESQL_VER="15.13"
Z3_VER="4.13.0"
Z3_X64_GLIBC_VER="2.31"
Z3_NAME="z3-${Z3_VER}-x64-glibc-${Z3_X64_GLIBC_VER}"

DESCRIPTION="Ghidra is a software reverse engineering (SRE) framework created and
		maintained by the National Security Agency Research Directorate. This
		framework includes a suite of full-featured, high-end software analysis
		tools that enable users to analyze compiled code on a variety of platforms
		simply and efficiently."
HOMEPAGE="https://github.com/NationalSecurityAgency/ghidra"

FIDB_FILES="vs2012_x86.fidb vs2012_x64.fidb vs2015_x86.fidb vs2015_x64.fidb \
	vs2017_x86.fidb vs2017_x64.fidb vs2019_x86.fidb vs2019_x64.fidb vsOlder_x86.fidb vsOlder_x64.fidb"

SRC_URI="https://github.com/NationalSecurityAgency/${PN}/archive/refs/tags/Ghidra_${PV}_build.tar.gz
	https://dev.pentoo.ch/~blshkv/distfiles/${PN}-dependencies-${GRADLE_DEP_VER}.tar.gz
	https://github.com/pxb1988/dex2jar/releases/download/v2.4/dex-tools-v2.4.zip
	https://github.com/digitalsleuth/AXMLPrinter2/raw/691036a3caf84950fbb0df6f1fa98d7eaa92f2a0/AXMLPrinter2.jar
	https://github.com/unsound/hfsexplorer/releases/download/hfsexplorer-0.21/hfsexplorer-0_21-bin.zip
	https://downloads.sourceforge.net/yajsw/yajsw/yajsw-stable-${YAJSW_VER}.zip
	https://ftp.postgresql.org/pub/source/v${POSTGRESQL_VER}/postgresql-${POSTGRESQL_VER}.tar.gz
	https://archive.eclipse.org/tools/cdt/releases/8.6/cdt-8.6.0.zip
	https://sourceforge.net/projects/pydev/files/pydev/PyDev%209.3.0/PyDev%209.3.0.zip -> PyDev-9.3.0.zip
	https://github.com/NationalSecurityAgency/ghidra-data/raw/Ghidra_${RELEASE_VERSION}/lib/java-sarif-2.1-modified.jar
	https://github.com/NationalSecurityAgency/ghidra-data/raw/Ghidra_${RELEASE_VERSION}/Debugger/dbgmodel.tlb
	https://github.com/Z3Prover/z3/releases/download/z3-${Z3_VER}/${Z3_NAME}.zip
"
for FIDB in ${FIDB_FILES}; do
	SRC_URI+=" https://github.com/NationalSecurityAgency/ghidra-data/raw/Ghidra_${RELEASE_VERSION}/FunctionID/${FIDB}"
done

# Python wheels/sdists, pinned to the versions fetchDependencies.gradle expects.
# Windows- and macOS-only wheels are omitted: this package is Linux only.
SRC_URI+=" https://files.pythonhosted.org/packages/ee/01/1ed1d482960a5718fd99c82f6d79120181947cfd4667ec3944d448ed44a3/protobuf-6.31.0-py3-none-any.whl
	https://files.pythonhosted.org/packages/90/c7/6dc0a455d111f68ee43f27793971cf03fe29b6ef972042549db29eec39a2/psutil-5.9.8.tar.gz
	https://files.pythonhosted.org/packages/a3/dc/17031897dae0efacfea57dfd3a82fdd2a2aeb58e0ff71b77b87e44edc772/setuptools-80.9.0-py3-none-any.whl
	https://files.pythonhosted.org/packages/0b/2c/87f3254fd8ffd29e4c02732eee68a83a1d3c346ae39bc6822dcbcb697f2b/wheel-0.45.1-py3-none-any.whl
	https://files.pythonhosted.org/packages/5e/a2/52084698c0a3c7e7a94ddfff26f83df09a50781b8436f6f203f5de0a457c/pybag-2.2.16-py3-none-any.whl
	https://files.pythonhosted.org/packages/66/95/f30c80615fda0d3c0ee6493ac9db61183313b43499b62dec136773b0e870/comtypes-1.4.13-py3-none-any.whl
	https://files.pythonhosted.org/packages/92/3a/658eb3ba88f067662be280f8f1aec07a70c96bac77e9edc48b1be38e446b/win32more-0.7.0-py3-none-any.whl
	https://files.pythonhosted.org/packages/f6/49/cff21fc3adcac1fe19f9f2e50278553fe13b9ac702be569c97f85292481d/win32more_appsdk-0.7.3-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/81/bc/7c1c5609f835d3e719c944714638a7a70bbfef6b990c251c32c1cd82d67a/win32more_core-0.7.0-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/b5/6d/d58b223be7cff571527d91a3626089cb4da614dcba461811dcf18449f0f9/win32more_microsoft_graphics_win2d-0.7.1.3.2-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/6c/8e/fdfc9f796aad6b622ff197b3e58c9689db95482dbf7817cd99d351b54719/win32more_microsoft_web_webview2-0.7.1.0.3650.58-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/56/d7/0bb36964811a23f262cdddb1e5b91fdbd2f494990d48e657f15108f04855/win32more_microsoft_windows_sdk_contracts-0.7.10.0.26100.6901-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/e5/37/8706eb126fc52e59526304aa89ee30771a894e489aa0ea835f101e499b17/win32more_microsoft_windows_sdk_win32metadata-0.7.68.0.4-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/ef/7c/9630708dd252e0c5c7c9975d52ba0deea996e9b0cf29784d521ac30f3a48/win32more_microsoft_windowsappsdk-0.7.1.8.251106002-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/20/12/38679034af332785aac8774540895e234f4d07f7545804097de4b666afd8/packaging-25.0-py3-none-any.whl
	https://files.pythonhosted.org/packages/6d/d0/191db2e9ab6ae7029368a488c9d88235966843b185aba7925e54aa0c0013/jpype1-1.5.2-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
	https://files.pythonhosted.org/packages/74/f3/1cd4332076ed0421e703412f47f15f43af170809435c57ba3162edc80d4b/jpype1-1.5.2-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
	https://files.pythonhosted.org/packages/0b/7d/9fdbbc1a574be43f9820735ca8df0caf8b159856201d9b21fd73932342bc/jpype1-1.5.2-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
	https://files.pythonhosted.org/packages/97/0a/cbe03759331c640aa5862f974028122a862b08935a0b11b8fa6f6e46c26b/jpype1-1.5.2-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
	https://files.pythonhosted.org/packages/77/91/f08a719461a390b48d9096b50f1f4a49ee281007ec192e51073090d3d8b7/jpype1-1.5.2-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
	https://files.pythonhosted.org/packages/bd/68/47fa634cbd0418cbca86355e9421425f5892ee994f7338106327e49f9117/jpype1-1.5.2.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"

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

S="${WORKDIR}/ghidra-Ghidra_${PV}_build"

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
	unpack ${A}

	mkdir -p "${S}/.gradle/flatRepo" || die "mkdir failed"
	cd "${S}/.gradle" || die

	unpack dex-tools-v2.4.zip
	cp dex-tools-v2.4/lib/dex-*.jar ./flatRepo || die "cp dex jar failed"

	cp "${DISTDIR}/AXMLPrinter2.jar" ./flatRepo || die "cp AXMLPrinter failed"
	cp "${DISTDIR}/java-sarif-2.1-modified.jar" ./flatRepo || die "cp sarif failed"

	unpack hfsexplorer-0_21-bin.zip
	cp lib/*.jar ./flatRepo || die "cp hfsexplorer failed"

	# com.microsoft.z3 Java binding for the SymbolicSummaryZ3 extension
	unpack "${Z3_NAME}.zip"
	cp "${Z3_NAME}/bin/com.microsoft.z3.jar" ./flatRepo || die "cp z3 jar failed"

	mkdir -p "${WORKDIR}/ghidra.bin/Ghidra/Features/GhidraServer/" || die "mkdir server failed"
	cp "${DISTDIR}/yajsw-stable-${YAJSW_VER}.zip" "${WORKDIR}/ghidra.bin/Ghidra/Features/GhidraServer/" || die "cp yajsw failed"

	local plugin_dep_path="ghidra.bin/GhidraBuild/EclipsePlugins/GhidraDev/buildDependencies"
	mkdir -p "${WORKDIR}/${plugin_dep_path}/" || die "mkdir plugin deps failed"
	cp "${DISTDIR}/PyDev-9.3.0.zip" "${WORKDIR}/${plugin_dep_path}/PyDev 9.3.0.zip" || die "cp PyDev failed"
	cp "${DISTDIR}/cdt-8.6.0.zip" "${WORKDIR}/${plugin_dep_path}/" || die "cp cdt failed"
	cp "${DISTDIR}/postgresql-${POSTGRESQL_VER}.tar.gz" "${WORKDIR}/${plugin_dep_path}/" || die "cp postgresql failed"

	cd "${S}" || die
	mv ../dependencies . || die "mv dependencies failed"

	mkdir ./dependencies/fidb || die "mkdir fidb failed"
	local fidb
	for fidb in ${FIDB_FILES}; do
		cp "${DISTDIR}/${fidb}" ./dependencies/fidb/ || die "cp ${fidb} failed"
	done

	mkdir -p ./dependencies/{Debugger-rmi-trace,Debugger-agent-dbgeng,PyGhidra,BSim,SymbolicSummaryZ3/os/linux_x86_64} || die "mkdir dependency dirs failed"

	# Prebuilt Windows type library (midl output, buildable only on Windows); the
	# Debugger-agent-dbgeng project asserts it exists at configure time.
	cp "${DISTDIR}/dbgmodel.tlb" ./dependencies/Debugger-agent-dbgeng/ || die "cp dbgmodel.tlb failed"

	cp "${DISTDIR}/postgresql-${POSTGRESQL_VER}.tar.gz" ./dependencies/BSim/ || die "cp BSim postgresql failed"

	cp .gradle/"${Z3_NAME}"/bin/libz3*.so ./dependencies/SymbolicSummaryZ3/os/linux_x86_64/ || die "cp z3 libs failed"

	cp "${DISTDIR}"/{protobuf-6.31.0-py3-none-any.whl,psutil-5.9.8.tar.gz,setuptools-80.9.0-py3-none-any.whl,wheel-0.45.1-py3-none-any.whl} \
		./dependencies/Debugger-rmi-trace/ || die "cp Debugger-rmi-trace wheels failed"

	cp "${DISTDIR}"/{pybag-2.2.16-py3-none-any.whl,comtypes-1.4.13-py3-none-any.whl,win32more-0.7.0-py3-none-any.whl,win32more_appsdk-0.7.3-py2.py3-none-any.whl,win32more_core-0.7.0-py2.py3-none-any.whl,win32more_microsoft_graphics_win2d-0.7.1.3.2-py2.py3-none-any.whl,win32more_microsoft_web_webview2-0.7.1.0.3650.58-py2.py3-none-any.whl,win32more_microsoft_windows_sdk_contracts-0.7.10.0.26100.6901-py2.py3-none-any.whl,win32more_microsoft_windows_sdk_win32metadata-0.7.68.0.4-py2.py3-none-any.whl,win32more_microsoft_windowsappsdk-0.7.1.8.251106002-py2.py3-none-any.whl} \
		./dependencies/Debugger-agent-dbgeng/ || die "cp Debugger-agent-dbgeng wheels failed"

	cp "${DISTDIR}"/{packaging-25.0-py3-none-any.whl,setuptools-80.9.0-py3-none-any.whl,wheel-0.45.1-py3-none-any.whl,jpype1-1.5.2.tar.gz,jpype1-1.5.2-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl,jpype1-1.5.2-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl,jpype1-1.5.2-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl,jpype1-1.5.2-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl,jpype1-1.5.2-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl} \
		./dependencies/PyGhidra/ || die "cp PyGhidra wheels failed"
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
	find build/dist/ghidra_${PV}_DEV/ -type f -name '*.zip' -exec rm -f {} + || die "rm zip files failed"
	rm -r build/dist/ghidra_${PV}_DEV/docs/ || die "rm docs failed"

	insinto /usr/share/ghidra
	doins -r build/dist/ghidra_${PV}_DEV/*

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

	# doins drops the executable bit; restore the modes the build produced
	local exe
	while IFS= read -r exe; do
		fperms +x "/usr/share/ghidra/${exe}" || die "fperms ${exe} failed"
	done < <(cd build/dist/ghidra_${PV}_DEV && find . -type f -perm -u+x -printf '%P\n')

	dosym -r /usr/share/ghidra/ghidraRun /usr/bin/ghidra

	doicon GhidraDocs/GhidraClass/Beginner/Images/GhidraLogo64.png
	make_desktop_entry --eapi9 ${PN} -n "Ghidra" -i /usr/share/pixmaps/GhidraLogo64.png \
		-c "Utility" -C "Software reverse engineering framework"
}
