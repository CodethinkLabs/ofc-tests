#!/usr/bin/python3

# Python test script for Fortran compilers.

import argparse
import os
from os import walk
import subprocess
import sys

fortranExtensions = [ '.f', '.FOR' ]

def findTests():
    tests = []
    for (dirpath, dirnames, filenames) in walk("programs"):
        for f in filenames:
            if any(lambda x: f.endsWith(x) for x in fortranExtensions):
                tests.append(os.path.join(dirpath,f))
    return tests

def runTests(tests, compiler, outputDir, compilerargs):
    if not os.path.exists(outputDir): os.mkdir(outputDir)
    for t in tests:
        basename = os.path.basename(t)
        stdinFile = os.path.join("programs", "stdin", basename);
        if not os.path.exists(stdinFile):
            stdinFile = "/dev/null" # TODO: Non-posix!
        cmdline = "%s %s %s > %s/%s.stdout 2> %s/%s.stderr < %s && echo $? > %s/%s.exit"%(compiler, compilerargs, t, outputDir, basename, outputDir, basename, stdinFile, outputDir, basename)
        print("running test: %s"%cmdline)
        subprocess.call(cmdline, shell=True)
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output')
    parser.add_argument('-c', '--compiler', default="gfortran")
    parser.add_argument('-a', '--compilerargs', default="")
    args = parser.parse_args()
    if args.output is None:
        print("You must specify an output directory with --output.")
        exit(2)

    tests = findTests()
    runTests(tests, args.compiler, args.output, args.compilerargs)
