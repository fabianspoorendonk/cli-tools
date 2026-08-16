@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "CONTAINER_IMAGE=%~1"
if not defined CONTAINER_IMAGE (
    call :fail 64 "The container image was not specified."
    exit /b !ERRORLEVEL!
)
if not defined COMMAND_NAME set "COMMAND_NAME=container"
where podman >nul 2>&1
if errorlevel 1 (
    call :fail 127 "Podman was not found on PATH."
    exit /b !ERRORLEVEL!
)
rem Wrappers provide the remaining container options and command arguments through CONTAINER_* variables.
if not defined CONTAINER_RUN_OPTIONS_MOUNT_MODE set "CONTAINER_RUN_OPTIONS_MOUNT_MODE=ro"
if not defined CONTAINER_HOST_WORKSPACE set "CONTAINER_HOST_WORKSPACE=%CD%"
set "ERROR_FILE=%TEMP%\cli-tools-%COMMAND_NAME%-%RANDOM%.err"
set "INTERACTIVE_OPTION="
if "%CONTAINER_RUN_OPTIONS_INTERACTIVE%"=="1" set "INTERACTIVE_OPTION=--interactive"
set "CONFIG_MOUNT="
if defined CONTAINER_CONFIG_FILE set CONFIG_MOUNT=--volume "%CONTAINER_CONFIG_FILE%:/config/.markdownlint-cli2.yaml:ro"

podman run --rm --pull=missing ^
    --network none ^
    --read-only ^
    --cap-drop all ^
    --security-opt no-new-privileges ^
    --pids-limit 128 ^
    --tmpfs /tmp:rw,noexec,nosuid,nodev,size=64m ^
    !INTERACTIVE_OPTION! ^
    --volume "%CONTAINER_HOST_WORKSPACE%:/workspace:%CONTAINER_RUN_OPTIONS_MOUNT_MODE%" ^
    !CONFIG_MOUNT! ^
    --workdir /workspace ^
    "%CONTAINER_IMAGE%" %CONTAINER_COMMAND_ARGS% 2>"%ERROR_FILE%"
set "RUN_ERROR=%ERRORLEVEL%"
if "!RUN_ERROR!"=="0" (
    del /q "%ERROR_FILE%" >nul 2>&1
    exit /b 0
)
findstr /i /c:"cannot connect to Podman" /c:"unable to connect to Podman" /c:"connection refused" "%ERROR_FILE%" >nul
if errorlevel 1 (
    call :fail !RUN_ERROR!
    exit /b !ERRORLEVEL!
)
if defined CLI_TOOLS_RETRY_ATTEMPTED (
    call :fail !RUN_ERROR!
    exit /b !ERRORLEVEL!
)
call :container_platform_recover
if errorlevel 1 (
    exit /b !ERRORLEVEL!
)
del /q "%ERROR_FILE%" >nul 2>&1
set "CLI_TOOLS_RETRY_ATTEMPTED=1"
call "%~f0" "%CONTAINER_IMAGE%"
exit /b !ERRORLEVEL!

:fail
if not "%~2"=="" echo %COMMAND_NAME%: %~2 1>&2
if defined ERROR_FILE (
    if exist "%ERROR_FILE%" type "%ERROR_FILE%" 1>&2
    del /q "%ERROR_FILE%" >nul 2>&1
)
exit /b %~1

:container_platform_recover
echo %COMMAND_NAME%: Starting the Podman machine... 1>&2
podman machine start >nul 2>&1
if errorlevel 1 (
    call :fail 125 "The Podman engine could not be started."
    exit /b !ERRORLEVEL!
)
exit /b 0
