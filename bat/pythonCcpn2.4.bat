@echo off
setlocal
call "paths"

"%ANACONDA3%"\python -O %*
endlocal
