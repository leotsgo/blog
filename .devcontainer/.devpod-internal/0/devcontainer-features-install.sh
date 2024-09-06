#!/bin/sh
set -e

on_exit () {
	[ $? -eq 0 ] && exit
	echo 'ERROR: Feature "Hugo" (ghcr.io/devcontainers/features/hugo) failed to install! Look at the documentation at ${documentation} for help troubleshooting this error.'
}

trap on_exit EXIT

set -a
. ../devcontainer-features.builtin.env
. ./devcontainer-features.env
set +a

echo ===========================================================================

echo 'Feature       : Hugo'
echo 'Description   : '
echo 'Id            : ghcr.io/devcontainers/features/hugo'
echo 'Version       : 1.1.2'
echo 'Documentation : https://github.com/devcontainers/features/tree/main/src/hugo'
echo 'Options       :'
echo '    EXTENDED="true"
    VERSION="latest"'
echo 'Environment   :'
printenv
echo ===========================================================================

chmod +x ./install.sh
./install.sh
