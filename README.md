#tm-win-builder

This repository provides tools to compile TeXmacs for windows, and a resulting executable zip that can install TeXmacs on a windows machine.

The build process is done using the [MSys2/Mingw-w32/Mingw-w64](https://sourceforge.net/p/msys2/wiki/MSYS2%20introduction/) environment.
The setup of the environment, the compilation and the packaging is done in a single step (no complicated how-to to follow!) by running the XXX executable. This whole stuff is essentially a modified version of the Git for Windows SDK (many thanks to them for making this so easy).


##Pros

- fully automated building of TeXmacs on windows : no prior experience in compiling is needed. Much simpler than the official method.

- No need to wait for the next official release of TeXmacs to test novelties and enjoy the bugfixes.

- A spell checker is bundled with TeXmacs (additional dictionaries require manual install, though).

- This version of TeXmacs can be used as an "equation editor" for Inkscape

- Latest versions of the dependencies are used (notably Ghostscript).

- Once the compilation is over, an up-to-date, full-featured build environment remains available for building an updated version later on (saving the long download and install), or for those willing to tweak the code or customize their own TeXmacs installation (familiarity with unix-like environment needed). This environment can also be used for building other great opensource softwares.

- This building environment is not frozen in time: it will be still valid when TeXmacs switches to Qt5, for instance. 


##Cons

- The resulting TeXmacs installation is larger than the official one, with many more dlls.

- The sdk is HUGE on disk.

- If there is an issue with this build, it should be filed here before reporting it to the official site.


##Requirements

- Disk space needed for the building environment : nearly 5 GB. I made no attempt to minimize its size. It can probably be reduced at least by half. 

- Internet access (with large bandwidth, preferably)

- Beyond the download times, the more cpu cores, the better. As an indication, with 250 Mb/s internet bandwith and 8-core cpu, the complete process takes ~30 min.


##Key files that drive the build process (where to look in case of problems)

After unpacking XXX, the setup-tm-sdk.bat batch file is run. It will download and setup the build environment, open an MSys2 shell and run the build-tm.sh script in it.

build-tm.sh will 

- invoke pacman to download readily-built dependencies needed by TeXmacs (qt4, freetype, ...).

- (re-)build three of the dependencies from source using makepkg-mingw: poppler-qt4 (the readily-built package has an option that prevents TeXmacs to start), wget and guile1.8 (that are not available already built - for guile we use the sibbling repo [mingw-w64-guile1.8]())

- pull the sibbling repo [mingw-w64-texmacs]() and invoke makepkg-mingw to build it. The details of the build options are set in the PKGBUILD of that repo : it will pull the latest svn source, possibly apply patches, then compile, and finally bundle everything that is needed to install on a windows machine in an executable zip file, making a poor man's installer.
