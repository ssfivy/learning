#!/usr/bin/env python3

import pprint
import string
import z3

# use coordinates from top left
# rows 0-8
# cols A-I
# cell = puzzle[row][column]

rows = [ r for r in range(9) ]
cols = [ c for i, c in enumerate(string.ascii_uppercase) if i < 9 ]

puzzle = [ [0 for c in cols ] for r in rows ]

pprint.pprint(puzzle)

# Let's start making constraints!

c_row = z3.Distinct()

s = z3.Solver()
s.add(c_row)
s.add(c_col)
print(s)
print('Solving things...')
print(s.check())
