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

if ! (pacman -Q mingw-w64-i686-qt4) ; then
  cd /var/cache/pacman/pkg
  #wget http://repo.msys2.org/mingw/i686/mingw-w64-i686-qt4-4.8.7-4-any.pkg.tar.xz
  wget https://github.com/slowphil/mingw-w64-qt4/releases/download/qt4-4.8.7-4/mingw-w64-i686-qt4-4.8.7-4-any.pkg.tar.xz
  pacman --noconfirm -U mingw-w64-i686-qt4-4.8.7-4-any.pkg.tar.xz
fi

cd /build

# libcurl option breaks poppler dll and exes on 32 bits
# we rebuild poppler-qt4 from sources, without curl option
# 1- pull package source (easier with svn)
if test ! -d mingw-w64-poppler-qt4 ; then
  if true ;
  then
    # donwload already-built
    mkdir mingw-w64-poppler-qt4/
    cd mingw-w64-poppler-qt4/
    wget https://github.com/slowphil/mingw-w64-poppler-qt4/releases/download/poppler-qt4-0.45/mingw-w64-i686-poppler-qt4-0.45.0-1-any.pkg.tar.xz
    pacman --noconfirm -U mingw-w64-i686-poppler-qt4-0.45.0-1-any.pkg.tar.xz
  else
    #svn export https://github.com/msys2/MINGW-packages-dev/trunk/mingw-w64-poppler-qt4 mingw-w64-poppler-qt4
    #cd mingw-w64-poppler-qt4/
    ## 2- we remove curl option  
    #sed -i '/--enable-libcurl/d' ./PKGBUILD
    ## 3- bump version  
    #sed -i 's/pkgver=0.36.0/pkgver=0.45.0/g' ./PKGBUILD
    #sed -i 's/93cc067b23c4ef7421380d3e8bd7c940b2027668446750787d7c1cb42720248e/96dd1a6024bcdaa4530a3b49687db3d5c24ddfd072ccb37c6de0e42599728798/g' ./PKGBUILD
    ## fix typo
    #sed -i 's/$}/${/g' ./PKGBUILD
    
    #patching already done here:
    git clone https://github.com/slowphil/mingw-w64-poppler-qt4.git
    cd mingw-w64-poppler-qt4/
    MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm
  fi
fi

# we build mingw-w64-wget from sources (no binary available)
#cd /build
#if test ! -d mingw-w64-wget ; then
#  svn export https://github.com/Alexpux/MINGW-packages/trunk/mingw-w64-wget mingw-w64-wget
#  cd mingw-w64-wget/
#  MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm --skippgpcheck
#fi
#pacman --noconfirm -S mingw-w64-i686-wget # now available in repo!


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
wget https://downloads.sourceforge.net/project/innounp/innounp/innounp%200.49/innounp049.rar ;
unrar e innounp049.rar ;
rm *.rar
fi
# then inno setup
if test ! -z "/build/inno/inno_setup/ISCC.exe" ; then
wget http://files.jrsoftware.org/is/6/innosetup-6.0.3.exe ;
./innounp.exe -dinno_setup -c{app} -v -x innosetup-6.0.3.exe ;
rm innosetup-6.0.3.exe
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
wget https://kjkpub.nyc3.digitaloceanspaces.com/software/sumatrapdf/rel/SumatraPDF-3.1.2.zip
7z x SumatraPDF-3.1.2.zip
rm *.zip
fi

# get Imagemagick portable
if test ! -d "/build/Imagemagick" ; then
mkdir /build/Imagemagick
cd /build/Imagemagick
wget https://download.imagemagick.org/ImageMagick/download/binaries/ImageMagick-7.1.0-portable-Q8-x86.zip
7z x ImageMagick-7.1.0-portable-Q8-x86.zip
rm *.zip
fi

# now, finally download and build texmacs
cd /build
if test ! -d mingw-w64-texmacs ; then
  git clone https://github.com/slowphil/mingw-w64-texmacs.git
fi
cd mingw-w64-texmacs/
MINGW_ARCH=mingw32 makepkg-mingw -sL --noconfirm -p PKGBUILD-qt4


#end
#reset

#clear package cache to free disk space
cd /var/cache/pacman/pkg
rm *.pkg.tar.xz

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
  
