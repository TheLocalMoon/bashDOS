#!/bin/bash

function createcommand() {
    local command_name="$1"
    local function_name="${plugin_name}_${command_name}"
    commands["$command_name"]="$function_name"
    command_list="$command_list $command_name"
}

function load_plugin_files() {
    local plugins_dir="$1"
    local plugin_files=()

    for file in "$plugins_dir"/*; do
        if [[ -f "$file" ]]; then
            plugin_files+=("$file")
        fi
    done

    echo "${plugin_files[@]}"
}

function load_plugins() {
    local plugin_files=("$@")
    
    for file in "${plugin_files[@]}"; do
        source "$file"
        echo "Loaded plugin: $(basename "$file")"
    done
}

function plugin_hook() {
    local hook_name="$1"
    shift
    local hook_function
    for plugin in "${loaded_plugins[@]}"; do
        hook_function="${plugin}_${hook_name}"
        if [[ $(type -t "$hook_function") == "function" ]]; then
            "$hook_function" "$@"
        fi
    done
}