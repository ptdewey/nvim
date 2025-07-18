#!/usr/bin/env bash

if [[ "$(basename "$PWD")" != "nvim" ]]; then
    git clone "https://github.com/ptdewey/nvim.git"
    cd nvim || exit 1
fi

if [[ -L "${HOME}/.config/nvim" ]]; then
    rm "${HOME}/.config/nvim"
fi

ln -s "$(pwd)" "${HOME}/.config/nvim"
