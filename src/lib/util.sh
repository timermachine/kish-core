#!/bin/bash
# Utility functions


function join { local IFS="$1"; shift; echo "$*"; }


# cmdurl
# takes succinct command line input
# and converts to url
# globaly (yuk) , sets $domain,$paths, $q
function cmdurl () {

    # split $1 into domain and trailing path/s
    arr=(`echo $1 | tr '/' ' '`)

    domain=${arr[0]}

    unset arr[0]
    paths=$(join '/' ${arr[@]})

    # default to .com if eg no .co.uk etc specified:
    if [[ ! $domain == *"."* ]]; then
    domain="https://$domain.com"
    fi

    # default to https:// if protocol not specified:
    # todo: slash splitting above messing with this. account for ://
    if [[ ! $domain == *":"* ]]; then
    domain="https://$domain"
    fi

    shift

    # echo "@"
    joined=$(join '+' $@)
    q=$joined
    # q=$(urlencode $joined)
    # echo $q

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