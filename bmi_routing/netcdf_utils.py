# -*- coding: utf-8 -*-
"""
Created on Thu Jul 11 16:27:49 2019

@author: lagravasandovald
"""

import xarray as xr

to_long_name = {
        "RiverFlow" : "Routed stream flow",
        "RiverFlowVelocity": "River Flow Velocity"
        }

to_standard_name = {
        "RiverFlow" : "river_flow_rate",
        "RiverFlowVelocity": "routing__river_flow_velocity"
        }


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


def write_netcdf(file_name, current_time, reaches, lats, lons, var_name, var_values):
    DS_dict = {}
    fill_value = -9999
    dims = {'nrch': len(reaches), 'time': 1}
    attrs = {'title': 'TopNet Routing for river', 'river_basin': 'REC3_SOUTHLAND_15440662_strahler3', 
         'note': 'Index nrch starts at 0', 'institution': 'NIWA', 'reference_geoid': 'WGS84', 'region': 'Aparima', 'no_sub_catchments': len(reaches)}

    coords = { 'end_lon': {'dims': ('nrch',), 
                           'attrs': {'standard_name': 'longitude', 'long_name': 'longitude of downstream end of stream reach', 'units': 'degrees_east', 'axis': 'X', 'valid_min': -180, 'valid_max': 180, '_FillValue': -9999},
                           'data': lons},
               'end_lat': {'dims': ('nrch',), 
                            'attrs': {'standard_name': 'latitude', 'long_name': 'latitude of downstream end of stream reach', 'units': 'degrees_north', 'axis': 'Y', 'valid_min': -90, 'valid_max': 90, '_FillValue': -9999},
                            'data': lats}
             }

    DS_dict['dims'] = dims
    DS_dict['attrs'] = attrs
    DS_dict['coords'] = coords    
    # the reaches
    rchid_attrs = {'standard_name': "rchid",
                 'long_name': 'identifier for stream reach', 'units': '1',
                 'valid_min': 0.0, 'valid_max': 1e+20, 'cell_methods': 'time: mean',
                 'grid_mapping': 'nzgd1949', 'Type': 'NC_INT', '_FillValue': fill_value}
    
    rchid = {'dims': ('nrch',), 'attrs': rchid_attrs, 'data': reaches}

    # the actual variable
    var_attrs = {'description': var_name, 'standard_name': to_standard_name[var_name],
                 'long_name': to_long_name[var_name], 'units': 'meter3 second-1',
                 'valid_min': 0.0, 'valid_max': 1e+20, 'cell_methods': 'time: mean',
                 'grid_mapping': 'nzgd1949', 'Type': 'NC_DOUBLE', '_FillValue': fill_value}
    
    var_output = {'dims': ('time', 'nrch'), 'attrs': var_attrs, 'data': [list(var_values)]}
    
    DS_dict['data_vars'] = {to_standard_name[var_name] : var_output,
                            'rchid': rchid}
    print(DS_dict)
    output_DS = xr.Dataset.from_dict(DS_dict)
    output_DS.to_netcdf(file_name)
    


    