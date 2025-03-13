#!/bin/bash

# This scripts compiles parameters from an set of ENV variables to an array
# this should be run with source, so the params ENV becomes avaliable.

# Function to add arguments to parameter array
# usage: add_param <name> <$env_value>
add_param() {
    local param_name="$1"
    local param_value="$2"

    if [ -n "$param_value" ]; then
        params+=("$param_name"="$param_value")
    fi
}

params=(
    "-log"
    "-newconsole"
    "-useperfthreads"
    "-NoAsyncLoadingThread"
    "-UseMultithreadForDS"
    "-NumberOfWorkerThreadsServer"="$(nproc --all)"
)

add_param "-MaxServerPlayers"      "${GSMAXSERVERPLAYERS}"
add_param "-Port"                  "${GSPORT}"
add_param "-QueryPort"             "${GSQUERYPORT}"
add_param "-ServerPassword"        "${GSSERVERPASSWORD}"
add_param "-SteamServerName"       "${GSSERVERNAME}"
add_param "-WorldSaveName"         "${GSWORLDSAVENAME}"

echo "${params[@]}"
