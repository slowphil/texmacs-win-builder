#!/bin/sh



#This script builds a "texmacs-win-sdk-installer", which, when run, will automatically
#-setup an msys2-mingw environment 
#-get all dependencies for texmacs
#-build texmacs and pack texmacs installers

#This script runs inside a prexisting msys2 environment (or linux), but the installer it generates is not related to it.  

# the script extracts a msys2-[base-]x86_64-YYYYMMDD.sfx.exe file
# from https://github.com/msys2/msys2-installer/releases/latest
# e.g. https://github.com/msys2/msys2-installer/releases/download/2020-11-09/msys2-base-x86_64-20201109.sfx.exe
# adds needed stuff and repacks it with the stuff in this repo
# to make the "TeXmacs for Windows SDK installer"

#important : needs the enhanced sfx from Git for windows 
#https://github.com/git-for-windows/build-extra/commit/ef78e61c865379ce2c07ec3b7fc01c6c930a054d
# not that in the standard 7z sdk (https://www.7-zip.org/sdk.html)
 
sfx="msys2-base-x86_64-20201109.sfx.exe"
date="2020-11-09"

if test -z "$1" ; then 
  wget "https://github.com/msys2/msys2-installer/releases/download/$date/$sfx"
  if test ! -f $sfx ; then
    echo "Could not download $sfx msys2-base-x86_64-20201109.sfx.exe, stopping."
    echo " "
    echo "You may run this script with an alternate sfx.exe or tar.xz file"
    echo "downloaded from https://github.com/msys2/msys2-installer/releases"
    echo "or http://repo.msys2.org/distrib/x86_64/"
    echo "and run this script with the downloaded file as argument"
    echo "$(basename $0) <msys2-[base-]x86_64-YYYYMMDD.*>" 
    exit 1
  else
    src=$sfx
  fi
else
  src=$1
fi

die () {
	echo "$*" >&2
	exit 1
}

TARGET="texmacs-win-sdk-installer.7z.exe"
OPTS7="-m0=lzma -mx=9 -md=64M -r"
TMPPACK=/tmp/tmp.7z
TMPUNPACK=/tmp/tmp_unpack

#directory where this script is, other files we need are there too
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

#SCRIPT_PATH=$(dirname $(readlink -f $0)) should work too


#The fastest would be to pick the 7z archive in sfx,
# (finding its signature in the sfx and discarding what's in front)
#offset=$(LANG=C grep -obUaP "\x37\x7A\xBC\xAF\x27\x1C" $1 | cut -d":" -f1)
#dd bs=$offset skip=1 if=$1 of=$TMPPACK
# then add our scripts to the archive
#7z a $TMPPACK $SCRIPT_PATH/setup-tm-sdk.bat $SCRIPT_PATH/build-tm.sh $SCRIPT_PATH/7zSD.sfx
# and repack as below

#however, the original 7z archive has un unwanted msys64 folder at root
#that we would need to suppress afterwards
#By extracting and repacking, we get rid of this msys64 folder


#unpack msys64
rm -rf $TMPUNPACK
mkdir $TMPUNPACK
case $src in
  *".sfx.exe"*)
    7z x -o$TMPUNPACK $src 
    ;;
  *".tar.xz"*)
    7z x $src -so | 7z x -aoa -si -ttar -o$TMPUNPACK
    ;;
esac

#copy our scripts and the 7zSD.sfx 
cp "$SCRIPT_PATH/7zSD.sfx" "$SCRIPT_PATH/setup-tm-sdk.bat" "$SCRIPT_PATH/build-tm.sh"  $TMPUNPACK/msys64

echo "Creating sfx archive"
cd /tmp 
7za a $OPTS7 "$TMPPACK" $TMPUNPACK/msys64/*
(cat "$SCRIPT_PATH/7zSD.sfx" &&
 echo ';!@Install@!UTF-8!' &&
 echo 'Title="TeXmacs for Windows SDK"' &&
 echo 'BeginPrompt="This archive installs an SDK and automaticaly builds TeXmacs for Windows\n You need ~5GB of free disk space for the build to complete"' &&
 echo 'CancelPrompt="Do you want to cancel the TeXmacs SDK installation?"' &&
 echo 'ExtractDialogText="Please, wait..."' &&
 echo 'ExtractPathText="Where do you want to install the TeXmacs SDK?"' &&
 echo 'ExtractTitle="Extracting..."' &&
# echo 'GUIFlags="8+32+64+256+4096"' && #not implemented in newest sfx see https://github.com/git-for-windows/7-Zip/blob/v19.00-VS2019-sfx/README.md
# echo 'GUIMode="1"' &&
# echo 'OverwriteMode="2"' &&
 echo 'InstallPath="C:\\\\texmacs-sdk"' &&
 echo 'ExecuteFile="setup-tm-sdk.bat"' &&
 #echo 'Delete="%%T\setup-tm-sdk.bat"' &&
 echo ';!@InstallEnd@!' &&
 cat "$TMPPACK") > "$TARGET"

if test -f "$TARGET" ; then
  if ! type cygpath > /dev/null; then
    echo "Success! You will find the new installer at \"$(readlink -f $TARGET)\""
  else
    echo "Success! You will find the new installer at \"$(cygpath -aw $TARGET)\""
  fi
else
  echo "Sorry something went wrong..."
fi

rm -rf $TMPPACK
rm -rf $TMPUNPACK

