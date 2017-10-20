#!/usr/bin/env python
import os,glob,string,sys,shutil
from numpy.distutils.core import setup, Extension
from numpy.distutils import fcompiler
from distutils.dep_util import newer

def get_fc():
    ''' get Fortran compiler '''
    fc = fcompiler.get_default_fcompiler()
    for i in range(len(sys.argv)):
        if '--fcompiler' in sys.argv[i]:
            fc = sys.argv.pop(i)
            fc = fc[fc.index('=')+1:]
    return fc

def get_fflags(fc):
    '''get Fortran compiler flags '''
    if fc == 'gnu95':
        fflags=['-fdefault-real-8','-fno-range-check','-ffree-form']
    elif fc == 'intel' or fc == 'intelem':
        fflags='-132 -r8'
    elif fc == 'ibm':
        fflags='-qautodbl=dbl4 -qsuffix=f=f90:cpp=F90 -qfree=f90'
    else:
        fflags=None
    return fflags

def get_flags():
    fc = get_fc()
    return get_fflags(fc)

def get_sources():
    fname = os.path.join('src_f','src_list')
    with open(fname) as f:
        src_files = [os.path.join('src_f',s.strip()) for s in f.readlines()]
    src_files.append(os.path.join('src_f','_rrtmg.pyf'))
    return src_files

if __name__ == "__main__":
    from numpy.distutils.core import setup
    src_list = get_sources()
    ext_rrtmg = Extension( 
        name = '_rrtmg',
        sources = src_list,
        extra_f90_compile_args = ['-fdefault-real-8','-fno-range-check','-ffree-form' ]
    )
    setup(
        name = "pyrrtmg",
        version = open('VERSION').read().rstrip('\r\n'),
        description = "Python Interface for RRTMG",
        author = "Hartwig Deneke",
        author_email = "deneke@tropos.de",
        url = "http://sat.tropos.de/",
        packages = [ 'pyrrtmg' ],
        package_dir = { '': 'src'},
        ext_package = 'pyrrtmg',
        ext_modules = [ ext_rrtmg ],
    )

