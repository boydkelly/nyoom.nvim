#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

nvim -es +'mkspell! ~/.config/nvim/spell/dyu ~/dev/jula/pubs/dyu_CI'
