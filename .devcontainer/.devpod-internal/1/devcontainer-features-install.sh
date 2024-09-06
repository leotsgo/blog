#!/bin/sh
set -e

on_exit () {
	[ $? -eq 0 ] && exit
	echo 'ERROR: Feature "zsh" (ghcr.io/nils-geistmann/devcontainers-features/zsh) failed to install!'
}

trap on_exit EXIT

set -a
. ../devcontainer-features.builtin.env
. ./devcontainer-features.env
set +a

echo ===========================================================================

echo 'Feature       : zsh'
echo 'Description   : A feature to install and configure zsh with OhMyZsh'
echo 'Id            : ghcr.io/nils-geistmann/devcontainers-features/zsh'
echo 'Version       : 0.0.6'
echo 'Documentation : '
echo 'Options       :'
echo '    DESIREDLOCALE="en_US.UTF-8 UTF-8"
    PLUGINS="git"
    SETLOCALE="true"
    THEME="robbyrussell"'
echo 'Environment   :'
printenv
echo ===========================================================================

chmod +x ./install.sh
./install.sh
