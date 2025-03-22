#!/bin/bash

WinHexPID=$(winedbg --command "info proc" | grep -Po '^\s*\K.{8}(?=.*AbioticFactorServer-Win64-Shipping\.exe)')
wine cmd.exe /C "taskkill /pid $(( 0x$WinHexPID ))"
wineserver -w

exit
