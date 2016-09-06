#!/bin/bash

usage() { echo "Usage: $0 [ORIGINAL_SOURCE] [FLANG_BINARY] [EXPECTED] [BEHAVIOUR]" 1>&2; exit 1; }

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

BINARY=$(realpath $2)

EXPECTED=$(realpath $3)
BEHAVIOUR=$4
BEHAVIOUR_NAME=$(basename $BEHAVIOUR)

STDIN_NAME=$SRC_DIR/stdin/$SRC_NAME

TIMEOUT="timeout 3m"

pushd $ISOLATE
if [ -f $STDIN_NAME ]
then
	cat $STDIN_NAME | $TIMEOUT $BINARY > $BEHAVIOUR_NAME
else
	$TIMEOUT $BINARY > $BEHAVIOUR_NAME
fi
popd

mv $ISOLATE/$BEHAVIOUR_NAME $BEHAVIOUR
rm -rf $ISOLATE &> /dev/null

diff $EXPECTED $BEHAVIOUR &> /dev/null
[ $? -eq 0 ] || exit 1
