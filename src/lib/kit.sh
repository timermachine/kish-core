#!/bin/bash

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
 source "$HOME/.kish/lib/util.sh"

 TP="testpass"
 TF="testfail"

 kstate_init $TP
 kstate_init $TF

function xeq() {
  # noop
  return 0 # ok
}

function eq () {
  local testdesc="$1"
  local result="$2"
  local expected="$3"

  echo "  $testdesc:"
   if [ "$result" == "$expected" ];then
     kstate_increment "$TP"
     printf "${IGre}"
     echo "    √ $result == $expected "
   else
      kstate_increment "$TF"
      printf "${IRed}"
      echo "    x $result != $expected"
    fi
    # reset color
    printf "${IWhi}"
}


function desc () {
  echo ""
   printf "${BIWhi}"
   echo "$1"
    printf "${IWhi}"
}


# cd's to aliases (++ check current dir has any .test files first, if so run from there instead, fallback to configured dir.)
# search all .test files (++and sub dirs) ()
# parse test files searching for only/onlyeq? / onlyfrom tag.

# search all .test files (++and sub dirs) ()

# function parseTestFiles() {
  # echo $PWD
   for f in $PWD/*.test*; do
   echo "Test File: " $f
   #  () subshell: to improve tests isolation.  kstate to track passes/failed tests
   (
    source $f
   )
   done

testpasses=$(kstate_get "$TP")
testfails=$(kstate_get "$TF")
let testcounter=testpasses+testfails

 echo  "${GREEN}$testpasses tests passed. ${RED} $testfails tests failed. ${NORMAL} $testcounter tests ran."

  # CI: 0: no errors >0 erros.  
  #  return  $tesFails


