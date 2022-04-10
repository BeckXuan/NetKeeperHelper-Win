@echo off
mode con cols=20 lines=6
cd /d %~dp0
python Netkeeper.py
echo.
pause.
