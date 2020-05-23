#!/usr/bin/env python3

import math
import pprint
import string
import z3

# 9x9 matrix of integer variables
X = [[z3.Int("x_%s_%s" % (i+1, j+1)) for j in range(9)]
     for i in range(9)]
pprint.pprint(X)
print('-------------------')

# each cell contains a value in {1, ..., 9}
cells_c = [z3.And(1 <= X[i][j], X[i][j] <= 9)
           for i in range(9) for j in range(9)]
# pprint.pprint(cells_c)
print('-------------------')

# each row contains a digit at most once
rows_c = [z3.Distinct([X[i][j] for j in range(9)])
          for i in range(9)]
# pprint.pprint(rows_c)
print('-------------------')

# each column contains a digit at most once
cols_c = [z3.Distinct([X[i][j] for i in range(9)])
          for j in range(9)]
# pprint.pprint(cols_c)
print('-------------------')

# each 3x3 square contains a digit at most once
sq_c = [z3.Distinct([X[3*i0 + i][3*j0 + j]
                     for i in range(3) for j in range(3)])
        for i0 in range(3) for j0 in range(3)]
# pprint.pprint(sq_c)
print('-------------------')

sudoku_c = cells_c + rows_c + cols_c + sq_c

###########################


def gen_killer_cage(cage_coords, cage_sum):
    '''Add a single killer sudoku cage.
    Takes a list of (row, col) coordinates and the sum
    '''
    c = []
    cagecells = [X[i][j] for i, j in cage_coords]
    # Digits dont repeat within cages
    c.append(z3.Distinct(cagecells))
    c.append(z3.Sum([cagecells]) == cage_sum)
    pprint.pprint(c)
    return c

# Try implementing solver for this: https://www.youtube.com/watch?v=QRM4T8dq9oc


cages = []
cages.append({'coords': [(0, 0), (0, 1), (1, 0), (2, 0), (3, 0)], 'sum': 20})
cages.append({'coords': [(0, 2), (0, 3), ], 'sum': 14})
cages.append({'coords': [(0, 5), (0, 6)], 'sum': 10})
cages.append({'coords': [(0, 7), (0, 8), (1, 8), (2, 8), (3, 8), ], 'sum': 20})
cages.append({'coords': [(1, 1), (2, 1)], 'sum': 11})
cages.append({'coords': [(1, 2), (1, 3), (1, 4), (1, 5), (1, 6), ], 'sum': 21})
cages.append({'coords': [(1, 7), (2, 7)], 'sum': 13})
cages.append({'coords': [(2, 2), (2, 3), (3, 3)], 'sum': 20})
cages.append({'coords': [(2, 4), (3, 4)], 'sum': 12})
cages.append({'coords': [(2, 5), (3, 5), (2, 6)], 'sum': 12})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})
cages.append({'coords': [(,), (,), (,), (,), (,), ], 'sum': x})


cage_c = [gen_killer_cage(c['coords'], c['sum']) for c in cages]

###########################


instance = ((0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0))

instance = ((0, 0, 0, 0, 5, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (8, 0, 0, 0, 0, 0, 0, 0, 9),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 6, 0, 0, 0, 0))

instance_c = [z3.If(instance[i][j] == 0,
                    True,
                    X[i][j] == instance[i][j])
              for i in range(9) for j in range(9)]

s = z3.Solver()
s.add(sudoku_c + instance_c)
if s.check() == z3.sat:
    m = s.model()
    r = [[m.evaluate(X[i][j]) for j in range(9)]
         for i in range(9)]
    pprint.pprint(r)
else:
    print("failed to solve")
