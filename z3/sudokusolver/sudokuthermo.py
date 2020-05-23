#!/usr/bin/env python3

# Solving thermo sudoku: https://www.youtube.com/watch?v=va3xrk7YALo

import math
import pprint
import string
import z3

# 9x9 matrix of integer variables
X = [[z3.Int("x_%s_%s" % (i+1, j+1)) for j in range(9)]
     for i in range(9)]
pprint.pprint(X)
# print('-------------------')

# each cell contains a value in {1, ..., 9}
cells_c = [z3.And(1 <= X[i][j], X[i][j] <= 9)
           for i in range(9) for j in range(9)]
# pprint.pprint(cells_c)
# print('-------------------')

# each row contains a digit at most once
rows_c = [z3.Distinct([X[i][j] for j in range(9)])
          for i in range(9)]
# pprint.pprint(rows_c)
# print('-------------------')

# each column contains a digit at most once
cols_c = [z3.Distinct([X[i][j] for i in range(9)])
          for j in range(9)]
# pprint.pprint(cols_c)
# print('-------------------')

# each 3x3 square contains a digit at most once
sq_c = [z3.Distinct([X[3*i0 + i][3*j0 + j]
                     for i in range(3) for j in range(3)])
        for i0 in range(3) for j0 in range(3)]
# pprint.pprint(sq_c)
# print('-------------------')

sudoku_c = cells_c + rows_c + cols_c + sq_c

###########################
# Thermometer sudoku


def add_thermometer(s, thermometer):
    '''Add a single thermometer sudoku thermometer.
    Takes a list of (row, col) coordinates in increasing order
    '''
    prevmark = None
    for mark in thermometer:
        if prevmark is not None:
            # Add constraint: mark must be bigger than previous mark
            # (implies distinct as well)
            i, j = mark
            ip, jp = prevmark
            s.add(X[ip][jp] < X[i][j])
        else:
            # Very first mark, nothing to compare to
            pass
        prevmark = mark


thermos = []
thermos.append([(1, 7), (0, 6), (0, 5), (0, 4), (0, 3), (0, 2), (1, 1), ])
thermos.append([(2, 1), (3, 2), (3, 3), (4, 4), (5, 5), (5, 6), (6, 7), ])
thermos.append([(7, 7), (8, 6), (8, 5), (8, 4), (8, 3), (8, 2), (7, 1), ])

###########################


instance = ((0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 8),
            (5, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 2, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 7, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 6),
            (6, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0))


instance_c = [z3.If(instance[i][j] == 0,
                    True,
                    X[i][j] == instance[i][j])
              for i in range(9) for j in range(9)]

s = z3.Solver()

for t in thermos:
    add_thermometer(s, t)

s.add(sudoku_c + instance_c)
if s.check() == z3.sat:
    m = s.model()
    r = [[m.evaluate(X[i][j]) for j in range(9)]
         for i in range(9)]
    pprint.pprint(r)
else:
    print("failed to solve")
