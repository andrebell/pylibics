#!/usr/bin/python
# -*- coding: utf-8 -*-

import numpy
import pylibics
import pylab

ics = pylibics.IcsOpen('testimages/testim.ics', 'r')

im = pylibics.IcsGetData(ics)

print('Image shape:', im.shape)
print('Image dtype:', im.dtype)

pylab.imshow(im[0,:,:], cmap='gray')
pylab.show()

