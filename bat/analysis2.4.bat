
@setlocal
@pushd..
@set CCPNMR_TOP_DIR=%CD%
@popd
@set ANACONDA3=%CCPNMR_TOP_DIR%\miniconda
@set PYTHONPATH=.;%CCPNMR_TOP_DIR%\ccpnmr2.4\python
@set PATH=%ANACONDA3%\lib\site-packages\numpy\.libs;%ANACONDA3%;%ANACONDA3%\Library\mingw-w64\bin;%ANACONDA3%\Library\usr\bin;%ANACONDA3%\Library\bin;%ANACONDA3%\Scripts;%ANACONDA3%\bin;%CCPNMR_TOP_DIR%\bin;%PATH%

@set ANALYSIS="%CCPNMR_TOP_DIR%"\ccpnmr2.4\python\ccpnmr\analysis\AnalysisGui.py
@"%ANACONDA3%"\python -i -O -W ignore::DeprecationWarning "%ANALYSIS%" %*
@endlocal