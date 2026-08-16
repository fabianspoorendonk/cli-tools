@echo off
setlocal

rem Command configuration
set "COMMAND_DIR=%~dp0"
set "COMMAND_NAME=%~n0"

rem Container configuration
set "CONTAINER_IMAGE=ghcr.io/jqlang/jq@sha256:4f34c6d23f4b1372ac789752cc955dc67c2ae177eb1b5860b75cdc5091ce6f91"

rem Container run options
set "CONTAINER_RUN_OPTIONS_INTERACTIVE=1"

rem Container command arguments
set "CONTAINER_COMMAND_ARGS=%*"

rem Run container
set "CONTAINER_RUN=%COMMAND_DIR%..\lib\container.cmd"
call "%CONTAINER_RUN%" "%CONTAINER_IMAGE%"
exit /b %ERRORLEVEL%
