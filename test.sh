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
	printf "<p>Test run started: %s</p>" "$(date -u)"
}

function print_html_table_start
{
	printf "<br>"
	printf "<h2>%s</h2>\n" "$1"
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
	printf "<td>%s</td>" "$1"
}

function print_html_cell_bold
{
	printf "<td><b>%s</b></td>" "$1"
}

function print_html_cell_centre
{
	printf "<td align=center>%s</td>" "$1"
}

function print_html_cell_fail
{
	printf "<td align=center><font color=\"#bf0000\">FAIL (%d)</font></td>" $1
}

function print_html_cell_pass
{
	printf '<td align=center><font color="#00bf00">PASS</font></td>'
}

function print_html_cell_ignored
{
	printf '<td align=center><font color="#3f3f3f">-</font></td>'
}

function print_html_cell_pass_fail
{
	if [ $1 -eq 0 ]
	then
		print_html_cell_pass
	else
		print_html_cell_fail $1
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
	local TEST_VGO=$4
	local TEST_BEHAVIOUR=1

	local TEST_DIR_NAME=$(basename $TEST_DIR)
	local IS_NEGATIVE=0

	if [ "$TEST_DIR_NAME" == "sema" ]
	then
		TEST_VG=0
		TEST_VGO=0
		TEST_BEHAVIOUR=0
	fi

	if [ "$TEST_DIR_NAME" == "negative" ]
	then
		IS_NEGATIVE=1
		TEST_VG=0
		TEST_VGO=0
		TEST_BEHAVIOUR=0
	fi

	local STATUS=-1

	local TOTAL=0
	local PASS=0
	local PASS_BEHAVIOUR=0
	local PASS_VG=0
	local PASS_VGO=0

	print_html_table_start $TEST_DIR/
	print_html_table_header 'Source File' 'Standard' 'Behavioural' 'Valgrind' 'Valgrind (Optimised)'
	for f in $(find $TEST_DIR -maxdepth 1 -type f | sort)
	do
		print_html_table_row_start
		print_html_cell $(basename $f)

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
			STATUS=$?
			print_html_cell_pass_fail $STATUS
			[ $STATUS -eq 0 ] && let "PASS_BEHAVIOUR += 1"
		else
			print_html_cell_ignored
		fi

		if [ $TEST_VG -ne 0 ] && [ $STATUS -eq 0 ]
		then
			# VALGRIND DEBUG
			FRONTEND=$OFC make out/$f.vg &> /dev/null
			STATUS=$?
			[ $STATUS -eq 0 ] && let "PASS_VG += 1"
			print_html_cell_pass_fail $STATUS
		else
			print_html_cell_ignored
		fi

		if [ $TEST_VGO -ne 0 ] && [ $STATUS -eq 0 ]
		then
			# VALGRIND OPTIMISED
			FRONTEND=$OFC make out/$f.vgo &> /dev/null
			STATUS=$?
			[ $STATUS -eq 0 ] && let "PASS_VGO += 1"
			print_html_cell_pass_fail $STATUS
		else
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
		print_html_cell_centre "$PASS_VG / $PASS"
	else
		print_html_cell_ignored
	fi

	if [ $TEST_VGO -ne 0 ]
	then
		print_html_cell_centre "$PASS_VGO / $PASS_VG"
	else
		print_html_cell_ignored
	fi

	print_html_table_row_end

	print_html_table_end
}

function run_tests
{
	local OFC=$1
	local TEST_VG=$2
	local TEST_VGO=$3

	for f in $(find programs -type d | grep -v stdin | grep -v stdout)
	do
		run_tests_dir $f $OFC $TEST_VG $TEST_VGO
	done
}

PASS=0
TOTAL=0

print_html_header
print_html_report_info
run_tests $1 ${2:-1} ${3:-1}
printf "<p>Passed %s of %s</p>" $PASS $TOTAL
print_html_footer

if [ $PASS -ne $TOTAL ]
then
	exit 1
else
	exit 0
fi
