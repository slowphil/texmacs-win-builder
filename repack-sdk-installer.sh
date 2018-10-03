#!/bin/sh

# Repack texmacs-win-sdk-$VERSION.exe
export LANG=C # for objdump output in english
test -z "$1" && {
	echo "Usage: $0 <version>"
	exit 1
}

die () {
	echo "$*" >&2
	exit 1
}

ARCH="$(uname -m)"
case "$ARCH" in
i686)
	BITNESS=32
	;;
x86_64)
	BITNESS=64
	;;
*)
	die "Unhandled architecture: $ARCH"
	;;
esac

test -f /usr/bin/objdump ||
pacman -Sy --noconfirm binutils ||
die "Could not install binutils"

type 7za ||
pacman -Sy --noconfirm p7zip ||
die "Could not install 7-Zip"


#FAKEROOTDIR="$(cd "$(dirname "$0")" && pwd)/root"
FAKEROOTDIR="/fakeroot"
TARGET="/texmacs-win-sdk-installer-"$1".7z.exe"
OPTS7="-m0=lzma -mx=9 -md=64M"
TMPPACK=/tmp.7z
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$FAKEROOTDIR/usr/bin" "$FAKEROOTDIR/etc" ||
die "Could not create fake root directory"


cp /usr/bin/dash.exe "$FAKEROOTDIR/usr/bin/sh.exe" &&
sed -e 's/^#\(XferCommand.*curl\).*/\1 --anyauth -C - -L -f %u >%o/' \
	</etc/pacman.conf >"$FAKEROOTDIR/etc/pacman.conf.proxy" ||
die "Could not copy extra files into fake root"

dlls_for_exes () {
	# Add DLLs' transitive dependencies
	dlls=
	todo="$* "
	while test -n "$todo"
	do
		path=${todo%% *}
		todo=${todo#* }
		case "$path" in ''|' ') continue;; esac
		for dll in $(/usr/bin/objdump -p "$path" |
			sed -n 's/^\tDLL Name: msys-/usr\/bin\/msys-/p')
		do
			case "$dlls" in
			*"$dll"*) ;; # already found
			*) dlls="$dlls $dll"; todo="$todo /$dll ";;
			esac
		done
	done
	echo "$dlls"
}

fileList="etc/nsswitch.conf \
	etc/pacman.conf \
	etc/pacman.d \
	usr/bin/pacman-key \
	usr/bin/tput.exe \
	usr/bin/pacman.exe \
    usr/bin/pacman-conf.exe \
	usr/share/makepkg/util/parseopts.sh \
	usr/bin/curl.exe \
	usr/bin/gpg.exe \
	$(dlls_for_exes /usr/bin/gpg.exe /usr/bin/curl.exe)
	usr/ssl/certs/ca-bundle.crt \
	var/lib/pacman \
	setup-tm-sdk.bat $FAKEROOTDIR/etc $FAKEROOTDIR/usr \
	repack-sdk-installer.sh \
    7zSD.sfx"

echo $fileList

echo "Creating archive" &&
(cd / && 7za -x'!var/lib/pacman/*' -x'!etc/pacman.d/gnupg/private-keys-v1.d' a $OPTS7 "$TMPPACK" $fileList) &&
(cat "/7zSD.sfx" &&
 echo ';!@Install@!UTF-8!' &&
 echo 'Title="TeXmacs for Windows SDK"' &&
 echo 'BeginPrompt="This archive installs an SDK and automaticaly builds TeXmacs for Windows\n You need ~5GB of free disk space for the build to complete"' &&
 echo 'CancelPrompt="Do you want to cancel the TeXmacs SDK installation?"' &&
 echo 'ExtractDialogText="Please, wait..."' &&
 echo 'ExtractPathText="Where do you want to install the TeXmacs SDK?"' &&
 echo 'ExtractTitle="Extracting..."' &&
 echo 'GUIFlags="8+32+64+256+4096"' &&
 echo 'GUIMode="1"' &&
 echo 'InstallPath="C:\\texmacs-sdk"' &&
 echo 'OverwriteMode="2"' &&
 echo 'ExecuteFile="%%T\setup-tm-sdk.bat"' &&
 #echo 'Delete="%%T\setup-tm-sdk.bat"' &&
 echo ';!@InstallEnd@!' &&
 cat "$TMPPACK") > "$TARGET" &&
echo "Success! You will find the new installer at \"$TARGET\"." &&
echo "It is a self-extracting .7z archive." #&&
rm $TMPPACK
