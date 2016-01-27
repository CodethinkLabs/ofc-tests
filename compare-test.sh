#!/bin/bash

TGFOR=$(tempfile)
TREFOR=$(tempfile)
TAOUT=$(tempfile)
chmod +x $TAOUT

## Compile directly with gfortran
gfortran $2 -o $TAOUT &> /dev/null
if [ -e $TAOUT ]
then
	if [ -f $2.stdin ]
	then
		cat $2.stdin | $TAOUT > $TGFOR
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
	if [ -f $2.stdin ]
	then
		cat $2.stdin | $TAOUT > $TREFOR		
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
