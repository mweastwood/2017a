from pylab import *
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors

class MyLogNormalize(colors.Normalize):
    def __init__(self, vmin=None, vmax=None, base=None, clip=False):
        self.base = base
        colors.Normalize.__init__(self, vmin, vmax, clip)

    def __call__(self, value, clip=None):
        base = self.base
        value = maximum(value, self.vmin)
        value = minimum(value, self.vmax)
        numerator   = log10(    value - self.vmin + base) - log10(base)
        denominator = log10(self.vmax - self.vmin + base) - log10(base)
        out = numerator / denominator
        return np.ma.masked_array(out)

