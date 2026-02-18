#!/usr/bin/env bash

[ -d .nyoom ] && rm -fr .nyoom
[ -f nvim-pack-lock.json ] && rm nvim-pack-lock.json
[ -d ~/.cache/nvim-nyoom ] && rm -fr ~/.cache/nvim-nyoom
[ -d ~/.local/share/nvim-nyoom/site/pack ] && rm -fr ~/.local/share/nvim-nyoom/site/pack
