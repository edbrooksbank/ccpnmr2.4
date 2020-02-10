@setlocal
@call "paths.bat"

@set DANGLEGUI="%CCPNMR_TOP_DIR%\%PYTHONFOLDER%"\python\cambridge\dangle\DangleGui.py
@"%ANACONDA3%"\python -i -O -W ignore::DeprecationWarning "%DANGLEGUI%" %*
@endlocal
