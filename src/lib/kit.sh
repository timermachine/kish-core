#!/usr/bin/env bash

: '
 Home rolled super simple testing.

  eq 'test description' result expected
  example:
  fn=$(theFnToTest "param1" "param2")
  eq 'test desc' "$fn" 'expected'
  
  stdout visual red/green indented.


 Why: 
 Bats is pretty much the only alternative for shell script unit testing.
 It has its own domain specifc language, and frankly quite a steep learning curve.
 This home rolled alternative is:
  * super simple - you can understand the code in minutes.
  * encourages code reuse through .lib.sh files.
  * provides auto-geneation of test, lib, command line execution files.
  * This provides a basis for good practices of separation of code.
  * Since it is super simple it is zero setup, zero learning curve.
  * OK - it doesnt provide integration testing for CI/code coverage etc, but its shell scripts - YAGNI?
  * So there, kudos, and ya boo sucks Bats ;)
  * tests should be easily portable to bats/whatever latest & next greatest test framework that might come along.
  but these are bash scripts, so this  a keep it simple option.


Run a sepcific test /directory.

tap compliance!
test fail/pass count & summary
last run fails only (store file, line)

# SETUP-TO

# ONLY-FROM

# ONLY

Parse to temp.test.sh

This is nice because integration tests will run every thing - igoring onlys!


Pretty much what’s left is eq codes/tap compatibility.


  Generate: The only nice to have I might add is generate fn.sh, fn.lib.sh, fn.test.sh


 
'
#  call this kit, move up a dir. add to geneated help.
#   calling kit runs all .test files.
#   parse file, search for onlyFname's, run only these tests. xeq
#   call this kit, move up a dir. add to geneated help.


 source "$HOME/.kish/lib/colors.sh"
 source "$HOME/.kish/lib/util.sh" # moved kstate here - do we need utils?

# States for global tracking :
#  kstate - test fail/pass counter
#  xstate - disable/enable test runs
#  TODO CHORE: refactor kstate and xstate to just state
 kstate_path="$HOME/.kish/temp/"
 TP="testpass" #filename to log test passes
 TF="testfail" #filename to log test fails
 TS="tesskip" #filename to log tesk skips (x/xoff)
 xstate_path="$HOME/.kish/temp/"
 XSTATE_FILE="xstate" #filename to log xstate (on/off) for test run exclusion

# kstate_init id  sets to zero
function kstate_init () {
#   echo    "${YELLOW} kstate_init: $kstate_path$1"
  echo 0 > "$kstate_path$1"
}

# increment counter
function kstate_increment () {
    let kincrement=$(cat  "$kstate_path$1")+1
    echo $kincrement > "$kstate_path$1"
}

# get id
function kstate_get () {
    echo $(cat "$kstate_path$1")
}

# set id value
function kstate_set () {
    echo $1 > "$kstate_path$1"
}


# ------- xstate block start --------

#xreset id  sets to zero name:reset/init?
function xstate_init () {
  echo 0 > "$xstate_path$XSTATE_FILE"
}

# get xstate
function xstate_get () {
    echo $(cat "$xstate_path$XSTATE_FILE")
}

# set xstate value
function xstate_set () {
    echo $1 > "$xstate_path$XSTATE_FILE"
}
# -------xstate block end--------


 kstate_init $TP
 kstate_init $TF
 kstate_init $TS
 xstate_init

 # turns off tests - eg: eq, desc  
 function xon () {
  xstate_set 1
 }
# editors can upper case just x annoyingly
# function X () {
#   xstate_set 1
#  }

 # turns back on (xstate=false) for eq, desc (if x previously called)
 function xoff () {
  xstate_set 0
 }

function xeq() {
  # noop
  kstate_increment "$TS"
  return 0 # ok
}

function it () {
   if [[ $(xstate_get) -eq 0 ]]; then
    eval "$1"
    else 
      kstate_increment "$TS"
   fi
}

function xit () {
    kstate_increment "$TS"
}

function eq () {
  # xs=$(xstate_get)
  # log_info "eq xstate: $xs"
    # if [[ "$xs" -eq 0 ]]; then 
    local testdesc="$1"
    local result="$2"
    local expected="$3"

    echo "  $testdesc:"
    if [ "$result" == "$expected" ];then
      kstate_increment "$TP"
      printf "${IGre}"
        echo "   √  $result."
        echo "   == $expected."
    else
        kstate_increment "$TF"
        printf "${IRed}"
        echo "   x  $result."
        echo "   != $expected."
      fi
      # reset color
      printf "${IWhi}\n"
    # fi
}


function desc () {
  [[ $(xstate_get) -eq 1 ]] && return 0
  # echo "------------------------ DESC -----------------------------------------------"
  #  printf ">>>>>>>>>>>> ${BIWhi} % ${IWhi} >>>>>>>>>>>> \n" "$1"

   printf "${BIWhi}"
   echo "$1"
  printf "${IWhi}"
  echo ""
}


# cd's to aliases (++ check current dir has any .test files first, if so run from there instead, fallback to configured dir.)
# search all .test files (++and sub dirs) ()
# parse test files searching for only/onlyeq? / onlyfrom tag.

# search all .test files (++and sub dirs) ()

: '
no params : default dir (aliases)
param : dir - *.test* within it.
param : one file - just that file
param : glob (multiple test files x*)

'

test_files=''
if (( $# > 1 )); then
   test_files="$@"
else 
    if [ -f "$1" ];then
        test_files="$1" 
    else
       #if $1 dir   
       if [ -d "$1" ]; then
         test_files="$1/*.test*"
       else
            test_files="$PWD/*.test*"
        fi
    fi
fi

echo "test_files: $test_files"

   for f in $test_files; do
   echo ""
   echo "-------------------------------- Test File: $f --------------------------------"
   #  () subshell: to improve tests isolation.  kstate to track passes/failed tests
   (
    source $f
   )
   echo ""
   done

testpasses=$(kstate_get "$TP")
testfails=$(kstate_get "$TF")
testskips=$(kstate_get "$TS")
(( testcounter=testpasses+testfails ))

 echo "##################### Tests Done ######################"
 echo ""
 echo  "${GREEN}$testpasses passed. ${RED} $testfails  failed. ${NORMAL} $testskips skipped. $testcounter tests ran."


 xoff #turn x off for next test run.
 
 # CI: 0: no errors; >0 erros. todo: TAP compliance.
# to figure out: return: can only `return' from a function or sourced script
# return  "$testfails"


