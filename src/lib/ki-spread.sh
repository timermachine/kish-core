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
cmd=''
applicable='any'

function ey() {
    echo "${YELLOW}$*${NORMAL}"
}

function multi() {

    # log_info "multi *: $*"

    local returndir=$PWD
    local cmd_arr=()
    local counter=0
    #  log_info "multi. $1"
    # log_info "applicable: $dir/$applicable"

    for p in "$@"; do
        counter+=1
        # trailing dot or just dot - target single dir:
        if [[ $p =~ /\. ]] || [[ $p = '.' ]]; then
            #  log_info "trail dot: $p counter: $counter"
            cmd_arr+=("cd $p")
            cmd_arr+=("echo ''")
            cmd_arr+=("ey $p:")
            cmd_arr+=("$cmd ")         # params (if $@, shift dir)
            cmd_arr+=("cd $returndir") #("cd ..") #

        else

            for dir in $p/*; do
                if [ -d "$dir" ]; then
                    #  log_info "dirs in $p"
                    if [ "$applicable" = 'any' ] || [ -e "$dir/$applicable" ]; then
                        local dir_stripped=${dir/\/\//\/}
                        # log_info "dir: $dir, stripped: $dir_stripped"
                        cmd_arr+=("cd $dir_stripped")
                        cmd_arr+=("echo ''")
                        cmd_arr+=("ey $dir_stripped:")
                        cmd_arr+=("$cmd ")         # params (if $@, shift dir)
                        cmd_arr+=("cd $returndir") #("cd ..") #
                    fi
                # else
                #     cmd_arr+=("echo $cmd: $dir_stripped: No such file or directory")
                fi
            done
        fi
        local res=''
        for i in "${cmd_arr[@]}"; do
            res+="$i,"
        done

    done
    echo "$res"
}

function _ki-spread() {
    # log_info "params: $*"
    local res
    local has_file_targets

    for p in "$@"; do
        if [ -f "$p" ]; then
            has_file_targets=true
        fi
        # not a file or directory, assume args for cmd.
        if [ ! -e "$p" ]; then
            # if $p contains spaces quote it
            if [[ "$p" == *" "* ]]; then
                cmd+=' '
                cmd+=\"$p\"
            else
                cmd+=" $p"
            fi
        fi
    done

    # log_info "has_file_targets: $has_file_targets"
    if [[ "$has_file_targets" = "true" ]]; then
        for p in "$@"; do

            if [ -d "$p" ]; then
                log_info "has_target_files, process dir $p"
                res+=$(multi "$p/.")
                res+="echo ,"

            fi
            if [ -f "$p" ]; then
                res+="$cmd $p,"
                log_info "has_target_files -f $p"
            fi
        done
    fi

    if [[ -z "$res" ]]; then
        # else
        if [ $# = 0 ]; then # no params( and no workspace filter) default to ./
            res=$(multi "./" "$@")
        else
            # if [ -d "$1" ]; then # by this point by default should be dir(s) drop check?
            res=$(multi "$@")
            # fi
        fi

    fi
    log_info "_ki_spread. res: $res"
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
