#!/bin/bash

# Parse index.html and extract all href attributes starting with https://
# Exclude preconnect/preload/dns-prefetch hints — these are bare origins, not navigable URLs
links=$(grep -v 'preconnect\|preload\|dns-prefetch' ./app/templates/index.html \
    | grep -o 'href="https://[^"]*' \
    | sed 's/href="//')

# Function to check if a given status code is acceptable
is_acceptable_status() {
    case "$1" in
        200|202|403) return 0 ;;
        *) return 1 ;;
    esac
}

# Loop through each https:// link and check existence with curl
for link in $links; do
    response=$(curl -sL -w "%{http_code}" "$link" -o /dev/null)
    if is_acceptable_status "$response" || is_override_url "$link"; then
        echo "Link $link exists (HTTP $response)"
    else
        echo "Link $link does not exist or has an unacceptable status code (HTTP $response)"
        exit 1
    fi
done
