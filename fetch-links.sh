#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

mkdir -p "data"

pagesize=500

diag() {
    echo "* $@" >&2
}

_curl() {
    local ws=$1
    curl -s "https://sonarcloud.io/api/$ws"
}

while IFS= read -r key; do
    diag "fetching links for project with key '$key' ..."
    link=$(_curl "project_links/search?projectKey=$key" | jq -r '.links[] | select(.type == "scm").url') || continue
    if [[ "$link" ]]; then
        echo "$key	$link"
    fi
done | tee -a data/key-scm.txt
