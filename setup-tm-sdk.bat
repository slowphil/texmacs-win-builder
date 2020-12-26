@REM Set up the texmacs SDK

@REM determine root directory

@REM https://technet.microsoft.com/en-us/library/bb490909.aspx says:
@REM <percent>~dpI Expands <percent>I to a drive letter and path only.
@REM <percent>~fI Expands <percent>I to a fully qualified path name.
@FOR /F "delims=" %%D in ("%~dp0") do @set cwd=%%~fD

@REM set PATH
@set PATH=%cwd%\usr\bin;%PATH%

@REM init msys2 repo keys etc.
@"%cwd%"\usr\bin\bash.exe --login -c exit

@REM update packages to current
@"%cwd%"\usr\bin\pacman -Syuu --noconfirm
@"%cwd%"\usr\bin\pacman -Syuu --noconfirm
@"%cwd%"\usr\bin\pacman -Syuu --noconfirm


@REM set MSYSTEM so that MSYS2 starts up in the correct mode
@set MSYSTEM=MINGW32


@REM now update the rest
@"%cwd%"\usr\bin\pacman -S --needed --noconfirm ^
	base python less openssh patch make tar diffutils ca-certificates ^
	git subversion mintty vim p7zip markdown winpty ^
 	mingw-w64-i686-toolchain ^
    base-devel
  

@IF ERRORLEVEL 1 GOTO INSTALL_REST

@REM Avoid overlapping address ranges
@IF MINGW32 == %MSYSTEM% @(
	ECHO Auto-rebasing .dll files
	CALL "%cwd%"\autorebase.bat
)



@REM Before running a shell, let's prevent complaints about "permission denied"
@REM from MSYS2's /etc/post-install/01-devices.post
@MKDIR "%cwd%"\dev\shm 2> NUL
@MKDIR "%cwd%"\dev\mqueue 2> NUL


@REM now get updated build-tm.sh, run it, finally start an interactive shell
@"%cwd%"\usr\bin\curl https://raw.githubusercontent.com/slowphil/texmacs-win-builder/master/build-tm.sh > "%cwd%"\build-tm.sh 
@bash --login -c "cd / && bash ./build-tm.sh"

	@IF ERRORLEVEL 1 PAUSE

	@start mintty -i /msys2.ico -t "texmacs SDK 32-bit" bash --login -i
)
