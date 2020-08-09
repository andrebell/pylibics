# -*- coding: utf-8 -*-

from setuptools import setup, find_packages
from setuptools.dist import Distribution


class Win32Dist(Distribution):
    def has_ext_modules(self):
        return True


setup(
    distclass = Win32Dist,
    name = 'pylibics',
    version = '1.5.2b1',
    packages = find_packages(),
    package_data = {
        'pylibics' : ['*.dll', '*.pyd', '*.so', 'README', 'AUTHORS', 'LICENSE',
                      'TODO', 'KNOWN_BUGS'],
        },
    zip_safe = False,
    author = 'Andre Alexander Bell',
    author_email = 'pylibics@andre-bell.de',
    description = 'Python wrapper for libics (Image Cytometry Standard).',
    license = 'BSD',
    keywords = ['libics', 'Image Cytometry Standard', 'ICS', 'IDS', 'image file format'],
    url = 'http://www.andre-bell.de/en/projects/pylibics',
    download_url = 'http://www.andre-bell.de/en/projects/pylibics/downloads',
    classifiers = [
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: BSD License',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: POSIX',
        'Programming Language :: C',
        'Programming Language :: Python',
        'Topic :: Multimedia :: Graphics',
        'Topic :: Scientific/Engineering :: Image Recognition',
        'Topic :: Software Development :: Libraries',
        ],
    long_description = '''
=============================
Installing and Using pylibics
=============================

.. contents:: **Table of Contents**

------------
Introduction
------------

The Image Cytometry Standard (ICS) is a file format for images, primarily in
microscopy imaging. The file format has been described by `Dean1990`_. ICS
files allow to store further information on the imaging system along with the
actual image (e.g aperture, light setting, microscope, and camera). Moreover,
the file format allows to store several integer format, floating point images as
well as complex valued images.

The library `libics`_ is a C library to read an write ICS image files. This
module wraps the functions provided by libics to Python. Actual image data are
returned as numpy arrays. Numpy array in turn can be written to ICS image files.

.. _Dean1990: Dean, P.; Mascio, L.; Ow, D.; Sudar, D. & Mullikin, J.
    'Proposed standard for image cytometry data files'
    Cytometry, Part A, 1990, 11, (5), 561-569
    doi: 10.1002/cyto.990110502
.. _libics: http://libics.sourceforge.net

Limitations and known bugs
--------------------------

 - Ics data written as version 2.0 is broken
 - Accessing ics history entries with the iterator interface
   seems not to work properly
 - Compression appears to be not working

-------------------------
Installation instructions
-------------------------

You can download the `source code package`_ to compile everything yourself or
you can use easy_install to install the precompiled package (py2.6, win32 and
linux, x86_64). To compile the package please follow the instructions provided
in the README file.

Windows
-------

Installing with easy_install is done by calling from the windows command
prompt (C:\>):

  C:\> easy_install pylibics

Linux
-----

Installing with easy_install is done by calling from the command prompt:

  > easy_install pylibics

.. _source code package: http://www.andre-bell.de/projects/pylibics/downloads

-----
Usage
-----

Please see the `project homepage`_ for usage examples. Also refer to the
examples provided in the source package.

.. _project homepage: http://www.andre-bell.de/projects/pylibics

---------------
Release Changes
---------------

1.5.2b1, Released 2010-11-23
 * Basic support for libics
''',
)
