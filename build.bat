:: UT2004 Build System For Windows
:: 
:: Expects to have been placed in the root directory of the
:: package you want to build.
:: 
:: Options:
::   BuildDir <directory> - Manually specify the root directory of the package
::     Example: C:\UT2004\MyPackage\Build\Build.bat BuildDir "C:\UT2004\MyPackage\"
::   NoInt - Do not automatically generate a .int for the package
::   NoUz - Do not automatically generate a .u.uz for the package
::   Silent - Suppresses compatibility warnings, automatically resolves them
::   NoBind - Prevents binding native functions to C++ implementations, useful when adding new natives
::   Verbose - Can be used multiple times. More verbose -> More output from script
:: 
:: Dependencies:
::   There is a way to specify dependencies.
::   First, you need to add them to the list of dependencies
::    in BuildSettings.bat, which can be found next to this
::    file.
::   Second, you need to add a new folder under
::    Build/Dependencies/ with the name of the dependency.
::   Third, place inside it all resources for the dependency
::    in the same folder structure the game expects packages
::    to be in. That means .u files need to be inside a
::    System subfolder, .utx in a Textures subfolder, etc.
::   Example:
::    Lets say you have a package called MyPackage which
::    depends on a package called MyDependency. Here is what
::    the (simplified) folder structure should look like:
::      C:\UT2004\MyPackage\
::      ├─Build\
::      │ └─Dependencies\
::      │   └─MyDependency\
::      │     ├─System\
::      │     │ └─MyDependency.u
::      │     └─Textures\
::      │       └─MyDependencyTex.utx
::      ├─Classes\
::      │ └─MyClass.uc
::      ├─Build.bat
::      └─BuildSettings.bat
:: 
:: A non-exhaustive list of reason you depend on a package:
::   - When you extend a class of another package
::      Example:
::       class MyClass extends MyDependency.CoolBaseClass;
::   - When you declare a variable/member of a type from
::     your dependency within one of your classes
::      Example:
::       var MyDependency.CoolClass MyVar;
::   - When you cast to a class from another package
::      Example:
::       MyVar = CoolClass(SomeActor);
::   - When you refer to an object from a dependency
::      Examples:
::       SomeClass = class'MyDependency.CoolClass';
::       SomeTex = Texture'MyDependency.CoolTexture';
::       SomeMesh = LodMesh'MyDependency.CoolMesh';
:: 
:: Be careful about what packages you depend on.
:: - Server admins need to install them together with your
::    package, which also means they need to redirect them
::    for people to download. More work for server admins
::    slows adoption of your package by them.
:: - Packages without obvious versioning might have multiple
::    different and incompatible versions using the same
::    name and being depended on by various other mods.
:: - Server admins might run into problems where your
::    package depends on version 2 of MyDependency, but
::    another package the server admin wants to use depends
::    on version 1 of MyDependency, which cant be resolved.
:: - As a consequence, make sure every package you release
::    has version information in the name, especially if you
::    expect to be depended on by someone else.
::
:: PostBuildHook:
::   PostBuildHook.bat is executed after a successful build
::    if it exists next to this file. This is intended for
::    use with automation, like, for example, updating a
::    server with the shiny new version of MyPackage that
::    was just built.
::   For this reason PostBuildHook.bat should not be
::    archived in version control or shared with others.
::
::   If the NoBind option is specified, PostBuildHook will
::    never be called because NoBind is an intermediary step
::    towards the final package.
::
@echo off
setlocal enabledelayedexpansion enableextensions

set BUILD_DIR=%~dp0
set BUILD_NOINT=0
set BUILD_NOUZ=0
set BUILD_SILENT=0
set BUILD_NOBIND=0
set BUILD_BYTEHAX=0
set VERBOSE=0

:ParseArgs
    if /I "%1" EQU "NoInt"    ( set BUILD_NOINT=1 )
    if /I "%1" EQU "NoUz"     ( set BUILD_NOUZ=1 )

    if /I "%1" EQU "Silent"   ( set BUILD_SILENT=1 )
    if /I "%1" EQU "NoBind"   ( set BUILD_NOBIND=1 )
    if /I "%1" EQU "ByteHax"  ( set BUILD_BYTEHAX=1 )

    if /I "%1" EQU "Verbose"  ( set /A VERBOSE+=1 )

    if /I "%1" EQU "BuildDir" (
        set BUILD_DIR=%~f2
        shift /1
    )
    
    shift /1
    if [%1] NEQ [] goto ParseArgs

if %VERBOSE% GEQ 3 echo on

call :SetPackageName "%BUILD_DIR%."
call "%~dp0BuildSettings.bat"

set BUILD_TEMP=%BUILD_DIR%Build\Temp\
if not exist "%BUILD_TEMP%" mkdir "%BUILD_TEMP%"

