#!/bin/sh

# builds and packs texmacs for windows on Msys2/Mingw32


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

if test ! -d /build ; then
  mkdir -p /build
fi



# pacman no longer finds qt4 probably because of https://github.com/msys2/MINGW-packages/issues/3881
# nevertheless the binary still exists in the repo (for the moment)
# https://msys2.duckdns.org/repos
# https://wiki.archlinux.org/index.php/offline_installation_of_packages
cd /var/cache/pacman/pkg
wget http://repo.msys2.org/mingw/i686/mingw-w64-i686-qt4-4.8.7-4-any.pkg.tar.xz
pacman --noconfirm -U mingw-w64-i686-qt4-4.8.7-4-any.pkg.tar.xz

cd /build

# libcurl option breaks poppler dll and exes on 32 bits
# we rebuild poppler-qt4 from sources, without curl option
# 1- pull package source (easier with svn)
if test ! -d mingw-w64-poppler-qt4 ; then
svn export https://github.com/Alexpux/MINGW-packages/trunk/mingw-w64-poppler-qt4 mingw-w64-poppler-qt4
fi
cd mingw-w64-poppler-qt4/
# 2- we remove curl option  
sed -i '/--enable-libcurl/d' ./PKGBUILD
# 3- bump version  
sed -i 's/pkgver=0.36.0/pkgver=0.45.0/g' ./PKGBUILD
sed -i 's/93cc067b23c4ef7421380d3e8bd7c940b2027668446750787d7c1cb42720248e/96dd1a6024bcdaa4530a3b49687db3d5c24ddfd072ccb37c6de0e42599728798/g' ./PKGBUILD
# fix typo
sed -i 's/$}/${/g' ./PKGBUILD
MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm

# we build mingw-w64-wget from sources (no binary available)
cd /build
if test ! -d mingw-w64-wget ; then
svn export https://github.com/Alexpux/MINGW-packages/trunk/mingw-w64-wget mingw-w64-wget
fi
cd mingw-w64-wget/
MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm --skippgpcheck



# guile 1.8 is not in the MSys2 repos, get it from my Githubs.
cd /build
if test ! -d mingw-w64-guile1.8 ; then
if true ;
then
  # donwload already-built
  mkdir mingw-w64-guile1.8/
  cd mingw-w64-guile1.8/
  wget https://github.com/slowphil/mingw-w64-guile1.8/releases/download/v1.8.8-mingw-w64-i686-1/mingw-w64-i686-guile1.8-1.8.8-1-any.pkg.tar.xz
  pacman --noconfirm -U mingw-w64-i686-guile1.8-1.8.8-1-any.pkg.tar.xz
else
  # build from sources
  git clone https://github.com/slowphil/mingw-w64-guile1.8.git
  cd mingw-w64-guile1.8/
  MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm
fi
fi

# get inno setup
if test ! -d "/build/inno" ; then
mkdir /build/inno
cd /build/inno
#first a utility to unpack inno setup itself without running it
if test ! -z "/build/inno/innounp.exe" ; then
wget https://downloads.sourceforge.net/project/innounp/innounp/innounp%200.46/innounp046.rar ;
unrar e innounp046.rar ;
rm *.rar
fi
# then inno setup
if test ! -z "/build/inno/inno_setup/ISCC.exe" ; then
wget http://files.jrsoftware.org/is/5/isetup-5.5.8.exe ;
./innounp.exe -dinno_setup -c{app} -v -x isetup-5.5.8.exe ;
rm isetup-5.5.8.exe
fi
fi

# get winsparkle
if test ! -d "/build/winsparkle" ; then
mkdir /build/winsparkle
cd /build/winsparkle
wget https://github.com/vslavik/winsparkle/releases/download/v0.6.0/WinSparkle-0.6.0.zip
7z x WinSparkle-0.6.0.zip
rm *.zip
cd WinSparkle-*
cp include/* ..
cp Release/* ..
fi

# get SumatraPDF
if test ! -d "/build/SumatraPDF" ; then
mkdir /build/SumatraPDf
cd /build/SumatraPDF
wget https://www.sumatrapdfreader.org/dl/SumatraPDF-3.1.2.zip
7z x SumatraPDF-3.1.2.zip
rm *.zip
fi

# now, finally download and build texmacs
cd /build
if test ! -d mingw-w64-texmacs ; then
git clone https://github.com/slowphil/mingw-w64-texmacs.git
fi
cd mingw-w64-texmacs/
MINGW_INSTALLS=mingw32 makepkg-mingw -sL --noconfirm 


#end
#reset
echo 
echo 
if test -f /texmacs_installer.exe ; then
  echo "**********************************************************" 
  echo "*                                                        *"
  echo "*          TeXmacs was successfully built !              *"
  echo "*                                                        *"
  echo "**********************************************************" 
  echo "You can find it here :"
  echo  "$(cygpath -aw /texmacs-installer.exe)"
else
  echo "**********************************************************" 
  echo "*                                                        *"
  echo "*      The TeXmacs installer was not created...          *"
  echo "*                                                        *"
  echo "*            something went wrong :(                     *"
  echo "**********************************************************" 
fi
echo 
read -p "Press Enter to close this window..."  
  
