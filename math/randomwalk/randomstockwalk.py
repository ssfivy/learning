#!/usr/bin/env python3

from random import choice, uniform
from matplotlib import pyplot
import copy

#set up parameters
days = 365 * 3
initial = 100
stocks = 1
#volatile = choice([-1,0,1])
#volatile = uniform(-1,1)

# initialise array
p = [initial] * days
index = [0] * days
prices = [copy.deepcopy(p) for i in range(stocks)]

#initialise bayesian

class BayesianEstimate:
    def __init__(self, initial, plus, minus):
        self.prob_initial = initial
        self.prob_true = plus
        self.prob_false = minus
    def estimate(self, event):
        if event:
            self.prob_initial = (self.prob_initial * self.prob_true) /((self.prob_initial * self.prob_true) + self.prob_false * (1 - self.prob_initial)) 

# randomly generate stock price by flipping coins
i = 1
while i < days:
    for p in prices:
        p[i] = p[i-1] + uniform(-1,1.05)
        #p[i] = p[i-1] + choice([-1,1])
        index[i] += p[i]
    index[i] /= stocks
    i+=1

# generate convincing plot
for p in prices:
    pyplot.plot(p)
#pyplot.step(index, '.')
pyplot.show()

