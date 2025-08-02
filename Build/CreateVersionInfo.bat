@setlocal enabledelayedexpansion enableextensions

set INFO_FILE="%BUILD_DIR%Classes/VersionInfo.uc"

if not exist "%BUILD_DIR%Classes" mkdir "%BUILD_DIR%Classes"

@if NOT EXIST %INFO_FILE% (
	@echo PackageBaseName="%1"
	@echo PackageVersion="%2"
	@echo PackageName="%3"

	 echo class VersionInfo extends Info;>%INFO_FILE%
	@echo.>>%INFO_FILE%
	@echo var string PackageBaseName;>>%INFO_FILE%
	@echo var string PackageVersion;>>%INFO_FILE%
	@echo var string PackageName;>>%INFO_FILE%
	@echo.>>%INFO_FILE%
	@echo defaultproperties {>>%INFO_FILE%
	@echo     PackageBaseName="%1">>%INFO_FILE%
	@echo     PackageVersion="%2">>%INFO_FILE%
	@echo     PackageName="%3">>%INFO_FILE%
	@echo }>>%INFO_FILE%
	@echo.>>%INFO_FILE%
)

@endlocal
