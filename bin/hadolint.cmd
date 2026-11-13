@echo off
setlocal EnableExtensions

rem Command configuration
set "COMMAND_DIR=%~dp0"
set "COMMAND_NAME=%~n0"

rem Container configuration
set "CONTAINER_IMAGE=docker.io/hadolint/hadolint@sha256:30a8fd2e785ab6176eed53f74769e04f125afb2f74a6c52aef7d463583b6d45e"

rem Container run options
set "CONTAINER_RUN_OPTIONS_INTERACTIVE=1"

rem Container command arguments
set "CONTAINER_COMMAND_ARGS=/bin/hadolint %*"

rem Run container
set "CONTAINER_RUN=%COMMAND_DIR%..\lib\container.cmd"
call "%CONTAINER_RUN%" "%CONTAINER_IMAGE%"
exit /b %ERRORLEVEL%