# pyRRTMG Package Installation

To install pyRRTMG, the following steps are needed:
1. Extract package: `tar -xf pyrrtmg-$(VERSION).tar.gz`
2. Change into package directory: `cd pyrrtmg-$(VERSION)`
3. Call python setup.py script: `python setup.py install`

Please note that this requires the gfortran compiler, and compiling
the RRTMG Fortran sources takes significant amoutn of time (>40
minutes!!!). For testing purposes, do consider compiling the code
without optimization, using the following command for step 3:
`python setup.py config_fc --noopt install`

Currently, compilation with other compilers than gfortran is not
supported, as I am unable to test the required changes. Please contact
me (deneke@tropos.de) if you are interested in working on this feature
(the needed compiler-specific flags for compilation have to be found).

For development/testing, it is sometimes useful to manually build the
fortran code into the _rrtmg.so extension. This can be achieved as
follows:

Full build:
```
pushd src_f
# build f2py signature file
f2py -h _rrtmg.pyf --overwrite-signature -m _rrtmg _rrtmg.f90
# compile extension
f2py -c -m _rrtmg --build-dir build --fcompiler=gnu95 --f90flags="-fdefault-real-8 -fno-range-check -ffree-form"  _rrtmg.pyf `cat src_list`
popd
```

Partial rebuild:
```
cat src_list  | sed -e 's/f90$/o/g' | awk '{print "./build/"$1 }' > obj_list
f2py -c -m _rrtmg --build-dir build --fcompiler=gnu95 --f90flags="-fdefault-real-8 -fno-range-check -ffree-form"  _rrtmg.pyf
```



