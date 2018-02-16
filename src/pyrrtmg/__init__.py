import _rrtmg

_rrtmg.init(1005.6)

nbnd_lw = 16 # number of longwave bands
nbnd_sw = 14 # number of shortwave bands
naer_ec =  6 # number of ECMWF aerosol types

# default values for volume mixing ratios
vmr_defaults = {
    'o2'    :    0.2046,
    'co2'   :  399.5e-6,
    'ch4'   : 1834.0e-9,
    'n2o'   :  328.0e-9,
    'cfc11' : 232.0e-12,
    'cfc12' : 516.0e-12,
    'cfc22' : 233.0e-12,
    'ccl4'  :  82.0e-12,   
}

input_vars = [
    "icld", "iaer", 
    "permuteseed_sw", "permuteseed_lw", 
    "irng", "idrv",
    "play", "plev",
    "tlay", "tlev", "tsfc",
    "h2ovmr", "o3vmr", "co2vmr",
    "ch4vmr", "n2ovmr", "o2vmr",
    "cfc11vmr", "cfc12vmr", "cfc22vmr", "ccl4vmr",
    "aldif", "aldir", "asdif", "asdir", "emis",
    "coszen", "adjes", "dyofyr",
    "scon", "inflgsw", "inflglw",
    "iceflgsw", "iceflglw",
    "liqflgsw", "liqflglw",
    "tauc_sw", "tauc_lw", "cldfrac",
    "ssac_sw", "asmc_sw","fsfc_sw",
    "ciwp", "clwp", "reic", "relq",
    "tauaer_sw", "ssaaer_sw", "asmaer_sw",
    "ecaer_sw", "tauaer_lw"
]

input_vars_sw = [
    "icld", "iaer", 
    "permuteseed_sw",
    "irng",
    "play", "plev",
    "tlay", "tlev", "tsfc",
    "h2ovmr", "o3vmr", "co2vmr",
    "ch4vmr", "n2ovmr", "o2vmr",
    "aldif", "aldir", "asdif", "asdir",
    "coszen", "adjes", "dyofyr",
    "scon", "inflgsw",
    "iceflgsw","liqflgsw",
    "tauc_sw", "cldfrac",
    "ssac_sw", "asmc_sw","fsfc_sw",
    "ciwp", "clwp", "reic", "relq",
    "tauaer_sw", "ssaaer_sw", "asmaer_sw",
    "ecaer_sw"
]

input_vars_lw = [
    "icld", "iaer", 
    "permuteseed_lw", 
    "irng", "idrv",
    "play", "plev",
    "tlay", "tlev", "tsfc",
    "h2ovmr", "o3vmr", "co2vmr",
    "ch4vmr", "n2ovmr", "o2vmr",
    "cfc11vmr", "cfc12vmr", "cfc22vmr", "ccl4vmr",
    "emis",
    "inflglw", "iceflglw", "liqflglw",
    "tauc_lw", "cldfrac",
    "ciwp", "clwp", "reic", "relq",
    "tauaer_lw"
]

output_vars = [ 
    'swuflx',  'swdflx',  'swdirflx',  'swhr',
    'swuflxc', 'swdflxc', 'swdirflxc', 'swhrc',
    'lwuflx',  'lwdflx',  'lwhr',
    'lwuflxc', 'lwdflxc', 'lwhrc'
]

def calc_flxhr(*args,**kwargs):
    '''
    Calculate fluxes and heating rates for both SW/LW
    '''

    # Check inputs
    narg = len(args)
    if narg==0:
        # Using named arguments
        if len(kwargs)==len(input_vars):
            try:
                args = [ kwargs[k] for k in input_vars ]
            except KeyError:
                raise ValueError('Missing keyword argument {0} to calc_flxhr!'.format(k))
        else:
                raise ValueError('Wrong number of keyword arguments to calc_flxhr!')
    elif narg!=len(input_vars):
        # Using argument list
        raise ValueError('Wrong number of input arguments to calc_flxhr!')
    # run RRTMG
    flxhr = _rrtmg.flxhr(*args)
    # return outputs as dict
    return dict(zip(output_vars,flxhr))

def calc_flxhr_sw(*args,**kwargs):
    '''
    Calculate fluxes and heating rates for SW
    '''

    # Check inputs
    narg = len(args)
    if narg==0:
        # Using named arguments
        try:
            args = [ kwargs[k] for k in input_vars_sw ]
        except KeyError:
            raise ValueError('Missing keyword argument {0} to calc_flxhr_sw!'.format(k))
    elif narg!=len(input_vars_sw):
        # Using argument list
        raise ValueError('Wrong number of input arguments to calc_flxhr!')
    # run RRTMG
    flxhr = _rrtmg.flxhr_sw(*args)
    # return outputs as dict
    return dict(zip(output_vars[:8],flxhr))

def calc_flxhr_lw(*args,**kwargs):
    '''
    Calculate fluxes and heating rates for LW
    '''

    # Check inputs
    narg = len(args)
    if narg==0:
        # Using named arguments
        try:
            args = [ kwargs[k] for k in input_vars_lw ]
        except KeyError:
            raise ValueError('Missing keyword argument {0} to calc_flxhr_lw!'.format(k))
    elif narg!=len(input_vars_lw):
        # Using argument list
        raise ValueError('Wrong number of input arguments to calc_flxhr_lw!')
    # run RRTMG
    flxhr = _rrtmg.flxhr_lw(*args)
    # return outputs as dict
    return dict(zip(output_vars[8:],flxhr))
