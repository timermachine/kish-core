#!/bin/bash
# shellcheck disable=SC2317  # Don't warn about unreachable commands in this file due to how kit works.
# shellcheck source=somefile
source "./ki-spread.sh" # code under test

: '
   
   AT $1 is file, exec command just on file.
'

# setup

function ey() {
    # log_info 'mock ey, no hidden color codes for easier string comparison'
    echo "$*"
}

function setup() {
    if [ ! -d "./ki-spread-testrig" ]; then
        echo "pwd: $PWD. Test rig dir ki-spread-testrig not found. exiting tests"
        exit
    else
        cd "ki-spread-testrig"
    fi

    shopt -s expand_aliases
    source "$HOME/.kish/aliases.sh"

}

function teardown() {
    cd ..
}

setup

desc "ki-spread I/O"

t() {
    local input="root.txt"
    cmd="ls"
    res=$(_ki-spread "$input")
    eq "($cmd $input) param 1 file that exists, exec commnad just on file." "$res" "ls root.txt"
    eq "e2e run just file" $(ki-spread "root.txt") "root.txt" # runs it.
}
it t

t() {
    local input="./"
    cmd="ls"
    res=$(_ki-spread "$input")
    eq "($cmd $input). Perform command on all child dirs. " "$res" "cd ./A,echo '',echo \'./A:\',ls ,cd $PWD,cd ./B,echo '',echo \'./B:\',ls ,cd $PWD,cd ./C,echo '',echo \'./C:\',ls ,cd $PWD,"
    ki-spread "./"
}
it t

t() {
    local input=""
    cmd="ls"
    res=$(_ki-spread)
    eq "(no params) default to . dir. Perform command on all child dirs. " "$res" "cd ./A,echo '',ey ./A:,ls ,cd /Users/henrykemp/dev/Timermachine/kish-core/src/lib/ki-spread-testrig,cd ./B,echo '',ey ./B:,ls ,cd /Users/henrykemp/dev/Timermachine/kish-core/src/lib/ki-spread-testrig,cd ./C,echo '',ey ./C:,ls ,cd /Users/henrykemp/dev/Timermachine/kish-core/src/lib/ki-spread-testrig,"
    ki-spread "./"
}
it t

t() {
    local input="./C"
    cmd="ls"
    res=$(_ki-spread "$input")
    eq "($cmd $input) directory specified." "$res" "cd ./C,echo '',ey ./C:,ls ,cd /Users/henrykemp/dev/Timermachine/kish-core/src/lib/ki-spread-testrig,"
    e2eres=$(ki-spread "$input")
    eq "e2e run directory specified" "$e2eres" "C-C1-c.txt
C-C1-c2.txt
C-C2-c.txt
C-C2-c2.txt" # runs it.
}
it t

t() {
    local input="./"
    applicable=".git"
    cmd="ls"
    res=$(_ki-spread "$input")
    eq "($cmd $input) applicable=$applicable. only exec for dirs that contain applicable." "$res" "cd ./A,echo '',ey ./A:,ls ,cd /Users/henrykemp/dev/Timermachine/kish-core/src/lib/ki-spread-testrig,"
    e2eres=$(ki-spread "")
    eq "e2e git applicable" "$e2eres" "
./A:
a.txt
a2.txt" # runs it.
}
oit t

t() {
    local input="./B/b.txt"
    cmd="ga"
    applicable=".git"
    res=$(_ki-spread "$input")
    eq "($input) specific file overrides applicable. " "$res" "ga ./B/b.txt"
    ki-spread "./"
}
it t

t() {
    local input="B/b.txt"
    cmd="ga"
    applicable=".git"
    res=$(_ki-spread "$input")
    eq "($input) specific file overrides applicable. " "$res" "ga B/b.txt"
    ki-spread "./"
}
it t

teardown
