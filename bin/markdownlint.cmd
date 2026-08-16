@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Command configuration
set "COMMAND_DIR=%~dp0"
set "COMMAND_NAME=%~n0"

rem Container configuration
set "CONTAINER_IMAGE=docker.io/davidanson/markdownlint-cli2@sha256:842f9e9b3db4ab11215a856e69e773eaa19cbf3bb2f51242aa8945ef80439445"
set "CONTAINER_CONFIG_FILE=%COMMAND_DIR%..\config\markdownlint-cli2.yaml"

rem Parse command arguments
for %%A in (%*) do (
    if /i "%%~A"=="--fix" set "CONTAINER_RUN_OPTIONS_MOUNT_MODE=rw"
    if /i "%%~A"=="--help" set "CONTAINER_COMMAND_ARGS_HAS_HELP=1"
    if /i "%%~A"=="-h" set "CONTAINER_COMMAND_ARGS_HAS_HELP=1"
    if "%%~A"=="-" set "CONTAINER_COMMAND_ARGS_HAS_GLOB=1"
    if not "%%~A"=="" if not "%%~A:~0,1"=="-" set "CONTAINER_COMMAND_ARGS_HAS_GLOB=1"
)

rem Container run options
if not defined CONTAINER_RUN_OPTIONS_MOUNT_MODE set "CONTAINER_RUN_OPTIONS_MOUNT_MODE=ro"

rem Container command arguments
if not defined CONTAINER_COMMAND_ARGS_HAS_GLOB set "CONTAINER_COMMAND_ARGS_HAS_GLOB=0"
set "CONTAINER_COMMAND_ARGS=--config /config/.markdownlint-cli2.yaml %*"
if defined CONTAINER_COMMAND_ARGS_HAS_HELP set "CONTAINER_COMMAND_ARGS=%*"
if not defined CONTAINER_COMMAND_ARGS_HAS_HELP if "!CONTAINER_COMMAND_ARGS_HAS_GLOB!"=="0" set "CONTAINER_COMMAND_ARGS=!CONTAINER_COMMAND_ARGS! **/*.md"

rem Run container
set "CONTAINER_RUN=%COMMAND_DIR%..\lib\container.cmd"
call "%CONTAINER_RUN%" "%CONTAINER_IMAGE%"
exit /b !ERRORLEVEL!
