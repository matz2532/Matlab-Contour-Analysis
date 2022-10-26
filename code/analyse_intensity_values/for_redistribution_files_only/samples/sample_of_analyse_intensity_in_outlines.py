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
microtubule_intensity_projection_imageIn = matlab.double([0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0], size=(8, 8))
cell_outlinesIn = [[matlab.double([1.0], size=(1, 1)), matlab.double([1.0], size=(1, 1)), matlab.double([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 1.0, 1.0], size=(1, 20)), matlab.double([3.0, 2.0, 1.0, 1.0, 1.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0, 5.0, 4.0], size=(1, 20))], [matlab.double([2.0], size=(1, 1)), matlab.double([2.0], size=(1, 1)), matlab.double([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 1.0, 1.0], size=(1, 20)), matlab.double([3.0, 2.0, 1.0, 1.0, 1.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0, 5.0, 4.0], size=(1, 20))]]
boarder_to_ignoreIn = matlab.double([0.0], size=(1, 1))
all_cell_labelsOut, all_anisotropy_valuesOut, all_orientation_valuesOut = my_analyse_intensity_values.analyse_intensity_in_outlines(watershedded_labelled_imageIn, microtubule_intensity_projection_imageIn, cell_outlinesIn, boarder_to_ignoreIn, nargout=3)
print(all_cell_labelsOut, all_anisotropy_valuesOut, all_orientation_valuesOut, sep='\n')

my_analyse_intensity_values.terminate()
