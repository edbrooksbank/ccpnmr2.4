@echo off
setlocal
call "paths"

set ENTRYMODULE="%CCPNMR_TOP_DIR%\%PYTHONFOLDER%"\python\ccp\format\spectra\params\XeasyData.py
"%ANACONDA3%"\python -i -O -W ignore::DeprecationWarning "%ENTRYMODULE%" %*
endlocal
