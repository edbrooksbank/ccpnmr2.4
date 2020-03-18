@echo off
setlocal
call "%~dp0\paths.bat"

set ENTRYMODULE="%CCPNMR_TOP_DIR%\%VERSIONPATH%"\python\cambridge\dangle\DangleGui.py
"%ANACONDA3%"\python -i -O -W ignore "%ENTRYMODULE%" %*
endlocal
