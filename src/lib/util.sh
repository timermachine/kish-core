#!/bin/bash
# Utility functions


function join { local IFS="$1"; shift; echo "$*"; }


# cmdurl
# takes succinct command line input
# and converts to url
# params:
# $1 domainname/path/s\?customquery=something&another=somethingelse
# $2... the search terms, no need to use quotes
# qkey usually q, search_query (eg youtube)
# globaly (yuk) , sets $url
function cmdurl () {

    # split $1 into domain+paths (\? delimiter) query after delimiter
    local dom_query=(`echo $1 | tr '\?' ' '`)
    echo 'dom_query' $dom_query
    if [[ ${#dom_query[@]} == 2 ]]; then
     local query=${dom_query[1]}
    fi
    echo "query $query"
   

    # split dom of dom_query into domain and trailing path/s
    local arr=(`echo ${dom_query[0]} | tr '/' ' '`)

    local domain=${arr[0]}

    unset arr[0]
    local paths=$(join '/' ${arr[@]})

    # default to .com if eg no .co.uk etc specified:
    if [[ ! $domain == *"."* ]]; then
    local domain="$domain.com"
    fi

    # default to https:// if protocol not specified:
    # todo: slash splitting above messing with this. account for ://
    if [[ ! $domain == *":"* ]]; then
    local domain="https://$domain"
    fi

    shift

    # echo "@"
    local joined=$(join '+' $@)
    local q=$joined
    # q=$(urlencode $joined)
    url="$domain/$paths?$qkey=$q&$query"
}


# function urlencode() {
#     # urlencode <string>
 
#     old_lc_collate=$LC_COLLATE
#     LC_COLLATE=C
 
#     local length="${#1}"
#     for (( i = 0; i < length; i++ )); do
#         local c="${1:$i:1}"
#         case $c in
#             [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
#             *) printf '%%%02X' "'$c" ;;
#         esac
#     done
 
#     LC_COLLATE=$old_lc_collate
# }