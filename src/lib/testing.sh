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
  The only nice to have I might add is generate fn.sh, fn.lib.sh, fn.test.sh


 
'
#  call this kit, move up a dir. add to geneated help.
#   calling kit runs all .test files.
#   parse file, search for onlyFname's, run only these tests. xeq
#   call this kit, move up a dir. add to geneated help.


 source "$HOME/.kish/lib/colors.sh"
 source "$HOME/.kish/lib/util.sh"

function xeq() {
  # noop
}

function eq () {
  local testdesc="$1"
  local result="$2"
  local expected="$3"
    echo "  $testdesc:"
   if [ "$result" == "$expected" ];then
     printf "${IGre}"
     echo "    √ $result == $expected "
   else
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