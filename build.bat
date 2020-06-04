@echo off
setlocal enabledelayedexpansion enableextensions
set BUILD_DIR=%~dp0

for /f "delims=" %%X IN ('dir /B /A /S *') DO (
	for %%D in ("%%~dpX\.") do (
		set PACKAGE_NAME=%%~nxD
		goto FoundPkgName
	)
)

:FoundPkgName
pushd %BUILD_DIR%

:: clean up old version so whats there is never stale
del System\%PACKAGE_NAME%.u
del System\%PACKAGE_NAME%.ucl
del System\%PACKAGE_NAME%.int
del System\%PACKAGE_NAME%.u.uz2

cd ..\System

:: make sure to always rebuild the package
del %PACKAGE_NAME%.u
del %PACKAGE_NAME%.ucl

ucc make

:: dont do the post-process steps if compilation failed
if ERRORLEVEL 1 goto cleanup

:: Merges packages loaded using #exec OBJ LOAD into the .u
ucc packageflag %PACKAGE_NAME%.u %BUILD_DIR%System\%PACKAGE_NAME%.u +BrokenLinks
:: Generate compressed file for redirects
ucc compress %BUILD_DIR%System\%PACKAGE_NAME%.u
:: Dump i18n strings
ucc dumpint %BUILD_DIR%System\%PACKAGE_NAME%.u

copy %PACKAGE_NAME%.int %BUILD_DIR%System >NUL
copy %PACKAGE_NAME%.ucl %BUILD_DIR%System >NUL

:cleanup
popd
endlocal