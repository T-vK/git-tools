#!/bin/bash

if ! command -v dialog &> /dev/null; then
    # Install dependency
    if [ "$(uname)" == "Darwin" ]; then
        brew install dialog
    else
        sudo dnf install -y dialog || sudo apt-get install -y dialog
    fi
fi

PATH_EXTENSION="export PATH=\"\$PATH:$(pwd)/bin\""

if [ -f ~/.bashrc ]; then
    echo "${PATH_EXTENSION}" >> ~/.zshrc
    echo "Installed for zsh! Please open a new terminal to complete the installation..."
else
    echo "ZSH not found."
fi

if [ -f ~/.bashrc ]; then
    echo "${PATH_EXTENSION}" >> ~/.bashrc
    echo "Installed for bash! Please open a new terminal to complete the installation..."
else
    echo "Error! Bash not found!"
    exit 1
fi
