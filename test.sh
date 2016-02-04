#!/bin/bash

# Test runner and report generator for Open Fortran Compiler

function print_html_header
{
printf "%s" "<!doctype html>
<html>
<style TYPE="text/css">
<!--
table
{
  width: 100%;
  border-collapse:separate;
  border-spacing: 0;
  border:solid #aaa 2px;
  border-radius:6px;
  -moz-border-radius:6px;
}
th
{
  height: 30px;
}
tr:nth-child(odd)
{
  background-color: #ccc;
}
tr:nth-child(even)
{
  background-color: #ddd;
}
td
{
  padding-left: 6px;
}

--!>
</style>
<head>
<title>Open Fortran Compiler Test Report</title>
<h1>Open Fortran Compiler Test Report</h1>
</head>
<body>
"
}

function print_html_report_info
{
	printf "<p>This is the test report for Open Fortran Compiler (OFC).</p>"
	printf "<p>Branch: %s</p>" "$OFC_GIT_BRANCH"
	printf "<p>SHA1: <a href=\"%s/tree/%s\">%s</a></p>" "$OFC_GIT_URL" "$OFC_GIT_COMMIT" "$OFC_GIT_COMMIT"
	printf "<p>Test run started: %s</p>" "$(date -u)"
}

function print_html_table_start
{
	local HEADER=$1

	printf "<h2>%s</h2>\n" "$HEADER"
	printf "<table>\n"
}

function print_html_table_header
{
	printf "<tr>"

	for var in "$@"
	do
		printf "<th>%s</th>" "$var"
	done

	printf "</tr>\n"
}

function print_html_table_row_start
{
	printf "<tr>"
}

function print_html_cell
{
	local TEXT=$1

	printf "<td>%s</td>" "$TEXT"
}

function print_html_cell_bold
{
	local TEXT=$1

	printf "<td><b>%s</b></td>" "$TEXT"
}

function print_html_cell_centre
{
	local TEXT=$1

	printf "<td align=center>%s</td>" "$TEXT"
}

function print_html_cell_test_file
{
	local FILE_PATH=$1

	printf "<td><a href=\"$TESTS_GIT_URL/blob/$TESTS_GIT_COMMIT/$1\">%s</a></td>" "$(basename $FILE_PATH)"
}

function print_html_cell_fail
{
	local STATUS=$1
	local LINK=$2

	printf "<td align=center><font color=\"#bf0000\">FAIL (%d)</font></td>" "$STATUS"
}

function print_html_cell_pass
{
	local LINK=$1

	printf '<td align=center><font color="#00bf00">PASS</font></td>'
}

function print_html_cell_ignored
{
	printf '<td align=center><font color="#3f3f3f">-</font></td>'
}

function print_html_cell_pass_fail
{
	local STATUS=$1

	if [ $STATUS -eq 0 ]
	then
		print_html_cell_pass
	else
		print_html_cell_fail $STATUS
	fi
}

function print_html_table_row_end
{
	printf "</tr>\n"
}

function print_html_table_end
{
	printf "</table>\n"
}

function print_html_footer
{
printf "%s" "</body>
</html>"
}