if %VERBOSE% GEQ 1 (
    echo PACKAGE_NAME=%PACKAGE_NAME%
    echo DEPENDENCIES=%DEPENDENCIES%
    echo BUILD_DIR=%BUILD_DIR%
    echo BUILD_TEMP=%BUILD_TEMP%
    echo BUILD_NOINT=%BUILD_NOINT%
    echo BUILD_NOUZ=%BUILD_NOUZ%
    echo BUILD_SILENT=%BUILD_SILENT%
    echo BUILD_NOBIND=%BUILD_NOBIND%
    echo BUILD_BYTEHAX=%BUILD_BYTEHAX%
    echo VERBOSE=%VERBOSE%
)

call "%BUILD_DIR%Build\CreateVersionInfo.bat" %PACKAGE_NAME% dev %PACKAGE_NAME%

pushd "%BUILD_DIR%..\System"

set MAKEINI="%BUILD_TEMP%make.ini"
set MAKELOG="%BUILD_TEMP%make.log"
call :GenerateMakeIni %MAKEINI% %DEPENDENCIES% %PACKAGE_NAME%
call :PrepareDependencies %DEPENDENCIES%
call :PrepareUnrealscriptSource
if ERRORLEVEL 1 goto compile_failed

:: make sure to always rebuild the package
:: New package GUID, No doubts about staleness
if exist "%PACKAGE_NAME%.u" del "%PACKAGE_NAME%.u"
if exist "%PACKAGE_NAME%.ucl" del "%PACKAGE_NAME%.ucl"

set MAKE_PARAMS=-ini=%MAKEINI% -log=%MAKELOG%

if %BUILD_SILENT% == 1 set MAKE_PARAMS=!MAKE_PARAMS! -Silent
if %BUILD_NOBIND% == 1 set MAKE_PARAMS=!MAKE_PARAMS! -NoBind
if %BUILD_BYTEHAX% == 1 set MAKE_PARAMS=!MAKE_PARAMS! -ByteHax

call :Invoke ucc make !MAKE_PARAMS!

:: dont do the post-process steps if compilation failed
if ERRORLEVEL 1 goto compile_failed

:: copy to release location
if not exist "%BUILD_DIR%System" (mkdir "%BUILD_DIR%System")
copy "%PACKAGE_NAME%.u"   "%BUILD_DIR%System" >NUL
copy "%PACKAGE_NAME%.ucl" "%BUILD_DIR%System" >NUL

if %BUILD_NOUZ% == 0 (
    :: generate compressed file for redirects
    call :Invoke ucc compress "%PACKAGE_NAME%.u"
    copy "%PACKAGE_NAME%.u.uz" "%BUILD_DIR%System" >NUL
)

if %BUILD_NOINT% == 0 (
    :: dump localization strings
    if exist "%PACKAGE_NAME%.int" del "%PACKAGE_NAME%.int" >NUL
    if exist "..\SystemLocalized\int\%PACKAGE_NAME%.int" del "..\SystemLocalized\int\%PACKAGE_NAME%.int" >NUL
    call :Invoke ucc dumpint "%PACKAGE_NAME%.u"
    if exist "%PACKAGE_NAME%.int" copy "%PACKAGE_NAME%.int" "%BUILD_DIR%System" >NUL
    if exist "..\SystemLocalized\int\%PACKAGE_NAME%.int" copy "..\SystemLocalized\int\%PACKAGE_NAME%.int" "%BUILD_DIR%System" >NUL
)

:: The reason we dont call PostBuildHook is because if youre using NoBind, this
:: is not the actual build of the package. This just generates header files for
:: C++. These are then used to build the native library thats bound to the
:: package, which can (and should) then be built without NoBind.
if %BUILD_NOBIND% == 0 (
    call :Hook "%~dp0PostBuildHook.bat"
)

echo [Finished at %Date% %Time%]

popd
endlocal
exit /B 0

:compile_failed
popd
endlocal
exit /B 1

:Hook
if exist %1 (
    @setlocal enabledelayedexpansion enableextensions
    @call %1
    @endlocal
    @if %VERBOSE% GEQ 3 (
        @echo on
    ) else (
        @echo off
    )
    
)
exit /B %ERRORLEVEL%

:Invoke
if %VERBOSE% GEQ 1 echo %*
%*
exit /B %ERRORLEVEL%

:SetPackageName
set PACKAGE_NAME=%~nx1
exit /B %ERRORLEVEL%

:: GenerateMakeIni
::  Generates an INI file for use with 'ucc make'
:: 
:: Usage:
::  call :GenerateMakeIni IniPath Packages...
::   IniPath is where to generate the ini to
::   Packages... is a variadic list of Packages (up to 254)
::    Usually the last Package is the one that you are trying to compile
::    If Package A depends on Package B, then B must appear before A in this list.
:GenerateMakeIni
    if not exist "%~dp1" mkdir "%~dp1"
    call :GenerateMakeIniPreamble %1

    :GenerateMakeIni_Loop
        if [%2] EQU [] goto GenerateMakeIni_EndLoop
        call :GenerateMakeIniDependency %1 %2
        shift /2
        goto GenerateMakeIni_Loop
    :GenerateMakeIni_EndLoop

    call :GenerateMakeIniPostscript %1
