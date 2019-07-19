Python wrapper for BMI models (Modified for River Routing)
==========================================

This is a fork of the bmi-python from openearth. 

The differences are:
- set_var has the capability to read from a netcdf file if the variable is on a list
- get_var is written to a netcdf if the variable we want is on a given list

This project will only work with the Fortran libraries for river routing developed by NIWA. 


