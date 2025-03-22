#!/bin/bash
source "${SCRIPTSDIR}/helper-functions.sh"

# Switch to workdir
cd "${STEAMAPPDIR}" || exit

### Function for gracefully shutdown
function shutdown_server {

    WinHexPID=$(winedbg --command "info proc" | grep -Po '^\s*\K.{8}(?=.*AbioticFactorServer-Win64-Shipping\.exe)')
    wine64 cmd.exe /C "taskkill /pid $(( 0x$WinHexPID ))"
    wineserver -w

    if [[ -n "$xvfbpid" ]]; then
        kill $xvfbpid
        wait $xvfbpid
    fi

    # Sends stop message
    if [[ "${DISCORD_SERVER_STOP_ENABLED,,}" == true ]]; then
        wait=true
        SendDiscordMessage "$DISCORD_SERVER_STOP_TITLE" "$DISCORD_SERVER_STOP_MESSAGE" "$DISCORD_SERVER_STOP_COLOR" "$wait"
    fi
}

trap shutdown_server SIGTERM

LogAction "Compiling Parameters"
source "${SCRIPTSDIR}/compile-parameters.sh"

LogAction "Starting Server"

LogInfo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &
xvfbpid=$!

LogInfo "Launching wine64 Abiotic Factor"
export DISPLAY=:0.0
export WINEDEBUG=fixme-all
wine64 "${STEAMAPPSERVER}/AbioticFactor/Binaries/Win64/AbioticFactorServer-Win64-Shipping.exe" "${params[@]}" &

WinePID=$!

source "${SCRIPTSDIR}/logfile-parser.sh"
tail --pid "$WinePID" -f "${STEAMAPPSERVER}/AbioticFactor/Saved/Logs/AbioticFactor.log" | LogParser &

wait $WinePID
