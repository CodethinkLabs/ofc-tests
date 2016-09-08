#!/bin/bash

usage() { echo "Usage: $0 [ORIGINAL_SOURCE] [OFC_SOURCE] [EXPECTED] [BEHAVIOUR]" 1>&2; exit 1; }

[ $# -eq 4 ] || usage
[ -e "$1"  ] || { echo "Source file not found: $1"; usage; }
[ -e "$2"  ] || { echo "Source file not found: $1"; usage; }
[ -e "$3"  ] || { echo "Expected file not found: $2"; usage; }

if [ -f $(which mktemp) ]
then
	ISOLATE=$(mktemp -d)
else
	ISOLATE=$(tempfile)
	rm $ISOLATE
	mkdir -p $ISOLATE
fi

SRC_PATH=$(realpath $1)
SRC_NAME=$(basename $SRC_PATH)
SRC_DIR=$(dirname $SRC_PATH)
INC_DIR=$SRC_DIR/include/

OFC_SRC_PATH=$(realpath $2)

EXPECTED=$(realpath $3)
BEHAVIOUR=$(realpath -m $4)

STDIN_NAME=$SRC_DIR/stdin/$SRC_NAME

## Compile OFC output with gfortran
BINARY=$ISOLATE/a.out
gfortran -x f77 -I $INC_DIR $OFC_SRC_PATH -o $BINARY &> /dev/null
if [ $? -eq 0 ]
then
	pushd $ISOLATE
	if [ -f $STDIN_NAME ]
	then
		cat $STDIN_NAME | $BINARY > $BEHAVIOUR
	else
		$BINARY > $BEHAVIOUR
	fi
	popd
	rm -f $BINARY &> /dev/null
else
	rm -rf $ISOLATE &> /dev/null
	exit 1
fi

rm -rf $ISOLATE &> /dev/null

diff $EXPECTED $BEHAVIOUR &> /dev/null
[ $? -eq 0 ] || exit 1
