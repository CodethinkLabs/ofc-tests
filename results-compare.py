#!/usr/bin/python3

import argparse
import os
from os import walk
import subprocess
import sys

def findTests(directory):
    tests = []
    for (dirpath, dirnames, filenames) in walk(directory):
        for f in filenames:
            if f.endswith(".stdout"):
                tests.append(f.rstrip(".stdout"))
    print(tests)
    return tests

def compare(dira, dirb, test):
    fails = []
    for extension in ['.stdout','.stderr','.exit']:
        filea = os.path.join(dira, test) + extension
        fileb = os.path.join(dirb, test) + extension
        if not os.path.exists(filea):
            fails.append(extension+" MISSING in A")
        elif not os.path.exists(fileb):
            fails.append(extension+" MISSING in B")
        else:
            process = subprocess.Popen(["diff", "-q", filea, fileb], stdout=subprocess.PIPE)
            res = process.wait()
            if res != 0:
                fails.append(extension)

    green = "\033[32m"
    red = "\033[31m"
    colreset = "\033[39m"

    if len(fails)==0:
        print(green+"%s MATCH"%test+colreset)
        return True
    else:
        print(red+"%s FAILS (%s)"%(test, ", ".join(sorted(fails)))+colreset)
        return False

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-a')
    parser.add_argument('-b')
    args = parser.parse_args()
    if args.a is None or not os.path.exists(args.a):
        print("You must specify the first results -a <directory>.")
        exit(2)
    if args.b is None or not os.path.exists(args.b):
        print("You must specify the second results -b <directory>.")
        exit(2)

    atests = frozenset(findTests(args.a))
    btests = frozenset(findTests(args.b))

    totals = { False: 0, True: 0 }
    
    for t in (atests.intersection(btests)):
        res = compare(args.a, args.b, t)
        totals[res] += 1

    print("Total: %s passes, %s failures (%2.0f%% pass)"%(totals[True], totals[False], 100.0*totals[True]/(totals[True]+totals[False])))
        
    if len(atests.intersection(btests)) == len(atests):
        print("All tests found were present in all results.")
    else:
        aonly = atests.difference(btests)
        bonly = btests.difference(atests)
        if len(aonly)>0:
            print ("These tests were found only in set A (%s): %s"%(args.a, ", ".join(list(aonly))))
        if len(bonly)>0:
            print ("These tests were found only in set B (%s): %s"%(args.b, ", ".join(list(bonly))))
