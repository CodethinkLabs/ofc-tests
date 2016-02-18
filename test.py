#!/usr/bin/python3

# Python test script for Fortran compilers.

import argparse
import os
from os import walk
import subprocess
import sys

# Anything with these extensions is a Fortran source file,
# unless it's in one of the 'excludePaths' below.
fortranExtensions = [ '.f', '.FOR' ]

# Any files in directories called these names are not tests
# (but subdirectories will still be searched)
excludePaths = [ 'stdin', 'stdout', 'stderr' ]


def findTests():
    tests = []
    for (dirpath, dirnames, filenames) in walk("programs"):
        (_,tail) = os.path.split(dirpath)
        if tail in excludePaths: continue
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
        cmdline = "%s %s %s > %s/%s.stdout 2> %s/%s.stderr < %s"%(compiler, compilerargs, t, outputDir, basename, outputDir, basename, stdinFile)
        print("running test: %s"%cmdline)
        res = subprocess.call(cmdline, shell=True)
        exitFile = open(os.path.join(outputDir,basename)+".exit", 'w')
        exitFile.write("%d\n"%res)
        exitFile.close()
    

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
