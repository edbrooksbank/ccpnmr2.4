@setlocal
@call "paths.bat"

@set ANALYSIS="%CCPNMR_TOP_DIR%\%PYTHONFOLDER%"\python\ccpnmr\analysis\AnalysisGui.py
@"%ANACONDA3%"\python -i -O -W ignore::DeprecationWarning "%ANALYSIS%" %*
@endlocal
