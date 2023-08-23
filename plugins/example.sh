#!/bin/bash

# Get the plugin name from the file name
plugin_name=$(basename "$0" .sh)

# Define the command function
function main_example() {
    #echo "Hello from $plugin_name plugin's custom 'example' command!"
    echo "eggings"
}

# Use createcommand() to add 'example'
createcommand "example"

echo "Plugin '$plugin_name' loaded."
