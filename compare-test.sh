#!/bin/bash

usage() { echo "Usage: $0 [OFC_PATH] [FORTRAN_SOURCE_PATH]" 1>&2; exit 1; }

[ $# -eq 2 ] || usage
[ -e "$2"  ] || { echo "File not found: $2"; usage; }

MKTEMP=tempfile
which mktemp &> /dev/null && MKTEMP=mktemp

TGFOR=$($MKTEMP)
TREFOR=$($MKTEMP)
TAOUT=$($MKTEMP)
chmod +x $TAOUT

STDIN_NAME=$(realpath $(dirname $2)/stdin/$(basename $2))
STDOUT_NAME=$(dirname $2)/stdout/$(basename $2)

## Compile directly with gfortran
if [ -f $STDOUT_NAME ]
then
	cp $STDOUT_NAME $TGFOR
else
	gfortran $2 -o $TAOUT &> /dev/null
	if [ -e $TAOUT ]
	then
		pushd $(dirname $TAOUT)
		rm -f fort.*
		if [ -f $STDIN_NAME ]
		then
			cat $STDIN_NAME | $TAOUT > $TGFOR
		else
			$TAOUT > $TGFOR
		fi
		popd
	else
		rm $TAOUT &> /dev/null
		rm $TGFOR &> /dev/null
		rm $TREFOR &> /dev/null
		exit 1
	fi
fi

## Compile with gfortran OFC output
$1 --sema-tree $2 2> /dev/null | gfortran -x f77 - -o $TAOUT &> /dev/null
if [ -e $TAOUT ]
then
	pushd $(dirname $TAOUT)
	rm -f fort.*
	if [ -f $STDIN_NAME ]
	then
		cat $STDIN_NAME | $TAOUT > $TREFOR
	else
		$TAOUT > $TREFOR
	fi
	popd
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
