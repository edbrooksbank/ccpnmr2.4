@echo off
setlocal
call "%~dp0\paths"

"%ANACONDA3%"\python -O %*
endlocal
