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

fetch_total() {
    local ws=$1
    _curl "$ws?ps=1" | jq .paging.total
}

total=$(fetch_total "components/search_projects")
diag "total projects: $total"

((pages = total / pagesize + 1))
diag "total pages: $pages"

diag "max 10000 records can be fetched (Elasticsearch limit)"

for ((page = 1; page <= pages; page++)); do
    diag "fetching page $page / $pages ..."
    _curl "components/search_projects?p=$page&ps=$pagesize" | jq -r '.components[].key'
done > data/project-keys.txt
