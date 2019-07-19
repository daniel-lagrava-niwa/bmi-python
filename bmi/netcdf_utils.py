# -*- coding: utf-8 -*-
"""
Created on Thu Jul 11 16:27:49 2019

@author: lagravasandovald
"""

import xarray as xr

def extract_1d_vector(netcdf_file, variable_name):
    DS = xr.open_dataset(netcdf_file)
    try:
        reach_id = DS.variables["rchid"].values
        out_values = DS.variables[variable_name].values
        return reach_id, out_values
        
    except KeyError as e:
        print("No such value %s on the file" % variable_name)
        print("Exception", e)
        return None


def write_netcdf():
    pass


    