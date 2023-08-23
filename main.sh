#!/bin/bash

version="0.1"
reset_color="\033[0m"

declare -A commands
commands["help"]=""
commands["exit"]="cya!"
commands["say"]=""
commands["history"]=""

command_list="exit say color history"

function createcommand() {
    local command_name="$1"
    local function_name="${plugin_name}_${command_name}"
    commands["$command_name"]="$function_name"
    command_list="$command_list $command_name"
}

colors=("red" "green" "yellow" "blue" "magenta" "cyan" "white" "custom")

calc_history=()

plugins_dir="plugins"
plugin_files=()

# Load plugins
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
    read -p ">> " full_command

    if [ -z "$full_command" ]; then
        continue
    fi

    read -ra command_args <<< "$full_command"
    command="${command_args[0]}"
    args="${command_args[@]:1}"

    case "$command" in
        "exit")
            echo -e "${commands[$command]}"
            exit 0
            ;;
        "help")
            echo "Available commands:"
            for cmd in $command_list; do
                echo "  - $cmd"
            done
            ;;
        "say")
            echo "$args"
            ;;
         "color")
            if [ -z "$args" ]; then
                echo -e "Available colors:"
                for color in ${colors[@]}; do
                    case "$color" in
                        "red")
                            colored_color="\e[31m$color\e[0m"
                            ;;
                        "green")
                            colored_color="\e[32m$color\e[0m"
                            ;;
                        "yellow")
                            colored_color="\e[33m$color\e[0m"
                            ;;
                        "blue")
                            colored_color="\e[34m$color\e[0m"
                            ;;
                        "magenta")
                            colored_color="\e[35m$color\e[0m"
                            ;;
                        "cyan")
                            colored_color="\e[36m$color\e[0m"
                            ;;
                        "white")
                            colored_color="\e[37m$color\e[0m"
                            ;;
                        "custom")
                            colored_color="\e[38;2;128;128;128m$color\e[0m"
                            ;;
                        *)
                            colored_color="$color"
                            ;;
                    esac
                    echo -e "  - $colored_color"
                done
            else
                case "$args" in
                    "red")
                        current_color="\e[31m"
                        echo -e "$current_color"
                        ;;
                    "green")
                        current_color="\e[32m"
                        echo -e "$current_color"
                        ;;
                    "yellow")
                        current_color="\e[33m"
                        echo -e "$current_color"
                        ;;
                    "blue")
                        current_color="\e[34m"
                        echo -e "$current_color"
                        ;;
                    "magenta")
                        current_color="\e[35m"
                        echo -e "$current_color"
                        ;;
                    "cyan")
                        current_color="\e[36m"
                        echo -e "$current_color"
                        ;;
                    "white")
                        current_color="\e[37m"
                        echo -e "$current_color"
                        ;;
                    "custom")
                        read -p "Enter HEX color code: " hex_color_input
                        hex_color="${hex_color_input#"#"}"
                        current_color="\e[38;2;$(printf "%d;%d;%d" 0x${hex_color:0:2} 0x${hex_color:2:2} 0x${hex_color:4:2})m"
                        echo -e "$current_color"
                        ;;
                    *)
                        echo -e "\e[31mUnknown color, type 'color' for a list of colors\e[0m"
                        current_color=""
                        ;;
                esac
            fi
            ;;
        "history")
            if [ ${#calc_history[@]} -eq 0 ]; then
                echo "No calculation history available."
            else
                echo "Calculation History:"
                for entry in "${calc_history[@]}"; do
                    echo "  - $entry"
                done
            fi
            ;;
        *)
            if [[ "$full_command" == *"<"* ]]; then
                echo -e "\033[32myes\033[0m"
            elif [[ "$full_command" == *">"* ]]; then
                echo -e "\033[31mno\033[0m"
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
                    calc_history+=("$full_command = $result")
                    if [ ${#calc_history[@]} -gt 10 ]; then
                        calc_history=("${calc_history[@]:1}")
                    fi
                else
                    if [ -z "$current_color" ]; then
                        current_color="\e[37m"
                    fi
                    if [[ -n "${commands[$command]}" ]]; then
        eval "${commands[$command]}"
    else
        echo -e "\033[31mbashDOS $version: $command: unknown operation$current_color"
    fi

                fi
            fi
            ;;
    esac
done
