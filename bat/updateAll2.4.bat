@echo off
setlocal
call "paths"

set ENTRYMODULE="%CCPNMR_TOP_DIR%\%PYTHONFOLDER%"\python\ccpnmr\update\UpdateAuto.py
"%ANACONDA3%"\python -i -O -W ignore::DeprecationWarning "%ENTRYMODULE%" %*
endlocal
