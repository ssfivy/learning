#!/usr/bin/env python3

from z3 import *

x = Int('x')
y = Int('y')
solve(x > 2, y < 10, x + 2*y == 7)

print(simplify(x + y + 2*x + 3))
print(simplify(x < y + x + 2))
print(simplify(And(x + 1 >= 3, x**2 + x**2 + y**2 + 2 >= 5)))


# (x - 3)*(x + 2)*(x + 5)
# (x**2 - x - 6) * (x + 5)
# x**3 - x**2 - 6*x + 5*x**2 - 5*x - 30
print(simplify(x**3 - x**2 - 6*x + 5*x**2 - 5*x - 30))
print(simplify((x - 3)*(x + 2)*(x + 5)))

x = Int('x')
solve(x**3 - x**2 - 6*x + 5*x**2 - 5*x - 30 == 14)

dog, cat, mouse = Ints('dog cat mouse')
solve(dog >= 1,   # at least one dog
      cat >= 1,   # at least one cat
      mouse >= 1,  # at least one mouse
      # we want to buy 100 animals
      dog + cat + mouse == 100,
      # We have 100 dollars (10000 cents):
      #   dogs cost 15 dollars (1500 cents),
      #   cats cost 1 dollar (100 cents), and
      #   mice cost 25 cents
      1500 * dog + 100 * cat + 25 * mouse == 10000)