exit /B %ERRORLEVEL%

:: It is important to not have spaces before the >>.
:: Spaces will be part of the names UT parses from the INI.

:GenerateMakeIniPreamble
    echo ; Generated, DO NOT MODIFY>%1
    echo.>>%1
    echo [Engine.Engine]>>%1
    echo EditorEngine=Editor.EditorEngine>>%1
    echo.>>%1
    echo [Editor.EditorEngine]>>%1
    echo CacheSizeMegs=32>>%1
    echo EditPackages=Core>>%1
    echo EditPackages=Engine>>%1
    echo EditPackages=Fire>>%1
    echo EditPackages=Editor>>%1
    echo EditPackages=UnrealEd>>%1
    echo EditPackages=IpDrv>>%1
    echo EditPackages=UWeb>>%1
    echo EditPackages=GamePlay>>%1
    echo EditPackages=UnrealGame>>%1
    echo EditPackages=XGame_rc>>%1
    echo EditPackages=XEffects>>%1
    echo EditPackages=XWeapons_rc>>%1
    echo EditPackages=XPickups_rc>>%1
    echo EditPackages=XPickups>>%1
    echo EditPackages=XGame>>%1
    echo EditPackages=XWeapons>>%1
    echo EditPackages=XInterface>>%1
    echo EditPackages=XAdmin>>%1
    echo EditPackages=XWebAdmin>>%1
    echo EditPackages=Vehicles>>%1
    echo EditPackages=BonusPack>>%1
    echo EditPackages=SkaarjPack_rc>>%1
    echo EditPackages=SkaarjPack>>%1
    echo EditPackages=UTClassic>>%1
    echo EditPackages=UT2k4Assault>>%1
    echo EditPackages=Onslaught>>%1
    echo EditPackages=GUI2K4>>%1
    echo EditPackages=UT2k4AssaultFull>>%1
    echo EditPackages=OnslaughtFull>>%1
    echo EditPackages=xVoting>>%1
    echo EditPackages=StreamlineFX>>%1
    echo EditPackages=UTV2004c>>%1
    echo EditPackages=UTV2004s>>%1
exit /B %ERRORLEVEL%

:GenerateMakeIniPostscript
    echo.>>%1
    echo [Core.System]>>%1
    echo SavePath=../Save>>%1
    echo CachePath=../Cache>>%1
    echo CacheExt=.uxx>>%1
    echo CacheRecordPath=../System/*.ucl>>%1
    echo MusicPath=../Music>>%1
    echo SpeechPath=../Speech>>%1
    echo Paths=../System/*.u>>%1
    echo Paths=../Maps/*.ut2>>%1
    echo Paths=../Textures/*.utx>>%1
    echo Paths=../Sounds/*.uax>>%1
    echo Paths=../Music/*.umx>>%1
    echo Paths=../StaticMeshes/*.usx>>%1
    echo Paths=../Animations/*.ukx>>%1
    echo Paths=../Saves/*.uvx>>%1
exit /B %ERRORLEVEL%

:GenerateMakeIniDependency
    echo EditPackages=%2>>%1
exit /B %ERRORLEVEL%

:PrepareDependencies
    if [%1] EQU [] exit /B %ERRORLEVEL%
    if exist "%BUILD_DIR%Build/Dependencies/%1/" (
    	if %VERBOSE% GEQ 1 echo Copying Dependency %1
        if %VERBOSE% GEQ 1 (
        	robocopy "%BUILD_DIR%Build/Dependencies/%1/" .. *.* /S /NJH /NJS /NS /NC /NP
        ) else (
        	robocopy "%BUILD_DIR%Build/Dependencies/%1/" .. *.* /S >NUL
        )
    ) else (
        echo "Could not locate dependency '%1' in '%BUILD_DIR%Build/Dependencies/'"
    )
    shift /1
    goto PrepareDependencies
exit /B %ERRORLEVEL%

:PrepareUnrealscriptSource
if not exist "%BUILD_DIR%Classes" mkdir "%BUILD_DIR%Classes"

for /f "delims=" %%f in ('dir "%BUILD_DIR%Classes\*" /b') do (
    if [%%f] NEQ [VersionInfo.uc] (
        del "%BUILD_DIR%Classes\%%f" >NUL
    )
)

for /f "delims=" %%f in ('dir "%BUILD_DIR%USrc\*" /a:-d /s /b') do (
    if EXIST "%BUILD_DIR%Classes\%%~nxf" (
        echo ERROR: %BUILD_DIR%Classes\%%~nxf already exists
        exit /B 1
    )
    copy /-Y "%%f" /B "%BUILD_DIR%Classes" /B >NUL
)
exit /B %ERRORLEVEL%
