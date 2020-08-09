#global defaults
isEmpty(SWIG_INCLUDE):SWIG_INCLUDE = .
isEmpty(SWIG_DIR):SWIG_DIR = .
isEmpty(SWIG_CMD):SWIG_CMD = swig -python -c++ -I${SWIG_INCLUDE}

#dependency to generate *_wrap.cxx from *.i
swig_cxx.name = SWIG_CXX ${QMAKE_FILE_IN}
swig_cxx.commands = $$SWIG_CMD -o $$SWIG_DIR/py${QMAKE_FILE_BASE}_wrap.cxx ${QMAKE_FILE_NAME}
swig_cxx.CONFIG += no_link
swig_cxx.variable_out = SOURCES
swig_cxx.output = $$SWIG_DIR/py${QMAKE_FILE_BASE}_wrap.cxx
swig_cxx.target = $$SWIG_DIR/py${QMAKE_FILE_BASE}_wrap.cxx
swig_cxx.input = SWIG_FILES
swig_cxx.clean = $$SWIG_DIR/py${QMAKE_FILE_BASE}_wrap.cxx
QMAKE_EXTRA_COMPILERS += swig_cxx

#dependency to generate *.py from *.i
swig_py.name = SWIG_PY ${QMAKE_FILE_IN}
swig_py.commands = $$SWIG_CMD -o $$SWIG_DIR/py${QMAKE_FILE_BASE}_wrap.cxx ${QMAKE_FILE_NAME}
swig_py.CONFIG += no_link
swig_py.output = $$SWIG_DIR/${QMAKE_FILE_BASE}.py
swig_py.input = SWIG_FILES
swig_py.clean = $$SWIG_DIR/${QMAKE_FILE_BASE}.py
QMAKE_EXTRA_COMPILERS += swig_py

