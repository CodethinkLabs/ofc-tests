#!/bin/bash

usage() { echo "Usage: $0 [FORTRAN_SOURCE_PATH] [OUTPUT]" 1>&2; exit 1; }

[ $# -eq 2 ] || usage
[ -e "$1"  ] || { echo "File not found: $1"; usage; }

SRC_PATH=$(realpath $1)
SRC_NAME=$(basename $SRC_PATH)
SRC_DIR=$(dirname $SRC_PATH)

INC_DIR=$SRC_DIR/include/

OUTPUT=$(realpath -m $2)

STDIN_NAME=$SRC_DIR/stdin/$SRC_NAME
STDOUT_NAME=$SRC_DIR/stdout/$SRC_NAME

## Compile directly with gfortran
if [ -f $STDOUT_NAME ]
then
	cp $STDOUT_NAME $OUTPUT
else
	if [ -f $(which mktemp) ]
	then
		MKTEMP="mktemp -p"
		ISOLATE=$(mktemp -d)
	else
		MKTEMP=tempfile -d
		ISOLATE=$(tempfile)
		rm $ISOLATE
		mkdir -p $ISOLATE
	fi

	BINARY=$ISOLATE/a.out
	gfortran -I $INC_DIR -x f77 $SRC_PATH -o $BINARY &> /dev/null
	if [ $? -eq 0 ]
	then
		EXPECTED=$($MKTEMP $ISOLATE)
		pushd $ISOLATE
		if [ -f $STDIN_NAME ]
		then
			cat $STDIN_NAME | $BINARY > $OUTPUT
		else
			$BINARY > $OUTPUT
		fi
		popd
	else
		rm -rf $ISOLATE &> /dev/null
		exit 1
	fi

	rm -rf $ISOLATE &> /dev/null
fi
