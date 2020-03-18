@echo off
setlocal
call "%~dp0\paths"

set ENTRYMODULE="%CCPNMR_TOP_DIR%\%VERSIONPATH%"\python\ccpnmr\format\gui\DataShifter.py
"%ANACONDA3%"\python -i -O -W ignore "%ENTRYMODULE%" %*
endlocal
