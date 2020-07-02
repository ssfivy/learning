#!/usr/bin/python3

# Test collatz conjencture for a number

import sys
import time
import matplotlib.pyplot as plt
from multiprocessing import Pool

initial = int(sys.argv[1])

# using recursion
# which is definitely not scalable due to stack limit but who cares its fun
def collatz_rec(number):
    print(number)
    if number == 1:
        raise Exception("Finished!")

    elif number % 2 :
        number = number * 3 + 1
    else:
        number /= 2

    collatz_rec(number)

#collatz_rec(initial)

def collatz(number, verbose=False):

    j = number
    steps = 0
    while True:
        if verbose:
            print(j)

        steps += 1

        if j <= 1:
            break
        elif j % 2 :
            j = j * 3 + 1
        else:
            j /= 2

    #print("Finished!")
    return (number, steps)


#collatz(initial)

def isalwaysodd():
    for i in range(1, 10000000):
        if i % 2 and (i * 3 + 1) % 2:
            print(i)
            break
#isalwaysodd()

# we assume every input value goes to 1
# terry tao nearly proved this i aint gonna assume otherwise

# for all values up to the provided one, count steps
start = time.time()
#for i in range(initial):
#    loops.append(collatz(i))

# Multi-processing baby!
# note: with input 10_000_000 this takes 32.527 s on Ryzen 2600 and took 1.8GB of RAM
# note: with input 20_000_000 this takes 71.147 s on Ryzen 2600 and took 3.4GB of RAM
pool = Pool()
results = pool.map(collatz, range(initial))
pool.close()
pool.join()

# sort results
loops = [None] * len(results)
maxsteps = (0,0)
for r in results:
    loops[r[0]] = r[1]
    if maxsteps[1] < r[1]:
        maxsteps = r

finish = time.time()

# easier to do 1 more calc than printing + caching the biggest stack print
collatz(maxsteps[0], True)

print('time taken: {}'.format(finish-start))
print('Maximum steps: {} steps for input {}'.format(maxsteps[1], maxsteps[0]))

plt.plot(loops)
plt.title('Collatz Conjencture: Steps needed to reach 1 from a particular number')
plt.xlabel('Input number')
plt.ylabel('Steps needed')
plt.show()

