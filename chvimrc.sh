#!/usr/bin/env bash

app_dir=$(dirname $(readlink -f $0))

debug_mode='0'
fork_maintainer='0'

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
    msg "\e[32m[✔]\e[0m ${1}${2}"
    fi
}

error() {
    msg "\e[31m[✘]\e[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
      msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}

create_symlinks() {
    echo 'create links'

    endpath="$app_dir"

    lnif "$endpath/.vimrc"              "$HOME/.vimrc"
    lnif "$endpath/.vimrc.bundles"      "$HOME/.vimrc.bundles"
    lnif "$endpath/.vimrc.before"       "$HOME/.vimrc.before"
    lnif "$endpath/.vim"                "$HOME/.vim"

    # Useful for fork maintainers
    #touch  "$HOME/.vimrc.local"
    if [ -e "$endpath/.vimrc.local" ]; then
        ln -sf "$endpath/.vimrc.local" "$HOME/.vimrc.local"
    fi

    if [ -e "$endpath/.vimrc.before.local" ]; then
        ln -sf "$endpath/.vimrc.before.local" "$HOME/.vimrc.before.local"
    fi

    if [ -e "$endpath/.vimrc.bundles.local" ]; then
        ln -sf "$endpath/.vimrc.bundles.local" "$HOME/.vimrc.bundles.local"
    fi

    if [ -e "$endpath/.vimrc.fork" ]; then
        ln -sf "$endpath/.vimrc.fork" "$HOME/.vimrc.fork"
    elif [ "$fork_maintainer" -eq '1' ]; then
        touch "$HOME/.vimrc.fork"
        touch "$HOME/.vimrc.bundles.fork"
        touch "$HOME/.vimrc.before.fork"
    fi

    if [ -e "$endpath/.vimrc.bundles.fork" ]; then
        ln -sf "$endpath/.vimrc.bundles.fork" "$HOME/.vimrc.bundles.fork"
    fi

    if [ -e "$endpath/.vimrc.before.fork" ]; then
        ln -sf "$endpath/.vimrc.before.fork" "$HOME/.vimrc.before.fork"
    fi

    ret="$?"
    success "$1"
    debug
}

function clean_symlinks() {
    echo 'clean old links'

    rm -f  "$HOME/.vimrc"
    rm -f  "$HOME/.vimrc.bundles"
    rm -f  "$HOME/.vimrc.before"
    rm -f  "$HOME/.vim"

    rm -f "$HOME/.vimrc.local"
    rm -f "$HOME/.vimrc.before.local"
    rm -f "$HOME/.vimrc.bundles.local"
    rm -f "$HOME/.vimrc.fork"
    rm -f "$HOME/.vimrc.bundles.fork"
    rm -f "$HOME/.vimrc.before.fork"

    rm -f "$HOME/.gvimrc.local"

    ret="$?"
    success "$1"
    debug
}

case $1 in
    vimrc )
        echo 'using vimrc'
        clean_symlinks
        ln -sf "$HOME/vimrc/.vimrc" "$HOME/.vimrc"
        ln -sf "$HOME/vimrc/.vim" "$HOME/.vim"
        ;;
    vimrcVundle )
        echo 'using vimrcVundle'
        clean_symlinks
        ln -sf "$HOME/vimrcVundle/.vimrc" "$HOME/.vimrc"
        ln -sf "$HOME/vimrcVundle/.vim" "$HOME/.vim"
        ;;
    vimrcspf13 )
        echo 'using vimrcspf13'
        clean_symlinks
        create_symlinks
        ;;
    *)
        echo 'input: vimrc, vimrcVundle or vimrcspf13'
        ;;
esac
