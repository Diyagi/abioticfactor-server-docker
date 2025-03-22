#!/bin/bash

declare -A characters

LogParser() {
    while IFS= read -r line; do
        if [[ "$line" =~ LogAbiotic:\ Display:\ CHAT\ LOG:\ (.*) ]]; then
            chat_log="${BASH_REMATCH[1]}"

            [[ "${DISCORD_CHAT_LOG_ENABLED,,}" == false ]] && return 0

            SendDiscordMessage "" "$chat_log" "$DISCORD_CHAT_LOG_COLOR"
        fi

        if [[ "$line" =~ LogAbiotic:\ Warning:\ Session\ short\ code:\ (.*) ]]; then
            [[ "${DISCORD_SERVER_START_ENABLED,,}" == false ]] && return 0

            # Extract Game ID
            short_code="${BASH_REMATCH[1]}"
            world_name="${GSWORLDSAVENAME:-Cascade}"

            # Build message from vars and send message
            message=$(world_name="$world_name" short_code="$short_code" envsubst <<<"$DISCORD_SERVER_START_MESSAGE")
            SendDiscordMessage "$DISCORD_SERVER_START_TITLE" "$message" "$DISCORD_SERVER_START_COLOR"
        fi
    done
}