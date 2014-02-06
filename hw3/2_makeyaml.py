#!/usr/bin/env python


import yaml
import numpy as np

v = np.random.rand(2**10)

# Convert to list so that we don't get random binary python specific yaml output
# Odd this doesn't work, there are still numpy specific types in there:
#   v = list(v)
w = []
for i in v:
    w += [float(i)]

print yaml.dump({'random vector': w})

#x = yaml.load(open("knuth.yaml"))
#print x['random vector']
