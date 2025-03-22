#!/bin/bash
source "${SCRIPTSDIR}/helper-functions.sh"

mkdir -p "${STEAMAPPSERVER}" || true

if ! [ -w "${STEAMAPPSERVER}" ]; then
    LogError "${STEAMAPPSERVER} is not writable."
    exit 1
fi

LogAction "Running SteamCMD"

# Initialize arguments array
args=(
    "+@sSteamCmdForcePlatformType" "windows"
    "+@sSteamCmdForcePlatformBitness" "64"
    "+force_install_dir" "$STEAMAPPSERVER"
    "+login" "anonymous"
    "+app_update" "$STEAMDEDICATEDAPPID" "validate"
)

# Add the quit command
args+=("+quit")

/home/steam/steamcmd/steamcmd.sh "${args[@]}"

exec bash "${SCRIPTSDIR}/launch.sh"
