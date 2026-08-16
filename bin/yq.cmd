@echo off
setlocal

rem Command configuration
set "COMMAND_DIR=%~dp0"
set "COMMAND_NAME=%~n0"

rem Container configuration
set "CONTAINER_IMAGE=docker.io/mikefarah/yq@sha256:11a1f0b604b13dbbdc662260d8db6f644b22d8553122a25c1b5b2e8713ca6977"

rem Container run options
set "CONTAINER_RUN_OPTIONS_INTERACTIVE=1"

rem Container command arguments
set "CONTAINER_COMMAND_ARGS=%*"

rem Run container
set "CONTAINER_RUN=%COMMAND_DIR%..\lib\container.cmd"
call "%CONTAINER_RUN%" "%CONTAINER_IMAGE%"
exit /b %ERRORLEVEL%
