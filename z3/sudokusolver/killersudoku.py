#!/usr/bin/env python3

# solves for killer sudoku, specifically this: https://www.youtube.com/watch?v=QRM4T8dq9oc

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


def add_killer_cage(s, cage_coords, cage_sum):
    '''Add a single killer sudoku cage.
    Takes a list of (row, col) coordinates and the sum
    '''
    cagecells = [X[i][j] for i, j in cage_coords]
    # Digits dont repeat within cages
    s.add(z3.Distinct(cagecells))
    s.add(z3.Sum(cagecells) == cage_sum)


# man these are really annoying to type
# not gonna do more killer sudokus

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
cages.append({'coords': [(3, 1), (3, 2), (4, 1), (5, 1), (5, 2), ], 'sum': 27})
cages.append({'coords': [(3, 6), (3, 7), (4, 7), (5, 7), (5, 6), ], 'sum': 27})
cages.append({'coords': [(4, 2), (4, 3)], 'sum': 9})
cages.append({'coords': [(4, 5), (4, 6)], 'sum': 10})
cages.append({'coords': [(5, 0), (6, 0), (7, 0), (8, 0), (8, 1), ], 'sum': 20})
cages.append({'coords': [(5, 3), (6, 3), (6, 2)], 'sum': 8})
cages.append({'coords': [(5, 4), (6, 4), ], 'sum': 16})
cages.append({'coords': [(5, 5), (6, 5), (6, 6), ], 'sum': 14})
cages.append({'coords': [(5, 8), (6, 8), (7, 8), (8, 8), (8, 7), ], 'sum': 19})
cages.append({'coords': [(6, 1), (7, 1), ], 'sum': 11})
cages.append({'coords': [(6, 7), (7, 7), ], 'sum': 13})
cages.append({'coords': [(7, 2), (7, 3), (7, 4), (7, 5), (7, 6), ], 'sum': 23})
cages.append({'coords': [(8, 2), (8, 3)], 'sum': 13})
cages.append({'coords': [(8, 5), (8, 6)], 'sum': 13})


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

for c in cages:
    add_killer_cage(s, c['coords'], c['sum'])

s.add(sudoku_c + instance_c)
if s.check() == z3.sat:
    m = s.model()
    r = [[m.evaluate(X[i][j]) for j in range(9)]
         for i in range(9)]
    pprint.pprint(r)
else:
    print("failed to solve")
