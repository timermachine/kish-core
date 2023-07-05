#!/bin/bash
# shellcheck disable=SC2317  # Don't warn about unreachable commands in this file due to how kit works.
# shellcheck source=somefile
source "./ki-spread.sh" # code under test

: '
   unit and E2E`ish tests with kish kit minimal testing framework
   eg kit ocal.test.sh
'

desc "ki-spread I/O"

t() {
    input=""
    res=$(_ki-spread $input)
    eq "returns return" "$res" ",echo a,echo b,echo c"
}
it t

 ki-spread