import numpy as np
import xarray as xr
from collections import OrderedDict as odict
import matplotlib.pyplot as plt

import  pyrrtmg as rrtmg

# ECMWF 
data_dir='/home/deneke/src/staging/rrtmg_carola/'

ecmwf_fname=data_dir+'2009097103151_15656_CS_ECMWF-AUX_GRANULE_P_R04_E02.nc'

vars = {
    # Pressure info
    'Play'   : 'ECMWF-AUX_Pressure',
    'Psfc'   : 'ECMWF-AUX_Surface_pressure',
    # Temperature info
    'Tlay'   : 'ECMWF-AUX_Temperature',
    'T2m'    : 'ECMWF-AUX_Temperature_2m',
    'Tsfc'   : 'ECMWF-AUX_Skin_temperature',
    'h2ovmr' : 'ECMWF-AUX_Specific_humidity',
    'o3vmr'  : 'ECMWF-AUX_Ozone'
}

# Molecular weight in kg/mol
mw = {
    'h2o' : 0.01802,
    'o3'  : 0.047995,
    'air' : 0.028965
}

# volume mixing ratio
vmr = {
    'o2'    :    0.2046,
    'co2'   :  399.5e-6,
    'ch4'   : 1834.0e-9,
    'n2o'   :  328.0e-9,
    'cfc11' : 232.0e-12,
    'cfc12' : 516.0e-12,
    'cfc22' : 233.0e-12,
    'ccl4'  :  82.0e-12,
}

# Misc constants

ncol = 300     # Number of columns
nlay = 105     # Number of layers
nlev = nlay+1  # Number of levels

# open ECMWF_AUX dataset and read atmospheric variables
ecmwf = xr.open_dataset(ecmwf_fname)
atm = {}
for k,v in vars.items():
    if len(ecmwf[v].shape)==2:
        atm[k] = np.asfortranarray(ecmwf[v].values[:ncol,(nlay-1)::-1],dtype=np.float64)
    else:
        atm[k] = np.asfortranarray(ecmwf[v].values[:ncol],dtype=np.float64)
# convert specific humidity to volume mixing ratio
atm['h2ovmr'] = mw['air']/mw['h2o']*atm['h2ovmr']/(1.0-atm['h2ovmr'])
# Convert ozone from mass to volume mixing ratio
atm['o3vmr'] = mw['air']/mw['o3']*atm['o3vmr']

# add trace gas concentrations
for s in ['co2', 'ch4', 'n2o', 'o2', 'cfc11', 'cfc12', 'cfc22', 'ccl4']:
    k = s+'vmr'
    atm[k] = np.full_like(atm['o3vmr'],vmr[s])
# Convert pressure to millibar
atm['Play'] *= 0.01
atm['Psfc'] *= 0.01
# get pressure on levels
p0 = atm['Psfc'][:,None]
p1 = 0.5*(atm['Play'][:,0:-1]+atm['Play'][:,1:])
p2 = atm['Play'][:,-1:]
atm['Plev'] = np.asfortranarray(np.hstack((p0,p1,p2)),dtype=np.float64)
# get temperature on levels
t0 = atm['T2m'][:,None]
t1 = 0.5*(atm['Tlay'][:,0:-1]+atm['Tlay'][:,1:])
t2 = atm['Tlay'][:,-1:]
atm['Tlev'] = np.asfortranarray(np.hstack((t0,t1,t2)),dtype=np.float64)

# build list of RRTMG inputs
rrtmg_input = [
    0,                  # icld
    0,                  # iaer
    0,                  # permuteseed_sw
    0,                  # permuteseed_lw
    0,                  # irng
    0,                  # idrv
]

# append list of atmospheric fields to RRTMG inputs
atm_args = ['Play','Plev','Tlay','Tlev','Tsfc','h2ovmr','o3vmr','co2vmr','ch4vmr','n2ovmr', \
            'o2vmr','cfc11vmr','cfc12vmr','cfc22vmr','ccl4vmr']
rrtmg_input.extend([atm[k] for k in atm_args])

# append surface properties
aldif = np.full((ncol),0.3,dtype=np.float64,order='F')
aldir = np.full((ncol),0.3,dtype=np.float64,order='F')
asdif = np.full((ncol),0.05,dtype=np.float64,order='F')
asdir = np.full((ncol),0.05,dtype=np.float64,order='F')
emis = np.full((ncol,rrtmg.nbnd_lw),1.0,dtype=np.float64,order='F')
rrtmg_input.extend([aldif,aldir,asdif,asdir,emis])

# append surface properties
coszen = np.full((ncol),0.8,dtype=np.float64,order='F')
rrtmg_input.extend([coszen,1.0,1,1365.0,0,0,0,0,0,0])

# append cloud properties
tauc_sw = np.full((rrtmg.nbnd_sw,ncol,nlay),0.8,dtype=np.float64,order='F')
tauc_lw = np.full((rrtmg.nbnd_lw,ncol,nlay),0.8,dtype=np.float64,order='F')
cldfrac = np.full((ncol,nlay),0.8,dtype=np.float64,order='F')
asmc_sw = np.full((rrtmg.nbnd_sw,ncol,nlay),0.8,dtype=np.float64,order='F')
ssac_sw = np.full((rrtmg.nbnd_sw,ncol,nlay),0.8,dtype=np.float64,order='F')
fsfc_sw = np.full((rrtmg.nbnd_sw,ncol,nlay),0.8,dtype=np.float64,order='F')
rrtmg_input.extend([tauc_sw,tauc_lw,cldfrac,asmc_sw,ssac_sw,fsfc_sw])
ciwp = np.zeros((ncol,nlay),dtype=np.float64,order='F')
clwp = np.zeros((ncol,nlay),dtype=np.float64,order='F')
reic = np.full((ncol,nlay),10.0,dtype=np.float64,order='F')
relq = np.full((ncol,nlay),10.0,dtype=np.float64,order='F')
rrtmg_input.extend([ciwp,clwp,reic,relq])

# append aerosol properties
tauaer_sw = np.full((ncol,nlay,rrtmg.nbnd_sw),0.0,dtype=np.float64,order='F')
ssaaer_sw = np.full((ncol,nlay,rrtmg.nbnd_sw),1.0,dtype=np.float64,order='F')
asmaer_sw = np.full((ncol,nlay,rrtmg.nbnd_sw),0.0,dtype=np.float64,order='F')
ecaer_sw  =  np.full((ncol,nlay,6),0.0,dtype=np.float64,order='F')
tauaer_lw = np.full((ncol,nlay,rrtmg.nbnd_lw),0.0,dtype=np.float64,order='F')
rrtmg_input.extend([tauaer_sw,ssaaer_sw,asmaer_sw,ecaer_sw,tauaer_lw])

# get inputs as ordered dict
rrtmg_input = odict(zip(rrtmg._rrtmg_inputs,rrtmg_input))

flxhr = rrtmg.calc_flxhr(**rrtmg_input)

plt.plot(flxhr['swdflx'][0,:],np.arange(106))
plt.plot(flxhr['swuflx'][0,:],np.arange(106))
plt.plot(flxhr['lwdflx'][0,:],np.arange(106))
plt.plot(flxhr['lwuflx'][0,:],np.arange(106))
plt.show()
