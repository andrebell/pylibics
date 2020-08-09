# pylibics module

Python interface to libics (Image Cytometry Standard). The files in the
directories 'libics-1.5.2' are from libics
(see http://libics.sourceforge.net).

To compile this module you need to first compile libics. Therfore, go to the
subfolder libics-1.5.2 and follow the instructions in the README and INSTALL
files provided there.

After compiling libics you are ready to compile the python wrapper pylibics.
The instructions for Windows and Linux are given below.

## Linux

To compile the python wrapper pylibics you will need

 - QMake (The make tool provided with the Qt library)
 - SWIG

both of which you have to install first.
Moreover, pylibics depends on the python packages

 - numpy
 - setuptools

which you have to have installed too.

1) Compiling the python wrapper

Start the compilation by calling

 > qmake
 > make clean
 > make

2) Installing the python wrapper with distutils/setuptools

and then install the package in the development mode by calling

 > python setup.py develop

_or_ build an egg file with

 > python setup.py bdist_egg

which you then can install with the command

 > easy_install dist/<name of the genareted egg file>

## Windows

To compile pylibics under Windows you need

 - Visual Studio 2008
 - Python (e.g. PythonXY (http://www.pythonxy.com))
 - SWIG (included in PythonXY)
 - numpy (included in PythonXY)

1) Compiling the python wrapper

To compile this project you need to set up the following environment variables:

- PYTHON_INC <- must point to the folder with the python includes
- NUMPY_INC <- must point to the folder with the numpy python extension includes
- PYTHON_LIB <- must point to the folder with the python lib files
- SWIG <- Full specifier (incl. the path) to the swig.exe

Open the Visual Studio solution file in Visual Studio and compile the project.
After compilation the output is a pylibics module in the 'pylibics' folder.
You will most likely want install this module with distutils. (see 2)

2) Installing the python wrapper with distutils/setuptools

Open a command line window and go to the python folder of the libics module.
To install the python module in development mode run

 > python setup.py develop

and to compile a python egg, which can be copied to the python installations
lib\site-packages folder, run

 > python setup.py bdist_egg

The egg file will be in the python\dist subfolder.
You can install the egg with the command

 > easy_install dist\<name of the genareted egg file>

