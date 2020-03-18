@echo off
set CCPNMR_TOP_DIR=%~dp0\..

set ANACONDA3=%CCPNMR_TOP_DIR%\miniconda
set VERSIONPATH=ccpnmr2.5
set PYTHONPATH=.;%CCPNMR_TOP_DIR%\%VERSIONPATH%\python
set PATH=%ANACONDA3%\lib\site-packages\numpy\.libs;%ANACONDA3%;%ANACONDA3%\Library\mingw-w64\bin;%ANACONDA3%\Library\usr\bin;%ANACONDA3%\Library\bin;%ANACONDA3%\Scripts;%ANACONDA3%\bin;%CCPNMR_TOP_DIR%\bin;%PATH%
set LD_LIBRARY_PATH=%ANACONDA3%\lib
