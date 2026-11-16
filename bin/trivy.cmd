@echo off
setlocal EnableExtensions

rem Command configuration
set "COMMAND_DIR=%~dp0"
set "COMMAND_NAME=%~n0"

rem Container configuration
set "CONTAINER_IMAGE=docker.io/aquasec/trivy@sha256:8f6bb947dbc528902e11f2f5be52f7b519f6a39d5d148f41166f2040499768fb"

rem Container command arguments
set "CONTAINER_COMMAND_ARGS=%*"

rem Run container
set "CONTAINER_RUN=%COMMAND_DIR%..\lib\container.cmd"
call "%CONTAINER_RUN%" "%CONTAINER_IMAGE%"
exit /b %ERRORLEVEL%