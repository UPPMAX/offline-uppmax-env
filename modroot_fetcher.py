#!/bin/env python3
import sys
import tkinter

# get name of module file as argument
modfile = sys.argv[1]

# create tcl reader
tcl = tkinter.Tcl()

# evaluate the file
tcl.eval('source /usr/share/lmod/lmod/libexec/tcl2lua.tcl')
tcl.eval(f'source {modfile}')

# get the modroot
modroot = tcl.eval('return $modroot')
modversion = tcl.eval('return $version')
