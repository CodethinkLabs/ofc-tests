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

function run_tests
{
	local OFC=$1
	local TEST_VG=$2
	local TEST_VGO=$3

	local STATUS=-1

	print_html_table_start
	print_html_table_header 'Source File' 'Standard' 'GFortran Comparison' 'Valgrind Debug' 'Valgrind Optimised'
	for f in $(find $(find programs -type d | grep -v stdin) -maxdepth 1 -type f | sort)
	do
		print_html_table_row_start
		print_html_cell $f

		# STANDARD
		FRONTEND=$OFC make out/$f.stderr &> /dev/null
		STATUS=$?
		print_html_cell_pass_fail $STATUS

		if [ $STATUS -eq 0 ]
		then
			# GFORTRAN COMPARISON
			./compare-test.sh $OFC $f &> /dev/null
			STATUS=$?
			print_html_cell_pass_fail $STATUS
		else
			print_html_cell_ignored
		fi

		if [ $TEST_VG -ne 0 ] && [ $STATUS -eq 0 ]
		then
			# VALGRIND DEBUG
			FRONTEND=$OFC make out/$f.vg &> /dev/null
			STATUS=$?
			print_html_cell_pass_fail $STATUS
		else
			print_html_cell_ignored
		fi

		if [ $TEST_VGO -ne 0 ] && [ $STATUS -eq 0 ]
		then
			# VALGRIND OPTIMISED
			FRONTEND=$OFC make out/$f.vgo &> /dev/null
			STATUS=$?
			print_html_cell_pass_fail $STATUS
		else
			print_html_cell_ignored
		fi

		if [ $STATUS -eq 0 ]
		then
			let "PASS += 1"
		fi

		let "TOTAL += 1"
		print_html_table_row_end
	done
	print_html_table_end
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
