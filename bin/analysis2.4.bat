
setlocal
pushd..
set CCPNMR_TOP_DIR=%CD%
popd
set ANACONDA3=%CCPNMR_TOP_DIR%\miniconda
set PYTHONPATH=.;%CCPNMR_TOP_DIR%\ccpnmr2.4\python
set PATH=%CCPNMR_TOP_DIR%\bin:${PATH}
set LD_LIBRARY_PATH=%ANACONDA3%\Lib

set ANALYSIS="%CCPNMR_TOP_DIR%"\ccpnmr2.4\python\ccpnmr\analysis\AnalysisGui.py
"%ANACONDA3%"\python -i -O -W ignore::DeprecationWarning "%ANALYSIS%" $*
endlocal