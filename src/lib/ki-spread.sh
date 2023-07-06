#!/bin/bash
: '
    K-spread empowers any command to execute across peer directories (mono-repo style)
    test folder, file structure:
    Project
      |-A
       |-a1
       |-a2
      |-B
       |-b1
       |-b2   
    cmd with no params:
        cmd A  cmd B
    cmd B

choice: mock cd, cmd? or create test dir. pref A-mock.

'

source "$HOME/.kish/lib/colors.sh"
source "$HOME/.kish/lib/log.sh"
st=''
cmd=''
applicable='any'
inapplicable='./node_modules'


function multi() {
    
    #log_info "multi *: $*"

    local returndir=$PWD
    
    local cmd_arr=()
    #  log_info "multi. $1"
    # log_info "applicable: $dir/$applicable"
    for dir in $1*; do
        if [ -d "$dir" ]; then
            if [ "$applicable" = 'any' ] || [ -e "$dir/$applicable" ]; then
                # local dir_stripped= ${str/\/\//\/}
                cmd_arr+=("cd $dir")
                cmd_arr+=("echo ''")
                #  cmd_arr+=("echo \"${YELLOW}$dir:${NORMAL}\"")
                 cmd_arr+=("ey $dir:")
                cmd_arr+=("$cmd ") # params (if $@, shift dir)
                cmd_arr+=("cd $returndir") #("cd ..") #
            fi
        fi
    done
    #  echo "${cmd_arr[@]}"
    local res
    for i in "${cmd_arr[@]}"; do
        res+="$i,"
    done
    echo "$res"
}

function multiactionreference() {

    allowedcount=0
    for dir in $1/*; do
        if [ -d "$dir" ]; then

            if [ "$applicable" = 'any' ] || [ -e "$dir/$applicable" ]; then
                printf "${IYel}"
                echo ''
                echo "$dir:"
                printf "${Whi}"
                singleaction $dir "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
                allowedcount+=1

                # todo: maybe enable with verbose option :
            else
                if [ "$dryrun" = true ]; then
                    printf "${IYel}"
                    echo ''
                    echo "$dir: excluded (has no $applicable)"
                    printf "${Whi}"
                fi
            fi
        # else - todo: verbose mode: say skipped as not an applicable git dir etc.
        fi

    done

    # if none of the children were allowable run for parent dir.
    #  So dont have to g targetdir/. - g targetdir will work.
    if [ "$allowedcount" = 0 ]; then
        # todo: verbose mode may show what was excluded and why
        # echo "debug: $allowedcount not zero"
        if [ "$applicable" = 'any' ] || [ -e "$1/$applicable" ]; then
            # printf "${IYel}"
            # echo ''
            # echo "$dir:"
            # printf "${Whi}"
            singleaction $1 "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
            allowedcount+=1
        fi

    fi
    if [ "$allowedcount" = 0 ]; then
        echo "No child or current dir with $applicable"
    fi
    allowedcount=0
    echo ''
}

function _ki-spread() {

    if [ -f "$1" ]; then # just single cmd action on specific file. todo: globbing.
        res="$cmd $1"
        # log_info "single file: $cmd $1 no applicable applied."
    else
        if [ $# = 0 ]; then # no params( and no workspace filter) default to ./
            res=$(multi "./" "$@")
        else
            if [ -d "$1" ]; then # act on directory given. todo: cd into it.
                res=$(multi "$@")
            fi
        fi
    fi
    echo "$res"
}

# main operational entry point function.
# return commands to execute based on:
# is a single file?
# is multiple files (glob)
# child dirs. (with bubble up to parent)
# applicable
# workspace

function ki-spread() {
    # log_info "ks $PWD"
    res=$(_ki-spread "$@")
    IFS=','
    read -ra commands <<<"$res"
    IFS=' '
    for i in "${commands[@]}"; do
        # eval strips .//. todo - strip explicitly and drop eval.
        eval "$i"
    done
}
