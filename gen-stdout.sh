#!/bin/bash

usage() { echo "Usage: $0 [SOURCE_PATH]" 1>&2; exit 1; }

[ $# -eq 1 ] || usage
[ -e "$1"  ] || { echo "File not found: $11"; usage; }

MKTEMP=tempfile
which mktemp &> /dev/null && MKTEMP=mktemp

TAOUT=$($MKTEMP)
chmod +x $TAOUT

SRC_PATH=$(realpath $1)
SRC_NAME=$(basename $SRC_PATH)
SRC_DIR=$(dirname $SRC_PATH)

STDIN_NAME=$SRC_DIR/stdin/$SRC_NAME
STDOUT_NAME=$SRC_DIR/stdout/$SRC_NAME
mkdir -p $SRC_DIR/stdout

## Compile directly with gfortran
gfortran $SRC_PATH -o $TAOUT &> /dev/null
if [ -e $TAOUT ]
then
	pushd $(dirname $TAOUT)
	rm -f fort.*
	if [ -f $STDIN_NAME ]
	then
		cat $STDIN_NAME | $TAOUT > $STDOUT_NAME
	else
		$TAOUT > $STDOUT_NAME
	fi
	popd
else
	rm $TAOUT &> /dev/null
	exit 1
fi

rm $TAOUT &> /dev/null
