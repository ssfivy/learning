#!/usr/bin/env python3

# Generates a graph of random walk
# Code that adds vectors: https://math.stackexchange.com/a/1365938
# All polar vectors in this code is (magnitude, theta)

import math
import secrets
import unittest

import matplotlib.pyplot as plt

# Configuration!
walker_count = 3
polar_vector_count = 1000
vector_magnitude = 1


def vector_sum_magnitude(magnitude1, theta1, magnitude2, theta2):
    return math.sqrt(magnitude1**2 + magnitude2**2 + 2*magnitude1*magnitude2*math.cos(theta2 - theta1))


def vector_sum_angle(magnitude1, theta1, magnitude2, theta2):
    return theta1 + math.atan2(magnitude2*math.sin(theta2-theta1), magnitude1 + magnitude2*math.cos(theta2-theta1))


# Let's add random walk vectors! All same length, but random direction
polar_vectors = []
for w in range(walker_count):
    polar_vectors.append([(vector_magnitude, secrets.randbelow(361))
                          for i in range(polar_vector_count)])

# oh no all these vectors stack on top of one another
# we have to convert them all into bector from origin if we want to plot them

rmax = 0
magnitudes = []
thetas = []
for w in range(walker_count):
    latest_vector = (0, 0)
    magnitude = [0]
    theta = [0]
    for v in polar_vectors[w]:
        r = vector_sum_magnitude(
            latest_vector[0], latest_vector[1], v[0], v[1])
        t = vector_sum_angle(latest_vector[0], latest_vector[1], v[0], v[1])
        latest_vector = (r, t)
        magnitude.append(r)
        theta.append(t)

        if r > rmax:
            rmax = r

    magnitudes.append(magnitude)
    thetas.append(theta)

# rough auto-scale our plot to size
rmax = math.ceil(rmax + 1)
tickstep = math.floor(rmax / 8)
rticks = list(range(0, rmax, tickstep))

# Plot in polar coordinates
ax = plt.subplot(111, projection='polar')
for w in range(walker_count):
    ax.plot(thetas[w], magnitudes[w])
ax.set_rmax(rmax)
ax.set_rticks(rticks)  # Less radial ticks
ax.set_rlabel_position(-22.5)  # Move radial labels away from plotted line
ax.grid(True)

ax.set_title("A random walk on a polar axis", va='bottom')
plt.show()
