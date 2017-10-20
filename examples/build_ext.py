import os

import os
import glob
import string
import sys
import re

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
        fflags='-fdefault-real-8 -fno-range-check -ffree-form'
    elif fc == 'intel' or fc == 'intelem':
        fflags='-132 -r8'
    elif fc == 'ibm':
        fflags='-qautodbl=dbl4 -qsuffix=f=f90:cpp=F90 -qfree=f90'
    else:
        fflags=None
    return fflags

def gen_sig(ext,src,dst):
    ''' generate pyf signature file '''
    if not os.path.exists(dst) or newer(src,dst):
        print 'Generating signature file {0}'.format(dst)
        os.system('f2py -h {dst} -m {ext} --overwrite-signature {src} 2>&1 > /dev/null'.format(src=src,dst=dst,ext=ext))
    else:
        print 'Up-to-date signature file {0} found.'.format(dst)
    return

def build_dynlib(fc,fflags,build_dir,ext,deps):
    ''' build dynamic library '''
    # do_build=False
    # for d in deps:
    #     if newer(d,ext+'.so'):
    #         do_build=True
    #         break
    # print do_build
    # if do_build:
    print 'Building dynamic library {0}.'.format(ext+'.so')
    dep_str = str.join(' ', dep_list)
    cmd = 'f2py -c --build-dir {build_dir} -m {ext} --fcompiler={fc} --f90flags="{fflags}" '      \
          '{ext}.pyf {deps}'.format( build_dir=build_dir, ext=ext, fc=fc, fflags=fflags, deps=dep_str )
    os.system(cmd)
#    else:
#        'Up-to-date dynamic library {0} found.'.format(ext+'.so')
    return


def build_ext(src_dir,ext_name):
    ''' build extension '''
    src_list  = 'src_list'
    build_dir = 'build'
    ext_file  = ext_name+'.so'
    sig_src   = ext_name+'.f90'
    sig_dst   = ext_name+'.pyf'
    # Get Fortran compiler
    fc = get_fc()
    print 'Using fortran compiler: {0}'.format(fc)
    # Get Fortran compiler flags
    fflags = get_fflags(fc)
    if fflags==None: 
        print 'Sorry, compiler {0} not supported'.format(compiler)
        return -1
    os.chdir(src_dir)
    print 'Entering {0}.'.format(src_dir)
    # Create build dir if it does not exist
    if not os.path.exists(build_dir):
        print 'Creating build dir {0}.'.format(build_dir)
        os.mkdir(build_dir)
    else:
        print 'Build dir {0} exists.'.format(build_dir)
        # Generate signature file
    gen_sig(ext_name,sig_src,sig_dst)
    # Generate src list
    with open(src_list) as f:
        src_files = [s.strip() for s in f.readlines()]
    obj_files=[os.path.join(build_dir,s[:-4]+'.o') for s in src_files if s[-4:]=='.f90']
    #dep_list=[s if newer(s,o) else o for (s,o) in zip(src_files,obj_files)]
    dep_list = src_files
    gen_dynlib(fc,fflags,build_dir,ext_name,dep_list)
    os.chdir('..')
    return 0

ext_dir  = 'src_f'
ext_name  = '_rrtmg'
build_ext(ext_dir,ext_name)

