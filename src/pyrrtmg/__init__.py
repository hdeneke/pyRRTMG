import _rrtmg

_rrtmg.init(1005.6)

nbnd_lw = 16 # number of longwave bands
nbnd_sw = 14 # number of shortwave bands

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

_rrtmg_inputs = [
    "icld", "iaer", "permuteseed_sw", "permuteseed_lw", 
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

_rrtmg_outputs = [ 
    'swuflx',  'swdflx',  'swhr',
    'swuflxc', 'swdflxc', 'swhrc',
    'lwuflx',  'lwdflx',  'lwhr',
    'lwuflxc', 'lwdflxc', 'lwhrc'
]

def calc_flxhr(*args,**kwargs):
    '''
    Calculate fluxes and heating rates
    '''
    if len(args)==0:
        # Using named arguments
        args = [ kwargs.get(k,None) for k in _rrtmg_inputs ]
    return dict(zip(_rrtmg_outputs,_rrtmg.flxhr(*args)))


