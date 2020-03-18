@echo off
setlocal
call "%~dp0\paths"

set ENTRYMODULE="%CCPNMR_TOP_DIR%\%VERSIONPATH%"\python\ccpnmr\update\UpdateAuto.py
"%ANACONDA3%"\python -i -O -W ignore "%ENTRYMODULE%" %*
endlocal
