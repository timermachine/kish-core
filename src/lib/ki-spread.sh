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
     local arr=("echo \"a\"" "echo \"b\"" "echo c")
    #  echo "${arr[@]}"
    local res
     for i in "${arr[@]}"; do
        res+="$i,"
    done
    echo "$res"
}

function _ki-spread() {
     res=$(multi)
    echo "$res"
}

# main entry point function.
# return commands to execute based on:
# is a single file?
# is multiple files (glob)
# child dirs. (with bubble up to parent)
# applicable
# workspace

function ki-spread() {
    # res=$(_ki-spread)
     res=$(multi)
    log_info "$res"
    
    # 1st / all params are files (specific file, glob pattern)


    IFS=','; read -ra commands <<<"$res"  ;IFS=' '
    for i in "${commands[@]}"; do
        $i
    done
}
