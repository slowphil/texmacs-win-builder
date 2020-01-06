# TeXmacs-win-builder

This repository provides tools to compile TeXmacs for windows in a fully automated way. After running it you get an executable zip that can install TeXmacs on a windows machine ([Ready-made such builds are available here](https://github.com/slowphil/mingw-w64-texmacs/releases/latest)).

The build process is done using the [MSys2/Mingw-w32/Mingw-w64](https://sourceforge.net/p/msys2/wiki/MSYS2%20introduction/) environment.
The setup of the environment, the compilation and the packaging is done in a single step (no complicated how-to to follow!) by running [the released executable](https://github.com/slowphil/texmacs-win-builder/releases/download/0.94/texmacs-win-sdk-installer-0.94.7z.exe). This whole stuff is essentially a modified version of the [Git for Windows SDK](https://git-for-windows.github.io/#contribute) (many thanks to them for making this so easy).


## Pros

- fully automated building of TeXmacs on windows : no prior experience in compiling is needed. Much simpler than the official method.

- No need to wait for the next official release of TeXmacs to test novelties and enjoy the bugfixes.

- A spell checker is bundled with TeXmacs (additional dictionaries require manual install, though).

- This version of TeXmacs can be used as an "equation editor" for Inkscape an LibreOffice

- This building environment and the dependencies are always created fully up-to-date.

- Once the compilation is over, the full-featured build environment remains available for building an updated version later on (saving the long download and install), or for those willing to tweak the code or customize their own TeXmacs installation (familiarity with unix-like environment needed). This environment can also be used for building other great open source softwares. The environment can easily maintained up-to date, using the package manager ([see how to update with pacman here](https://github.com/msys2/msys2/wiki/MSYS2-installation#iii-updating-packages)).


## Cons

- The sdk is HUGE on disk. I made no attempt to minimize its size. It could probably be reduced. 

- If there is an issue with this build, it should be filed here before reporting it to the official site.


## Requirements

- Disk space needed for the building environment : about 5 GB.

- Internet access (with large bandwidth, preferably)

- Beyond the download times, the more cpu cores, the better. As an indication, with 250 Mb/s internet bandwith and 4-core cpu, the complete process takes ~30 min.


## Key files that drive the build process (where to look in case of problems)

After unpacking [the released executable](https://github.com/slowphil/texmacs-win-builder/releases/download/0.94/texmacs-win-sdk-installer-0.94.7z.exe), the setup-tm-sdk.bat batch file is run. It will download and setup the build environment, open an MSys2 shell, fetch the current version of build-tm.sh script and run it (even if the released executable appears to be outdated, it somehow "updates itself").

build-tm.sh will 

- invoke pacman to download readily-built dependencies needed by TeXmacs (qt4, freetype, ...).

- (re-)build three of the dependencies from source using makepkg-mingw: poppler-qt4 (the readily-built package has an option that prevents TeXmacs to start), wget and guile1.8 (that are not available already built - for guile we use the sibling repo [mingw-w64-guile1.8](https://github.com/slowphil/mingw-w64-guile1.8))

- pull the sibling repo [mingw-w64-texmacs](https://github.com/slowphil/mingw-w64-texmacs) and invoke makepkg-mingw to build it. The details of the build options are set in the PKGBUILD of that repo : it will pull the latest svn source, possibly apply patches, then compile, and finally bundle everything that is needed to install on a windows machine in an executable installer.

