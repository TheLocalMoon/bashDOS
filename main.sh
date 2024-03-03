#!/bin/bash
source "dep_plg.sh"

version="0.11"
reset_color="\033[0m"

declare -A commands
command_list="exit say color history"
command_history=()
history_limit=10

colors=("red" "green" "yellow" "blue" "magenta" "cyan" "white" "custom")
declare -A color_codes=(
    ["red"]="31"
    ["green"]="32"
    ["yellow"]="33"
    ["blue"]="34"
    ["magenta"]="35"
    ["cyan"]="36"
    ["white"]="37"
    ["custom"]="38;2;128;128;128"
)

plugins_dir="plugins"
plugin_files=()

for file in "$plugins_dir"/*; do
    if [[ -f "$file" ]]; then
        source "$file"
        echo "Loaded plugin: $(basename "$file")"
    fi
done

clear

echo -e "\033[33mWelcome to bashDOS $version\033[0m"
echo "Type 'HELP' for a list of commands."

while true; do
    read -r -p ">> " full_command
    
    if [ -z "$full_command" ]; then
        continue
    fi

    read -ra command_args <<< "$full_command"
    command="${command_args[0]}"
    args="${command_args[@]:1}"

    command_lower=$(echo "$command" | awk '{print tolower($0)}')
    command_history+=("$full_command")

    case "$command_lower" in
        "exit")
            echo "cya!"
            exit 0
            ;;
        "help")
            echo "Available commands:"
            for cmd in $command_list; do
                echo "  - $cmd"
            done
            ;;
        "say")
            echo "${args[*]}"
            ;;
        "color")
            if [ -z "$current_color" ]; then
                current_color="\e[37m"
            fi

            if [ "${command_args[1]}" == "custom" ]; then
                read -p "Enter HEX color code: " hex_color_input
                if [[ "$hex_color_input" =~ ^[0-9A-Fa-f]{6}$ ]]; then
                    hex_color="${hex_color_input}"
                    current_color="\e[38;2;$(printf "%d;%d;%d" 0x${hex_color:0:2} 0x${hex_color:2:2} 0x${hex_color:4:2})m"
                    echo -e "$current_color"
                else
                    echo "Unable to parse HEX"
                fi
            else
                if [ -z "${command_args[@]:1}" ]; then
                    echo -e "Available colors:"
                    for color in "${colors[@]}"; do
                        color_name="$color"
                        color_value="${color_codes[$color]}"

                        if [ "$color_name" == "$args" ]; then
                            bold_color_name="\e[1m$color_name$reset_color"
                        else
                            bold_color_name="$color_name"
                        fi

                        echo -e "  - \e[${color_value}m$bold_color_name$reset_color"
                    done
                else
                    color_code="${color_codes[${args[0]}]}"
                    if [ -n "$color_code" ]; then
                        current_color="\e[${color_code}m"
                        echo -e "$current_color"
                    else
                        echo -e "\e[31mUnknown color, type 'color' for a list of colors\e[0m"
                        current_color=""
                    fi
                fi
            fi
            ;;



        "history")
            if [ ${#command_history[@]} -eq 0 ]; then
                echo "You didn't enter any commands yet."
            else
                if [ "${#command_history[@]}" -gt "$history_limit" ]; then
                    items_to_remove=$(( ${#command_history[@]} - history_limit ))
                    command_history=("${command_history[@]:$items_to_remove}")
                fi
        
                echo "Command History:"
                for item in "${command_history[@]}"; do
                    echo "- $item"
                done
            fi
            ;;
        *)
            if [ -z "$current_color" ]; then
                current_color="\e[37m"
            fi
            if [[ "$full_command" == *"<"* ]]; then
                echo -e "\033[32myes\033[0m"
            elif [[ "$full_command" == *">"* ]]; then
                echo -e "\033[31mno\033[0m"
            else
                if [[ ! -n "${commands[$command]}" && ! "$full_command" =~ ^[0-9+-/*]+$ ]]; then
                    echo -e "\033[31mbashDOS $version: $command: unknown operation$current_color"
                else
                    if [[ $command =~ ^[0-9+-/*]+$ ]]; then
                        if [[ "$full_command" == *"*"* ]]; then
                            IFS='*' read -ra num_array <<< "$full_command"
                            result=1
                            for num in "${num_array[@]}"; do
                                result=$((result * num))
                            done
                            if ((result > 1000000000000 || result < -1000000000000)); then
                                printf "%e\n" "$result"
                            else
                                echo "$result"
                            fi
                        else
                            result=$(( $command ))
                            if ((result > 1000000000000 || result < -1000000000000)); then
                                printf "%e\n" "$result"
                            else
                                echo "$result"
                            fi
                        fi
                    else
                        if [ -z "$current_color" ]; then
                            current_color="\e[37m"
                        fi

                        command_history+=("$full_command")
                        if [ ${#command_history[@]} -gt $history_limit ]; then
                            command_history=("${command_history[@]:1}")
                        fi

                        if [[ -n "${commands[$command]}" ]]; then
                            eval "${commands[$command]}"
                        fi
                    fi
                fi
            fi
            ;;
    esac
done
