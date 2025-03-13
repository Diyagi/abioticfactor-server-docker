#!/bin/bash
source "${SCRIPTSDIR}/helper-functions.sh"

# Switch to workdir
cd "${STEAMAPPDIR}" || exit

trap "$SCRIPTSDIR/shutdown-gameserver.sh" SIGTERM

LogAction "Compiling Parameters"
source "${SCRIPTSDIR}/compile-parameters.sh"

LogInfo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &

LogAction "Starting Server"

LogInfo "Launching wine64 Abiotic Factor"
DISPLAY=:0.0 wine64 "${STEAMAPPSERVER}/AbioticFactor/Binaries/Win64/AbioticFactorServer-Win64-Shipping.exe" "${params[@]}" &

WinePID=$!
wait $WinePID
