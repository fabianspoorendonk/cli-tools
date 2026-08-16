@echo off
setlocal EnableExtensions

rem Command configuration
set "COMMAND_DIR=%~dp0"
set "COMMAND_NAME=%~n0"

rem Container configuration
set "CONTAINER_IMAGE=docker.io/rhysd/actionlint@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667"

rem Container run options

rem Container command arguments
set "CONTAINER_COMMAND_ARGS=%*"

rem Run container
set "CONTAINER_RUN=%COMMAND_DIR%..\lib\container.cmd"
call "%CONTAINER_RUN%" "%CONTAINER_IMAGE%"
exit /b %ERRORLEVEL%