function run_tests_dir
{
	local TEST_DIR=$1
	local OFC=$2
	local TEST_VG=$3
	local TEST_BEHAVIOUR=1

	local TEST_DIR_NAME=$(basename $TEST_DIR)
	local IS_NEGATIVE=0

	if [ "$TEST_DIR_NAME" == "sema" ]
	then
		TEST_VG=0
		TEST_BEHAVIOUR=0
	fi

	if [ "$TEST_DIR_NAME" == "negative" ]
	then
		IS_NEGATIVE=1
		TEST_VG=0
		TEST_BEHAVIOUR=0
	fi

	local STATUS=-1
	local STATUS_BEHAVIOUR=-1

	local TOTAL=0
	local PASS=0
	local PASS_BEHAVIOUR=0
	local PASS_VG=0
	local PASS_VGO=0
	local FAIL_VGO=0

	print_html_table_start $TEST_DIR/
	print_html_table_header 'Source File' 'Standard' 'Behavioural' 'Valgrind' 'Valgrind (Debug)'
	for f in $(find $TEST_DIR -maxdepth 1 -type f | sort)
	do
		print_html_table_row_start
		print_html_cell_test_file $f

		# STANDARD
		FRONTEND=$OFC make out/$f.stderr &> /dev/null
		STATUS=$?

		if [ $IS_NEGATIVE -ne 0 ]
		then
			if [ $STATUS -eq 0 ]
			then
				STATUS=-1
			else
				STATUS=0
			fi
		fi

		[ $STATUS -eq 0 ] && let "PASS += 1"

		print_html_cell_pass_fail $STATUS

		if [ $TEST_BEHAVIOUR -ne 0 ] && [ $STATUS -eq 0 ]
		then
			# GFORTRAN COMPARISON
			./compare-test.sh $OFC $f &> /dev/null
			STATUS_BEHAVIOUR=$?
			print_html_cell_pass_fail $STATUS_BEHAVIOUR
			[ $STATUS_BEHAVIOUR -eq 0 ] && let "PASS_BEHAVIOUR += 1"
		else
			print_html_cell_ignored
		fi

		if [ $TEST_VG -ne 0 ] && [ $STATUS -eq 0 ]
		then
			# VALGRIND OPTIMISED
			FRONTEND=$OFC make out/$f.vgo &> /dev/null
			STATUS=$?
			[ $STATUS -eq 0 ] && let "PASS_VGO += 1"
			print_html_cell_pass_fail $STATUS "out/$f.vgo"

			if [ $STATUS -ne 0 ]
			then
				"FAIL_VGO += 1"

				# VALGRIND DEBUG
				FRONTEND=$OFC make out/$f.vg &> /dev/null
				STATUS=$?
				[ $STATUS -eq 0 ] && let "PASS_VG += 1"
				print_html_cell_pass_fail $STATUS "out/$f.vg"
			else
				print_html_cell_ignored
			fi
		else
			print_html_cell_ignored
			print_html_cell_ignored
		fi

		let "TOTAL += 1"
		print_html_table_row_end
	done

	print_html_table_row_start
	print_html_cell_bold "Total"

	print_html_cell_centre "$PASS / $TOTAL"

	if [ $TEST_BEHAVIOUR -ne 0 ]
	then
		print_html_cell_centre "$PASS_BEHAVIOUR / $PASS"
	else
		print_html_cell_ignored
	fi

	if [ $TEST_VG -ne 0 ]
	then
		print_html_cell_centre "$PASS_VGO / $PASS"

		if [ $FAIL_VGO -ne 0]
		then
			print_html_cell_centre "$PASS_VG / $FAIL_VGO"
		else
			print_html_cell_ignored
		fi
	else
		print_html_cell_ignored
		print_html_cell_ignored
	fi

	print_html_table_row_end

	print_html_table_end
}

function run_tests
{
	local OFC=$1
	local TEST_VG=$2

	for f in $(find programs -type d | grep -v stdin | grep -v stdout | sort)
	do
		run_tests_dir $f $OFC $TEST_VG $GIT_COMMIT $GIT_BRANCH
	done
}

# Ensure global git variables are set by make files
[[ -v OFC_GIT_COMMIT   ]] || { echo "TEST.SH ERROR: OFC_GIT_COMMIT not set"   1>&2; exit 1; }
[[ -v OFC_GIT_BRANCH   ]] || { echo "TEST.SH ERROR: OFC_GIT_BRANCH not set"   1>&2; exit 1; }
[[ -v TESTS_GIT_COMMIT ]] || { echo "TEST.SH ERROR: TESTS_GIT_COMMIT not set" 1>&2; exit 1; }

OFC_GIT_URL="https://github.com/CodethinkLabs/ofc"
TESTS_GIT_URL="https://github.com/CodethinkLabs/ofc-tests"

print_html_header
print_html_report_info
run_tests $1 ${2:-1}
print_html_footer
