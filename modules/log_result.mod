#########1#########2#########3#########4#########5#########6#########7#########8
# 
# $Header: /home/kbreslin/cvs/bohem/modules/log_result.mod,v 1.8 2010-09-06 10:36:01 kbreslin Exp $
#
# This file details functions that output ("log") individual test result. It is
# encouraged that these be used, as it makes for consistent output, on which
# additional scripts may depend.
# The file needs to be sourced in order for the functions to be made available.
# 
#########1#########2#########3#########4#########5#########6#########7#########8


# Functions output the following message to the standard output:
# PASSED|FAILED|SKIPPED: $TC_NAME: $message ($SECONDS sec.)
# where:
# - PASSED|FAILED|SKIPPED is selected with log_pass and log_fail functions, respectively.
#   Will _always_ appear in the first column!
# - $TC_NAME will be the "name" of the test case. Can be supplied by 'export
#   TC_NAME=blah' in the test_source file. Will default to $ADJUST_DIR/$test_case,
#   where test_case is the name of the test case as specificed in test list; the
#   default, in the case of bohem, is set by the calling script.
# - $message is an optional string that you pass to the function. Will default to
#   "Test passed" for log_pass, and "Test failed" for log_fail.
# - $SECONDS will be a timestamp since the last time (either) function was
#   called, or since the current test was started. 

if [ $_single_result_per_script -eq 1 ]; then
	export _bohem_log_prefix="TEST"
else
	export _bohem_log_prefix=""
fi

log_fail()
{
	printf "${_bohem_log_prefix}FAILED: ${TC_NAME}: ${*:-"Test failed"} ($SECONDS sec.)\n"
}
export -f log_fail


log_pass()
{
	printf "${_bohem_log_prefix}PASSED: ${TC_NAME}: ${*:-"Test passed"} ($SECONDS sec.)\n"
} 
export -f log_pass


log_skip()
{
	printf "${_bohem_log_prefix}SKIPPED: ${TC_NAME}: ${*:-"Test skipped"} ($SECONDS sec.)\n"
} 
export -f log_skip

log_broken()
{
	printf "${_bohem_log_prefix}BROKEN: ${TC_NAME}: ${*:-"Test skipped"} ($SECONDS sec.)\n"
} 
export -f log_broken

log_warning()
{
	printf "${_bohem_log_prefix}WARNING: ${TC_NAME}: ${*:-"Something bad happened"}\n"
} 
export -f log_warning

# Uncomment the following for testing.
#log_fail
#log_pass "double quoted string"
#TC_NAME="Bad test case"
#log_fail 'single quoted string'
#unset TC_NAME
#log_pass oneword
#SECONDS=20
#log_fail twenty seconds
#log_pass Composite output: `who am i`

