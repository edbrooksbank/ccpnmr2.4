@echo off
setlocal
call "paths.bat"

set ENTRYMODULE="%CCPNMR_TOP_DIR%\%VERSIONPATH%"\python\cambridge\dangle\DangleGui.py
"%ANACONDA3%"\python -i -O -W ignore::DeprecationWarning "%ENTRYMODULE%" %*
endlocal
