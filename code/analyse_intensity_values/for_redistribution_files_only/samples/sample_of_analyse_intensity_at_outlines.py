#!/usr/bin/env python
"""
Sample script that uses the analyse_intensity_values module created using
MATLAB Compiler SDK.

Refer to the MATLAB Compiler SDK documentation for more information.
"""

from __future__ import print_function
import analyse_intensity_values
import matlab

my_analyse_intensity_values = analyse_intensity_values.initialize()

watershedded_labelled_imageIn = matlab.double([0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0], size=(8, 8))
microtubule_intensity_projection_imageIn = matlab.double([124.0, 111.0, 114.0, 78.0, 130.0, 130.0, 209.0, 203.0, 164.0, 96.0, 207.0, 136.0, 89.0, 240.0, 224.0, 140.0, 159.0, 150.0, 53.0, 77.0, 120.0, 59.0, 216.0, 49.0, 57.0, 43.0, 58.0, 111.0, 79.0, 236.0, 110.0, 47.0, 231.0, 250.0, 112.0, 28.0, 66.0, 104.0, 152.0, 67.0, 154.0, 182.0, 56.0, 30.0, 75.0, 81.0, 108.0, 130.0, 21.0, 67.0, 205.0, 7.0, 237.0, 186.0, 125.0, 148.0, 60.0, 117.0, 246.0, 139.0, 133.0, 59.0, 125.0, 159.0], size=(8, 8))
cell_outlinesIn = [[matlab.double([1.0], size=(1, 1)), matlab.double([1.0], size=(1, 1)), matlab.double([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 1.0, 1.0], size=(1, 20)), matlab.double([3.0, 2.0, 1.0, 1.0, 1.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0, 5.0, 4.0], size=(1, 20))]]
data_singleOut = my_analyse_intensity_values.analyse_intensity_at_outlines(watershedded_labelled_imageIn, microtubule_intensity_projection_imageIn, cell_outlinesIn)
print(data_singleOut, sep='\n')

my_analyse_intensity_values.terminate()
