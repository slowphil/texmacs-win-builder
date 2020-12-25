# TeXmacs-win-builder

This repository provides tools to build TeXmacs for windows in a fully automated way. Running the [the released executable](https://github.com/slowphil/texmacs-win-builder/releases/download/0.95/texmacs-win-sdk-installer-0.95.7z.exe) will setup a full SDK with all dependencies and automatically start the build process for TeXmacs. Eventually it produces TeXmacs for windows installers ([Ready-made such installers for TeXmacs are available here](https://github.com/slowphil/mingw-w64-texmacs/releases/latest)).

The building process is done using the [MSys2/Mingw-w32/Mingw-w64](https://sourceforge.net/p/msys2/wiki/MSYS2%20introduction/) environment.

## Pros

- fully automated building of TeXmacs on windows : no prior experience in compiling is needed. Much simpler than the official method.

- No need to wait for the next official release of TeXmacs to test novelties and enjoy the bugfixes.

- A spell checker is bundled with TeXmacs (additional dictionaries require manual install, though).

- This version of TeXmacs can be used as an "equation editor" for Inkscape and LibreOffice

- This building environment and the dependencies are always created fully up-to-date.

- Once the compilation is over, the full-featured build environment remains available for building an updated version later on (saving the long download and install), or for those willing to tweak the code or customize their own TeXmacs installation (familiarity with unix-like environment needed). This environment can also be used for building other great open source softwares. The environment can easily maintained up-to date, using the package manager ([see how to update with pacman here](https://github.com/msys2/msys2/wiki/MSYS2-installation#iii-updating-packages)).


## Cons

- The sdk is HUGE on disk. I made no attempt to minimize its size. It could probably be reduced. 

- If there is an issue with this build, it should be filed here before reporting it to the official site.


## Requirements

- Disk space needed for the building environment : about 5.5 GB.

- Internet access (with large bandwidth, preferably)

- Beyond the download times, the more cpu cores, the better. As an indication, with 250 Mb/s internet bandwith and 4-core cpu, the complete process takes ~30 min. If your internet connection is slower it can last several hours...


## Key files that drive the build process of TeXmacs (where to look in case of problems)

After unpacking [the released executable](https://github.com/slowphil/texmacs-win-builder/releases/download/0.95/texmacs-win-sdk-installer-0.95.7z.exe), the setup-tm-sdk.bat batch file is run. It will download and setup the build environment, fetch the current version of build-tm.sh script and run it (even if the released executable seems outdated, it "update itself" to the latest buiding script), and finally open an MSys2 shell.

build-tm.sh will 

- invoke pacman to download readily-built dependencies needed by TeXmacs (freetype, ...).

- pull or (re-)build four of the dependencies from source using makepkg-mingw: qt4 (no longer available in Msys2 repos, we pull a binary of the latest version in the msys2 repos that [we copied here](https://github.com/slowphil/mingw-w64-qt4)), a prebuilt binary of [poppler-qt4](https://github.com/slowphil/mingw-w64-poppler-qt4), wget and guile1.8 (that are not available in msys2 repos - for guile we use the binary released in the sibling repo [mingw-w64-guile1.8](https://github.com/slowphil/mingw-w64-guile1.8))

- pull the sibling repo [mingw-w64-texmacs](https://github.com/slowphil/mingw-w64-texmacs) and invoke makepkg-mingw to build it. The details of the build options are set in the PKGBUILD of that repo : it will pull the latest svn source, possibly apply patches, then compile, and finally bundle everything that is needed to install on a windows machine in an executable installer (as well as an executable 7z archive for those needing/wanting a "portable" installation).

## Making of the SDK installer itself

Clone this repo in an pre-existing Msys2 install, or in a Linux machine (windows not needed). Then run pack_texmacs_sdk_installer.sh. See details in the script itself.

### changes in the SDK
Up to Dec. 2020, the SDK installer was a modified version of the early [Git for Windows SDK](https://git-for-windows.github.io/#contribute) (many thanks to them for making this so easy).
However, due to changes in MSYS2, the old sdk installer would no longer create a working setup, and because of profound changes in the Git for windows SDK, the previous TeXmacs win SDK installer could not be fixed easily. The TeXmacs win SDK installer is now a modified version of the [msys2 installer](https://github.com/msys2/msys2-installer/releases/latest), tweaked to keep the initial ease-of-use.
