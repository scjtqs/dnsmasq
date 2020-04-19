#!/bin/bash
TMP_DIR="/tmp/tmpinstalldir"
function cleanup {
	echo rm -rf $TMP_DIR > /dev/null
	echo rm -rf /webproc > /dev/null
}
function fail {
	cleanup
	msg=$1
	echo "============"
	echo "Error: $msg" 1>&2
	exit 1
}
function install {
	#settings
	USER="jpillora"
	PROG="webproc"
	MOVE="false"
	RELEASE="v0.3.3"
	INSECURE="false"
	OUT_DIR="$(pwd)"
	GH="https://github.com"
	#bash check
	[ ! "$BASH_VERSION" ] && fail "Please use bash instead"
	[ ! -d $OUT_DIR ] && fail "output directory missing: $OUT_DIR"
	#dependency check, assume we are a standard POISX machine
	which find > /dev/null || fail "find not installed"
	which xargs > /dev/null || fail "xargs not installed"
	which sort > /dev/null || fail "sort not installed"
	which tail > /dev/null || fail "tail not installed"
	which cut > /dev/null || fail "cut not installed"
	which du > /dev/null || fail "du not installed"
	GET="mv"
#	if which curl > /dev/null; then
#		GET="curl"
#		if [[ $INSECURE = "true" ]]; then GET="$GET --insecure"; fi
#		GET="$GET --fail -# -L"
#	elif which wget > /dev/null; then
#		GET="wget"
#		if [[ $INSECURE = "true" ]]; then GET="$GET --no-check-certificate"; fi
#		GET="$GET -qO-"
#	else
#		fail "neither wget/curl are installed"
#	fi
	#find OS #TODO BSDs and other posixs
	case `uname -s` in
	Darwin) OS="darwin";;
	Linux) OS="linux";;
	*) fail "unknown os: $(uname -s)";;
	esac
	#find ARCH
	if uname -m | grep 64 > /dev/null; then
		ARCH="amd64"
	elif uname -m | grep arm > /dev/null; then
		ARCH="arm"
    elif uname -m | grep aarch64 > /dev/null; then
		ARCH="arm64"
	elif uname -m | grep 386 > /dev/null; then
		ARCH="386"
	else
		fail "unknown arch: $(uname -m)"
	fi
	#choose from asset list
	URL=""
	FTYPE=""
	case "${OS}_${ARCH}" in
	"linux_386")
		URL="webproc_0.3.3_linux_386.gz"
		FTYPE=".gz"
		;;
	"linux_amd64")
		URL="webproc_0.3.3_linux_amd64.gz"
		FTYPE=".gz"
		;;
	"linux_arm64")
		URL="webproc_0.3.3_linux_arm64.gz"
		FTYPE=".gz"
		;;
	"linux_arm")
		URL="webproc_0.3.3_linux_armv7.gz"
		FTYPE=".gz"
		;;
	*) fail "No asset for platform ${OS}-${ARCH}";;
	esac
	#got URL! download it...
	echo -n "Downloading $USER/$PROG $RELEASE"

	echo "....."

	#enter tempdir
	mkdir -p $TMP_DIR
	cd $TMP_DIR
    which gzip > /dev/null || fail "gzip is not installed"
    #gzipped binary
    NAME="${PROG}_${OS}_${ARCH}.gz"
    GZURL="$GH/releases/download/$RELEASE/$NAME"
    #gz download!
    bash -c "$GET /webproc/$URL ./"
    gzip -d ./$URL  > $PROG || fail "download failed"

	#search subtree largest file (bin)
	TMP_BIN=$(find . -type f | xargs du | sort -n | tail -n 1 | cut -f 2)
	if [ ! -f "$TMP_BIN" ]; then
		fail "could not find downloaded binary"
	fi
	#ensure its larger than 2MB
	if [[ $(du -m $TMP_BIN | cut -f1) -lt 2 ]]; then
		fail "resulting file is smaller than 2MB, not a go binary"
	fi
	#move into PATH or cwd
	chmod +x $TMP_BIN || fail "chmod +x failed"

	mv $TMP_BIN $OUT_DIR/$PROG || fail "mv failed" #FINAL STEP!
	echo "Downloaded to $OUT_DIR/$PROG"
	#done
	cleanup
}
install
