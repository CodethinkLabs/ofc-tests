#!/bin/bash

usage() { echo "Usage: $0 [OFC_PATH] [FORTRAN_SOURCE_PATH]" 1>&2; exit 1; }

[ $# -eq 2 ] || usage
[ -e "$2"  ] || { echo "File not found: $2"; usage; }

TGFOR=$(mktemp)
TREFOR=$(mktemp)
TAOUT=$(mktemp)
chmod +x $TAOUT

STDIN_NAME=$(dirname $2)/stdin/$(basename $2)

## Compile directly with gfortran
gfortran $2 -o $TAOUT &> /dev/null
if [ -e $TAOUT ]
then
	if [ -f $STDIN_NAME ]
	then
		cat $STDIN_NAME | $TAOUT > $TGFOR
	else
		$TAOUT > $TGFOR
	fi
else
	rm $TAOUT &> /dev/null
	rm $TGFOR &> /dev/null
	rm $TREFOR &> /dev/null
	exit 1
fi

## Compile with gfortran OFC output
$1 --sema-tree $2 2> /dev/null | gfortran -x f77 - -o $TAOUT &> /dev/null
if [ -e $TAOUT ]
then
	if [ -f $STDIN_NAME ]
	then
		cat $STDIN_NAME | $TAOUT > $TREFOR
	else
		$TAOUT > $TREFOR
	fi
else
	rm $TAOUT &> /dev/null
	rm $TGFOR &> /dev/null
	rm $TREFOR &> /dev/null
	exit 1
fi

diff $TGFOR $TREFOR &> /dev/null
if [ $? -eq 0 ]
then
	rm $TAOUT &> /dev/null
	rm $TGFOR &> /dev/null
	rm $TREFOR &> /dev/null
	exit 0
fi

rm $TAOUT &> /dev/null
rm $TGFOR &> /dev/null
rm $TREFOR &> /dev/null
exit 1
