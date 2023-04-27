#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail

project=project

#[ -f ${HEADWORDS} ] || { echo "${HEADWORDS} not found.  Exiting..."; exit 1; }

for x in tmp xml xsd yaml adoc json; do export "${x}=${project}.$x"; done

for x in ls echo; do
	type -P $x >/dev/null 2>&1 || {
		echo >&2 "${x} not installed.  Aborting."
		exit 1
	}
done

nvim -es +'mkspell! ~/.config/nvim/spell/dyu ~/dev/jula/pubs/dyu_CI'
