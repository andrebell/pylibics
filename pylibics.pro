SWIG_DIR = src
SWIG_INCLUDE = src

include(swig_python.pri)

TEMPLATE = lib
CONFIG -= moc qt
CONFIG += dll console plugin no_plugin_name_prefix
VERSION = 1.5.2b1
TARGET = pylibics
OBJECTS_DIR = obj
INCLUDEPATH += src
INCLUDEPATH += libics-1.5.2
INCLUDEPATH += $$system(echo `python-config --includes | sed s/-I//g`/numpy)
QMAKE_LIBDIR += libics-1.5.2/.libs
DESTDIR = pylibics
LIBS += $$system(python-config --libs)
LIBS += -lics

SWIG_FILES = src/libics.i

# Delete compiled libics in DESTDIR
QMAKE_POST_LINK += rm -f $${DESTDIR}/libics*;
# We are on Linux, therefore remove Windows dlls
QMAKE_POST_LINK += rm -f $${DESTDIR}/*.dll $${DESTDIR}/*.pyd;
# Copy compiled lib files from libics to DESTDIR
#QMAKE_POST_LINK += cp libics-1.5.2/.libs/libics.so $${DESTDIR}/libics.so.0;
# Rename compiled pylibics and copy install __init__.py into DESTDIR
QMAKE_POST_LINK += mv -f $${DESTDIR}/pylibics.so $${DESTDIR}/_pylibics.so;
QMAKE_POST_LINK += mv -f $${SWIG_DIR}/pylibics.py $${DESTDIR}/__init__.py;
# Copy meta files
QMAKE_POST_LINK += cp -f AUTHORS LICENSE KNOWN_BUGS TODO $${DESTDIR};

# Input
#SOURCES += src/pylibics_wrap.cpp


