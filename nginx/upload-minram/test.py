#!/usr/bin/env python3

import time
import os

# 'Allocate' memory up and down to test memory monitoring programs
# doesn't have to be accurate, as long as we can test memory monitoring programs

memchunks = {}

memchunks['10k'] = set(range(10_000))
time.sleep(1)
memchunks['15k'] = set(range(15_000))
time.sleep(1)
memchunks['20k'] = set(range(20_000))
time.sleep(1)
memchunks['25k'] = set(range(25_000))
time.sleep(1)
memchunks['30k'] = set(range(30_000))
time.sleep(1)
memchunks['40k'] = set(range(40_000))
time.sleep(1)
memchunks['70k'] = set(range(70_000))
time.sleep(1)
memchunks['100k'] = set(range(100_000))
time.sleep(1)
