@echo off
setlocal enabledelayedexpansion enableextensions
set BUILD_DIR=%~dp0

pushd "%BUILD_DIR%"

for /f "delims=" %%X IN ('dir /B /A /S *') DO (
	for %%D in ("%%~dpX\.") do (
		set PACKAGE_NAME=%%~nxD
		goto FoundPkgName
	)
)

:FoundPkgName
pushd ..\System

:: make sure to always rebuild the package
:: New package GUID, No doubts about staleness
del %PACKAGE_NAME%.u
del %PACKAGE_NAME%.ucl

ucc make -ini="%BUILD_DIR%make.ini"

popd
:: dont do the post-process steps if compilation failed
if ERRORLEVEL 1 goto cleanup
pushd ..\System

:: Generate compressed file for redirects
ucc compress %PACKAGE_NAME%.u

:: Dump i18n strings
del %PACKAGE_NAME%.int
ucc dumpint %PACKAGE_NAME%.u

:: copy to release location
copy %PACKAGE_NAME%.u     "%BUILD_DIR%System" >NUL
copy %PACKAGE_NAME%.ucl   "%BUILD_DIR%System" >NUL
copy %PACKAGE_NAME%.int   "%BUILD_DIR%System" >NUL
copy %PACKAGE_NAME%.u.uz2 "%BUILD_DIR%System" >NUL

popd

if exist "PostBuildHook.bat" call "PostBuildHook.bat"

:cleanup
popd
endlocal
