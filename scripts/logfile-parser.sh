#!/bin/bash

declare -A players

LogParser() {
    while IFS= read -r line; do
        if [[ "$line" =~ LogAbiotic:\ Display:\ CHAT\ LOG:\ (.*) ]]; then

            base_message="${BASH_REMATCH[1]}"

            if [[ "$base_message" =~ ^\ (.+)\ has\ exited\ the\ facility\.$'\r'$ ]]; then

                player_name="${BASH_REMATCH[1]}"
                steamid="${players[$player_name]}"

                unset -v 'players["$player_name"]'

                [[ "${DISCORD_PLAYER_LEAVE_ENABLED,,}" == false ]] && continue

                # Build message from vars and send message
                message=$(player_name="$player_name" steamid="$steamid" envsubst <<<"$DISCORD_PLAYER_LEAVE_MESSAGE")
                SendDiscordMessage "$DISCORD_PLAYER_LEAVE_TITLE" "$message" "$DISCORD_PLAYER_LEAVE_COLOR"

                continue
            fi

            [[ "$base_message" =~ ^\ (.+)\ has\ entered\ the\ facility\.$'\r'$ ]] && continue

            [[ "${DISCORD_CHAT_LOG_ENABLED,,}" == false ]] && continue

            chat_log="$base_message"

            SendDiscordMessage "$DISCORD_SERVER_CHAT_LOG_TITLE" "$chat_log" "$DISCORD_CHAT_LOG_COLOR"

            #TODO: Will be implemented in the future once i can differentiate system messages from player messages
            # for player in "${!players[@]}"; do
            #     if [[ "${BASH_REMATCH[1]}" == *"$player"* ]]; then
            #         player_name="$player"
            #     fi
            # done

            # if [ -z "${player_name}" ]; then
            # else
            #     [[ "${DISCORD_CHAT_LOG_ENABLED,,}" == false ]] && continue

            #     chat_log="${BASH_REMATCH[1]}"

            #     SendDiscordMessage "$DISCORD_SERVER_CHAT_LOG_TITLE" "$chat_log" "$DISCORD_CHAT_LOG_COLOR"
            # fi
        
        elif [[ $line =~ LogNet:\ Join\ request:\ /Game/Maps/ServerEntry\?Name=(.+?)\?\?PW.*ConnectID=([0-9]+)_ ]]; then

            player_name="${BASH_REMATCH[1]}"
            steamid="${BASH_REMATCH[2]}"

            players["${player_name}"]="${steamid}"

            [[ "${DISCORD_PLAYER_JOIN_ENABLED,,}" == false ]] && continue

            # Build message from vars and send message
            message=$(player_name="$player_name" steamid="$steamid" envsubst <<<"$DISCORD_PLAYER_JOIN_MESSAGE")
            SendDiscordMessage "$DISCORD_PLAYER_JOIN_TITLE" "$message" "$DISCORD_PLAYER_JOIN_COLOR"

        elif [[ "$line" =~ LogAbiotic:\ Warning:\ Session\ short\ code:\ (.*) ]]; then
            [[ "${DISCORD_SERVER_START_ENABLED,,}" == false ]] && continue

            # Extract Game ID
            short_code="${BASH_REMATCH[1]}"
            world_name="${GSWORLDSAVENAME:-Cascade}"

            # Build message from vars and send message
            message=$(world_name="$world_name" short_code="$short_code" envsubst <<<"$DISCORD_SERVER_START_MESSAGE")
            SendDiscordMessage "$DISCORD_SERVER_START_TITLE" "$message" "$DISCORD_SERVER_START_COLOR"
        fi
    done
}