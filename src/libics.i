%define PYLIBICS_DOCSTRING
"Python wrapper for libics, which is a library to access files in the Image
Cytometry Standard (ICS) format.

The Image Cytometry Standard (ICS) is a file format for images, primarily in
microscopy imaging. The file format has been described by Dean [1]. ICS files
allow to store further information on the imaging system along with the actual
image (e.g aperture, light setting, microscope, and camera). Moreover, the file
format allows to store several integer format, floating point images as well as
complex valued images.

The library libics [2] is a C library to read an write ICS image files. This
module wraps the functions provided by libics to Python. Actual image data are
returned as numpy arrays. Numpy array in turn can be written to ICS image files.

Example 1: (Reading image files)

    >>> import pylibics
    >>> ics = pylibics.IcsOpen('libics-1.5.2/test/testim', 'r')
    >>> im = pylibics.IcsGetData(ics)
    >>> im.shape
    (2, 105, 175)
    >>> shape = pylibics.IcsGetLayout(ics)
    >>> shape
    (2, 105, 175)
    >>> csystem = pylibics.IcsGetCoordinateSystem(ics)
    >>> csystem
    'video'

Example 2: (Writing image files)

    >>> import pylibics
    >>> import scipy
    >>> im = scipy.lena.astype('uint8').copy()

    Note: Use 'w1' mode for writing version 1.0 files.
          Modes 'w' and 'w2' for version 2.0 files currently seem broken.

    >>> ics = IcsOpen('lenatest', 'w1')

    Note: In Python you do not need to specify the Layout. This is automatically
          done by IcsSetData from the underlying layout of the numpy array.

    >>> pylibics.IcsSetData(ics, lena)
    0

    Note: Closing the file handle actually writes the data.

    >>> pylibics.IcsClose(ics)
    0

[1] Dean, P.; Mascio, L.; Ow, D.; Sudar, D. & Mullikin, J.
    'Proposed standard for image cytometry data files'
    Cytometry, Part A, 1990, 11, (5), 561-569
    doi: 10.1002/cyto.990110502

[2] http://libics.sourceforge.net
"
%enddef

%module(docstring=PYLIBICS_DOCSTRING) pylibics
%{
#include <iostream>
#include <map>

#include <numpy/arrayobject.h>

#include <libics.h>
#include <libics_sensor.h>
#include <libics_test.h>

std::map<int, int> __ICS2NPY;
%}

%pythoncode {
VERSION = __import__('pkg_resources').get_distribution('pylibics').version
}

%{
#define SWIG_FILE_WITH_INIT
%}

%include "numpy.i"
%include "typemaps.i"

%typemap(in,numinputs=0) char *OUTSTR (char temp[ICS_LINE_LENGTH+1]) {
    $1 = temp;
}

%typemap(argout) char *OUTSTR {
    $1[ICS_LINE_LENGTH] = 0;
    %append_output(SWIG_FromCharPtr($1));
}

%typemap(in,numinputs=0) Ics_HistoryIterator *OUTIT (Ics_HistoryIterator temp) {
    $1 = &temp;
}

%typemap(argout) Ics_HistoryIterator *OUTIT {
    %append_output(SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_Ics_HistoryIterator, 0 |  0 ));
}

%init
%{
import_array();

__ICS2NPY[Ics_uint8] = PyArray_UINT8;
__ICS2NPY[Ics_sint8] = PyArray_INT8;
__ICS2NPY[Ics_uint16] = PyArray_UINT16;
__ICS2NPY[Ics_sint16] = PyArray_INT16;
__ICS2NPY[Ics_uint32] = PyArray_UINT32;
__ICS2NPY[Ics_sint32] = PyArray_INT32;
__ICS2NPY[Ics_real32] = PyArray_FLOAT32;
__ICS2NPY[Ics_real64] = PyArray_FLOAT64;
//    Ics_complex32: There is no numpy complex32 data type!
__ICS2NPY[Ics_complex64] = PyArray_COMPLEX64;
%}

/* For the moment the largest imel is a double complex of 16 bytes: */
#define ICS_MAX_IMEL_SIZE 16

/* These determine the sizes of static arrays and strings: */
#define ICS_MAXDIM 10        /* number of allowed dimensions in the image */
#define ICS_MAX_LAMBDA 16    /* number of allowed sensor channels */
#define ICS_STRLEN_TOKEN 20  /* length of a token string */
#define ICS_STRLEN_OTHER 128 /* length of other strings */
#define ICS_LINE_LENGTH 256  /* the maximum length of each of the lines in the .ics file. */
#define ICS_MAXPATHLEN 512   /* the maximum length of the file names */

/*
 * These are the known data types for imels. If you use another type,
 * you can't use the top-level functions:
 */
typedef enum {
    Ics_unknown = 0,
    Ics_uint8,          /* integer, unsigned,  8 bpp */
    Ics_sint8,          /* integer, signed,    8 bpp */
    Ics_uint16,         /* integer, unsigned, 16 bpp */
    Ics_sint16,         /* integer, signed,   16 bpp */
    Ics_uint32,         /* integer, unsigned, 32 bpp */
    Ics_sint32,         /* integer, signed,   32 bpp */
    Ics_real32,         /* real,    signed,   32 bpp */
    Ics_real64,         /* real,    signed,   64 bpp */
    Ics_complex32,      /* complex, signed, 2*32 bpp */
    Ics_complex64       /* complex, signed, 2*64 bpp */
} Ics_DataType;

/*
 * These are the compression methods supported by this library:
 */
typedef enum {
    IcsCompr_uncompressed = 0, /* No compression */
    IcsCompr_compress,         /* Using 'compress' (but when writing converted to gzip) */
    IcsCompr_gzip              /* Using Zlib (ICS_ZLIB must be defined) */
} Ics_Compression;

/*
 * These are the file modes:
 */
typedef enum {
    IcsFileMode_write,   /* Write mode */
    IcsFileMode_read,    /* Read mode */
    IcsFileMode_update   /* Read-Write mode: change only meta-data, read any header item */
} Ics_FileMode;

/*
 * This is the data structure that holds all the information in
 *  the ICS file:
 */
typedef struct _ICS {
    int Version;                               /* ICS version: 1 for v.1.0, 2 for v.2.0 */
    Ics_FileMode FileMode;                     /* How the ICS file was opened. Used by top-level only */
    void const* Data;                          /* Pointer to the data to write */
    size_t DataLength;                         /* Size of the data buffer */
    size_t const* DataStrides;                 /* Distance in pixels to the neighbors (writing only) */
    char Filename[ICS_MAXPATHLEN];             /* '.ics' filename (including path) */
    int Dimensions;                            /* Number of elements in Dim */
    Ics_DataRepresentation Dim[ICS_MAXDIM];    /* Image representaion */
    Ics_ImelRepresentation Imel;               /* Imel representation */
    char Coord[ICS_STRLEN_TOKEN];              /* Coordinate system used */
    Ics_Compression Compression;               /* Compression technique used */
    int CompLevel;                             /* Parameter for the compression */
    int ByteOrder[ICS_MAX_IMEL_SIZE];          /* Byte storage order */
    void* History;                             /* History strings */

    /* To read the data in blocks we need this: */
    void* BlockRead;                           /* Contains the status of the data file */

    /* New ICS v. 2.0 parameters: */
    char SrcFile[ICS_MAXPATHLEN];              /* Source file name */
    size_t SrcOffset;                          /* Offset into source file */

    /* Special microscopic parameters: */
    int WriteSensor;                           /* Set to 1 if the next params are needed */
    char Type[ICS_STRLEN_TOKEN];               /* sensor type */
    char Model[ICS_STRLEN_OTHER];              /* model or make */
    int SensorChannels;                        /* Number of channels */
    double PinholeRadius[ICS_MAX_LAMBDA];      /* Backprojected microns */
    double LambdaEx[ICS_MAX_LAMBDA];           /* Excitation wavelength in nanometers */
    double LambdaEm[ICS_MAX_LAMBDA];           /* Emission wavelength in nm */
    int ExPhotonCnt[ICS_MAX_LAMBDA];           /* # of excitation photons */
    double RefrInxMedium;                      /* Refractive index of embedding medium */
    double NumAperture;                        /* Numerical Aperture */
    double RefrInxLensMedium;                  /* Refractive index of design medium */
    double PinholeSpacing;                     /* Nipkow Disk pinhole spacing */

    /* SCIL_Image compatibility parameter */
    char ScilType[ICS_STRLEN_TOKEN];           /* SCIL_TYPE string */
} ICS;

/* These are the error codes: */
typedef enum {
    IcsErr_Ok = 0,
    IcsErr_FSizeConflict,       /* Non fatal error: unexpected data size */
    IcsErr_OutputNotFilled,     /* Non fatal error: the output buffer could not be completely filled (meaning that your buffer was too large) */
    IcsErr_Alloc,               /* Memory allocation error */
    IcsErr_BitsVsSizeConfl,     /* Image size conflicts with bits per element */
    IcsErr_BlockNotAllowed,     /* It is not possible to read COMPRESS-compressed data in blocks */
    IcsErr_BufferTooSmall,      /* The buffer was too small to hold the given ROI */
    IcsErr_CompressionProblem,  /* Some error occurred during compression */
    IcsErr_CorruptedStream,     /* The compressed input stream is currupted */
    IcsErr_DecompressionProblem,/* Some error occurred during decompression */
    IcsErr_DuplicateData,       /* The ICS data structure already contains incompatible stuff */
    IcsErr_EmptyField,          /* Empty field (intern error) */
    IcsErr_EndOfHistory,        /* All history lines have already been returned */
    IcsErr_EndOfStream,         /* Unexpected end of stream */
    IcsErr_FCloseIcs,           /* File close error on .ics file */
    IcsErr_FCloseIds,           /* File close error on .ids file */
    IcsErr_FCopyIds,            /* Failed to copy image data from temporary file on .ics file opened for updating */
    IcsErr_FOpenIcs,            /* File open error on .ics file */
    IcsErr_FOpenIds,            /* File open error on .ids file */
    IcsErr_FReadIcs,            /* File read error on .ics file */
    IcsErr_FReadIds,            /* File read error on .ids file */
    IcsErr_FTempMoveIcs,        /* Failed to remane .ics file opened for updating */
    IcsErr_FWriteIcs,           /* File write error on .ics file */
    IcsErr_FWriteIds,           /* File write error on .ids file */
    IcsErr_FailWriteLine,       /* Failed to write a line in .ics file */
    IcsErr_IllIcsToken,         /* Illegal ICS token detected */
    IcsErr_IllParameter,        /* A function parameter has a value that is not legal or does not match with a value previously given */
    IcsErr_IllegalROI,          /* The given ROI extends outside the image */
    IcsErr_LineOverflow,        /* Line overflow in ics file */
    IcsErr_MissBits,            /* Missing "bits" element in .ics file */
    IcsErr_MissCat,             /* Missing main category */
    IcsErr_MissLayoutSubCat,    /* Missing layout subcategory */
    IcsErr_MissParamSubCat,     /* Missing parameter subcategory */
    IcsErr_MissRepresSubCat,    /* Missing representation subcategory */
    IcsErr_MissSensorSubCat,    /* Missing sensor subcategory */
    IcsErr_MissSensorSubSubCat, /* Missing sensor subsubcategory */
    IcsErr_MissSubCat,          /* Missing sub category */
    IcsErr_MissingData,         /* There is no Data defined */
    IcsErr_NoLayout,            /* Layout parameters missing or not defined */
    IcsErr_NoScilType,          /* There doesn't exist a SCIL_TYPE value for this image */
    IcsErr_NotIcsFile,          /* Not an ICS file */
    IcsErr_NotValidAction,      /* The function won't work on the ICS given */
    IcsErr_TooManyChans,        /* Too many channels specified */
    IcsErr_TooManyDims,         /* Data has too many dimensions */
    IcsErr_UnknownCompression,  /* Unknown compression type */
    IcsErr_UnknownDataType,     /* The datatype is not recognized */
    IcsErr_WrongZlibVersion     /* libics is linking to a different version of zlib than used during compilation */
} Ics_Error;

/* Used by IcsGetHistoryString */
typedef enum {
    IcsWhich_First,             /* Get the first string */
    IcsWhich_Next               /* Get the next string */
} Ics_HistoryWhich;

typedef struct {
    int next;                     /* index into history array, pointing to next string to read,
                                     set to -1 if there's no more to read. */
    int previous;                 /* index to previous string, useful for relace and delete. */
    char key[ICS_STRLEN_TOKEN+1]; /* optional key this iterator looks for. */
} Ics_HistoryIterator;

%pythoncode {
class IcsException(Exception):
    pass


def raise_on_error(val):
    '''raise_on_error(IcsErrorCode)

    Raises an Exception for the given ICS error code.
    '''
    if isinstance(val, (list, tuple)):
        error = val[0]
        if len(val) == 1:
            result = None
        elif len(val) == 2:
            result = val[1]
        else:
            result = val[1:]
    else:
        error = val
        result = None
    if not error == IcsErr_Ok:
        msg = IcsGetErrorText(IcsErrorCode)
        raise IcsException(msg)
    return result
}

////////////////////////////////////////////////////////////////////////////////
// IcsGetLibVersion
%define IcsGetLibVersion_DOCSTRING
"IcsGetLibVersion() -> version_string

Returns a string that can be used to compare with ICSLIB_VERSION to check if the
version of the library is the same as that of the headers."
%enddef

%feature("autodoc", IcsGetLibVersion_DOCSTRING);
char const *IcsGetLibVersion (void);

////////////////////////////////////////////////////////////////////////////////
// IcsVersion

%define IcsVersion_DOCSTRING
"IcsVersion(filename, forcename) -> version_number

Returns 0 if it is not an ICS file, or the version number if it is. If forcename
is non-zero, no extension is appended."
%enddef

%feature("autodoc", IcsVersion_DOCSTRING);
int IcsVersion (char const *filename, int forcename);

////////////////////////////////////////////////////////////////////////////////
// IcsLoadPreview

%define IcsLoadPreview_DOCSTRING
"IcsLoadPreview(filename, planenumber) -> numpy.ndarray

Read a preview (2D) image out of an ICS file. The data type is always uint8."
%enddef

%{
PyObject *IcsLoadPreview_wrap (char const *filename, size_t planenumber)
{
    void *dest;
    size_t xsize;
    size_t ysize;
    Ics_Error error = IcsLoadPreview(filename, planenumber,
                                     &dest, &xsize, &ysize);
    npy_intp sizes[2];
    sizes[0] = ysize;
    sizes[1] = xsize;
    PyObject *array = PyArray_SimpleNewFromData(2, sizes, NPY_UBYTE, dest);
    PyArray_BASE(array) = PyCObject_FromVoidPtr(dest, free);
    PyObject *result = Py_BuildValue("(lN)", error, array);
    return result;
}
%}
%rename(IcsLoadPreview) IcsLoadPreview_wrap;

%pythonappend IcsLoadPreview_wrap(char const *filename, size_t planenumber) {
    return raise_on_error(val)
}

%feature("autodoc", IcsLoadPreview_DOCSTRING);
PyObject *IcsLoadPreview_wrap(char const *filename, size_t planenumber);

////////////////////////////////////////////////////////////////////////////////
// IcsOpen

%define IcsOpen_DOCSTRING
"IcsOpen(filename, mode) -> ICS

Open an ICS file for reading (mode = 'r') or writing (mode = 'w'). When writing,
append a '2' to the mode string to create an ICS version 2.0 file. Append an 'f'
to mode if, when reading, you want to force the file name to not change (no
'.ics' is appended). Append a 'l' to mode if, when reading, you don't want the
locale forced to 'C' (to read ICS files written with some other locale, set the
locale properly then open the file with 'rl')."
%enddef

%{
PyObject *IcsOpen_wrap(char const *filename, char const *mode)
{
    ICS *ics;
    Ics_Error error = IcsOpen(&ics, filename, mode);
    if (error == IcsErr_Ok)
    {
        PyObject *resultics = SWIG_NewPointerObj(SWIG_as_voidptr(ics), SWIGTYPE_p__ICS, 0 |  0 );
        PyObject *result = Py_BuildValue("(lN)", error, resultics);
        return result;
    }
    else
    {
        Py_INCREF(Py_None);
        PyObject *result = Py_BuildValue("(lN)", error, Py_None);
        return result;
    }
}
%}
%rename(IcsOpen) IcsOpen_wrap;

%pythonappend IcsOpen_wrap(char const *filename, char const *mode) {
    return raise_on_error(val)
}

%feature("autodoc", IcsOpen_DOCSTRING);
PyObject *IcsOpen_wrap(char const *filename, char const *mode);

////////////////////////////////////////////////////////////////////////////////
// IcsClose

%define IcsClose_DOCSTRING
"IcsClose(ics)

Close the ICS file. The ics 'stream' is no longer valid after this. No files are
actually written until this function is called."
%enddef

%pythonappend IcsClose(ICS *ics) {
    return raise_on_error(val)
}

%feature("autodoc", IcsClose_DOCSTRING);
Ics_Error IcsClose(ICS *ics);

////////////////////////////////////////////////////////////////////////////////
// IcsGetLayout

%define IcsGetLayout_DOCSTRING
"IcsGetLayout(ics) -> shape_tuple

Retrieve the layout of an ICS image. Only valid if reading."
%enddef

%{
PyObject *IcsGetLayout_wrap (ICS *ics)
{
    Ics_DataType dt;
    int ndims;
    size_t dims[ICS_MAXDIM];
    Ics_Error error = IcsGetLayout(ics, &dt, &ndims, dims);
    PyObject *dims_tuple = PyTuple_New(ndims);
    for (int i=0; i<ndims; ++i)
    {
        // Reverse order for numpy
        PyTuple_SetItem(dims_tuple, i, PyInt_FromLong(dims[ndims-1-i]));
    }
    return Py_BuildValue("(lN)", error, dims_tuple);
}
%}
%rename(IcsGetLayout) IcsGetLayout_wrap;

%pythonappend IcsGetLayout_wrap(ICS *ics) {
    return raise_on_error(val)
}

%feature("autodoc", IcsGetLayout_DOCSTRING);
PyObject *IcsGetLayout_wrap (ICS *ics);

////////////////////////////////////////////////////////////////////////////////
// IcsSetLayout

/* This function is not available, since it is called implicitely when setting
 * the data with IcsSetData!
 */
/* Ics_Error IcsSetLayout (ICS *ics, Ics_DataType dt, int ndims, size_t const *dims); */
/* Set the layout for an ICS image. Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetDataSize

%define IcsGetDataSize_DOCSTRING
"IcsGetDataSize(ics) -> integer

These three functions retrieve info from the ICS file.

 - IcsGetDataSize(ics)
 - IcsGetImelSize(ics)
 - IcsGetImageSize(ics)

Condition, IcsGetDataSize(ics) == IcsGetImelSize(ics) * IcsGetImageSize(ics)"
%enddef

%feature("autodoc", IcsGetDataSize_DOCSTRING);
size_t IcsGetDataSize(ICS *ics);

////////////////////////////////////////////////////////////////////////////////
// IcsGetImelSize

%define IcsGetImelSize_DOCSTRING
"IcsGetImelSize(ics) -> integer

These three functions retrieve info from the ICS file.

 - IcsGetDataSize(ics)
 - IcsGetImelSize(ics)
 - IcsGetImageSize(ics)

Condition, IcsGetDataSize(ics) == IcsGetImelSize(ics) * IcsGetImageSize(ics)"
%enddef

%feature("autodoc", IcsGetImelSize_DOCSTRING);
size_t IcsGetImelSize(ICS *ics);

////////////////////////////////////////////////////////////////////////////////
// IcsGetImageSize

%define IcsGetImageSize_DOCSTRING
"IcsGetImageSize(ics) -> integer

These three functions retrieve info from the ICS file.

 - IcsGetDataSize(ics)
 - IcsGetImelSize(ics)
 - IcsGetImageSize(ics)

Condition, IcsGetDataSize(ics) == IcsGetImelSize(ics) * IcsGetImageSize(ics)"
%enddef

%feature("autodoc", IcsGetImageSize_DOCSTRING);
size_t IcsGetImageSize(ICS *ics);

////////////////////////////////////////////////////////////////////////////////
// IcsGetData

%define IcsGetData_DOCSTRING
"IcsGetData(ics) -> numpy.ndarray

Read the image data from an ICS file. Only valid if reading."
%enddef

%{
PyObject *IcsGetData_wrap (ICS *ics)
{
    Ics_DataType dt;
    int ndims;
    size_t dims[ICS_MAXDIM];
    size_t bufsize;
    void *buf;
    Ics_Error error;

    IcsGetLayout(ics, &dt, &ndims, dims);
    bufsize = IcsGetDataSize(ics);
    buf = malloc(bufsize);
    error = IcsGetData(ics, buf, bufsize);

    npy_intp sizes[ICS_MAXDIM];
    // Reverse order for and change type from size_t to npy_intp for numpy
    for (int i=0; i<ndims; ++i)
    {
        sizes[i] = dims[ndims-1-i];
    }
    if (__ICS2NPY.find(dt) == __ICS2NPY.end())
    {
        error = IcsErr_UnknownDataType;
        PyObject *array = PyArray_SimpleNew(ndims, sizes, NPY_UBYTE);
        PyObject *result = Py_BuildValue("(lN)", error, array);

        return result;
    }
    else
    {
        PyObject *array = PyArray_SimpleNewFromData(ndims, sizes, __ICS2NPY[dt], buf);
        PyArray_BASE(array) = PyCObject_FromVoidPtr(buf, free);
        PyObject *result = Py_BuildValue("(lN)", error, array);

        return result;
    }
}
%}
%rename(IcsGetData) IcsGetData_wrap;

%pythonappend IcsGetData_wrap(ICS *ics) {
    return raise_on_error(val)
}

%feature("autodoc", IcsGetData_DOCSTRING);
PyObject *IcsGetData_wrap (ICS *ics);
/*  */

////////////////////////////////////////////////////////////////////////////////
// IcsGetROIData
// TODO: Implement wrapper for IcsGetROIData

/*
Ics_Error IcsGetROIData (ICS *ics, size_t const *offset,
                                   size_t const *size, size_t const *sampling,
                                   void *dest, size_t n);
*/
/* Read a square region of the image from an ICS file. To use the defaults
 * in one of the parameters, set the pointer to NULL. Only valid if reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetDataWithStrides
// TODO: Implement wrapper for IcsGetDataWithStrides

/*
Ics_Error IcsGetDataWithStrides (ICS *ics, void *dest, size_t n,
                                           size_t const *stride, int ndims);
*/
/* Read the image from an ICS file into a sub-block of a memory block. To
 * use the defaults in one of the parameters, set the pointer to NULL. Only
 * valid if reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetDataBlock
// TODO: Implement wrapper for IcsGetDataBlock

/*
Ics_Error IcsGetDataBlock (ICS *ics, void *dest, size_t n);
*/
/* Read a portion of the image data from an ICS file. Only valid if
 * reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsSkipDataBlock

%define IcsSkipDataBlock_DOCSTRING
"IcsSkipDataBlock(ics, n)

Skip a portion of the image from an ICS file. Only valid if reading."
%enddef

%pythonappend IcsSkipDataBlock(ICS *ics, size_t n) {
    return raise_on_error(val)
}

%feature("autodoc", IcsSkipDataBlock_DOCSTRING);
Ics_Error IcsSkipDataBlock (ICS *ics, size_t n);

////////////////////////////////////////////////////////////////////////////////
// IcsGetPreviewData

%define IcsGetPreviewData_DOCSTRING
"IcsGetPreviewData(ics, planenumber) -> numpy.ndarray

Read a plane of the image data from an ICS file, and convert it to uint8. Only
valid if reading."
%enddef

%{
PyObject *IcsGetPreviewData_wrap (ICS *ics, size_t planenumber)
{
    Ics_DataType dt;
    int ndims;
    size_t dims[ICS_MAXDIM];
    size_t bufsize;
    void *buf;
    Ics_Error error;

    IcsGetLayout(ics, &dt, &ndims, dims);
    bufsize = dims[0]*dims[1];
    buf = malloc(bufsize);
    error = IcsGetPreviewData(ics, buf, bufsize, planenumber);
    npy_intp sizes[2];
    sizes[0] = dims[1];
    sizes[1] = dims[0];
    PyObject *array = PyArray_SimpleNewFromData(2, sizes, NPY_UBYTE, buf);
    PyArray_BASE(array) = PyCObject_FromVoidPtr(buf, free);
    PyObject *result = Py_BuildValue("(lN)", error, array);
    return result;
}
%}
%rename(IcsGetPreviewData) IcsGetPreviewData_wrap;

%pythonappend IcsGetPreviewData_wrap(ICS *ics, size_t planenumber) {
    return raise_on_error(val)
}

%feature("autodoc", IcsGetPreviewData_DOCSTRING);
PyObject *IcsGetPreviewData_wrap(ICS *ics, size_t planenumber);

////////////////////////////////////////////////////////////////////////////////
// IcsSetData
// TODO: Implement a type check for the passed in numpy.ndarray object

%define IcsSetData_DOCSTRING
"IcsSetData(ics, array)

Set the image data for an ICS image. The pointer to this data must be accessible
until IcsClose has been called. Only valid if writing."
%enddef

%{
Ics_Error IcsSetData_wrap (ICS *ics, PyObject *array)
{
    // Set layout
    Ics_DataType dt = Ics_uint8;
    int ndims = PyArray_NDIM(array);
    size_t dims[ICS_MAXDIM];
    Ics_Error error;
    for (int i=0; i<ndims; ++i)
    {
        dims[ndims-1-i] = PyArray_DIMS(array)[i];
    }
    error = IcsSetLayout(ics, dt, ndims, dims);
    if (error != IcsErr_Ok)
        return error;

    // Set data
    size_t nbytes = PyArray_NBYTES(array);
    void *data = PyArray_DATA(array);
    error = IcsSetData(ics, data, nbytes);
    return error;
}
%}
%rename(IcsSetData) IcsSetData_wrap;

%pythonappend IcsSetData_wrap(ICS *ics, PyObject *array) {
    return raise_on_error(val)
}

%feature("autodoc", IcsSetData_DOCSTRING);
Ics_Error IcsSetData_wrap (ICS *ics, PyObject *numpy_ndarray);

////////////////////////////////////////////////////////////////////////////////
// IcsSetDataWithStrides
// TODO: Implement wrapper for IcsSetDataWithStrides

/*
Ics_Error IcsSetDataWithStrides (ICS *ics, void const *src, size_t n,
                                           size_t const *strides, int ndims);
*/
/* Set the image data for an ICS image. The pointer to this data must
 * be accessible until IcsClose has been called. Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSource
// TODO: Implement wrapper for IcsSetSource

/*
Ics_Error IcsSetSource (ICS *ics, char const *fname, size_t offset);
*/
/* Set the image source parameter for an ICS version 2.0 file. Only
 * valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetCompression

%define IcsSetCompression_DOCSTRING
"IcsSetCompression(ics, compression, level)

Set the compression method and compression parameter. Only valid if writing."
%enddef

%pythonappend IcsSetCompression(ICS *ics, Ics_Compression compression, int level) {
    return raise_on_error(val)
}

%feature("autodoc", IcsSetCompression_DOCSTRING);
Ics_Error IcsSetCompression (ICS *ics, Ics_Compression compression, int level);

////////////////////////////////////////////////////////////////////////////////
// IcsGetPosition
// TODO: Continue docstring from here

%apply double *OUTPUT {double *origin};
%apply double *OUTPUT {double *scale};
%apply char *OUTSTR {char *units};

%pythonappend IcsGetPosition (ICS const *ics, int dimension, double *origin,
                              double *scale, char *units) {
    return raise_on_error(val)
}

Ics_Error IcsGetPosition (ICS const *ics, int dimension, double *origin,
                          double *scale, char *units);

%clear double *origin;
%clear double *scale;
%clear char *units;
/* Get the position of the image in the real world: the origin of the first
 * pixel, the distances between pixels and the units in which to measure.
 * If you are not interested in one of the parameters, set the pointer to NULL.
 * Dimensions start at 0. Only valid if reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetPosition

%pythonappend IcsSetPosition (ICS const *ics, int dimension, double origin,
                              double scale, char const *units) {
    return raise_on_error(val)
}

Ics_Error IcsSetPosition (ICS *ics, int dimension, double origin,
                                    double scale, char const *units);
/* Set the position of the image in the real world: the origin of the first
 * pixel, the distances between pixels and the units in which to measure.
 * If units is NULL or empty, it is set to the default value of "undefined".
 * Dimensions start at 0. Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetOrder

%apply char *OUTSTR {char *order};
%apply char *OUTSTR {char *label};

%pythonappend IcsGetOrder (ICS const *ics, int dimension, char *order, char *label) {
    return raise_on_error(val)
}

Ics_Error IcsGetOrder (ICS const *ics, int dimension, char *order, char *label);

%clear char *order;
%clear char *label;
/* Get the ordering of the dimensions in the image. The ordering is defined
 * by names and labels for each dimension. The defaults are x, y, z, t (time)
 * and p (probe). Dimensions start at 0. Only valid if reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetOrder

%pythonappend IcsSetOrder (ICS *ics, int dimension, char const *order, char const *label) {
    return raise_on_error(val)
}

Ics_Error IcsSetOrder (ICS *ics, int dimension, char const *order, char const *label);
/* Set the ordering of the dimensions in the image. The ordering is defined
 * by providing names and labels for each dimension. The defaults are
 * x, y, z, t (time) and p (probe). Dimensions start at 0. Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetCoordinateSystem

%apply char *OUTSTR {char *coord};

%pythonappend IcsGetCoordinateSystem (ICS const *ics, char *coord) {
    return raise_on_error(val)
}

Ics_Error IcsGetCoordinateSystem (ICS const *ics, char *coord);

%clear char *coord;
/* Get the coordinate system used in the positioning of the pixels.
 * Related to IcsGetPosition(). The default is "video". Only valid if
 * reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetCoordinateSystem

%pythonappend IcsSetCoordinateSystem (ICS *ics, char const *coord) {
    return raise_on_error(val)
}

Ics_Error IcsSetCoordinateSystem (ICS *ics, char const *coord);
/* Set the coordinate system used in the positioning of the pixels.
 * Related to IcsSetPosition(). The default is "video". Only valid if
 * writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSignificantBits

%apply unsigned int *OUTPUT {size_t *nbits};

%pythonappend IcsGetSignificantBits (ICS const *ics, size_t *nbits) {
    return raise_on_error(val)
}

Ics_Error IcsGetSignificantBits (ICS const *ics, size_t *nbits);

%clear size_t *nbits;
/* Get the number of significant bits. Only valid if reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSignificantBits

%pythonappend IcsSetSignificantBits (ICS *ics, size_t nbits) {
    return raise_on_error(val)
}

Ics_Error IcsSetSignificantBits (ICS *ics, size_t nbits);
/* Set the number of significant bits. Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetImelUnits

%apply double *OUTPUT {double *origin};
%apply double *OUTPUT {double *scale};
%apply char *OUTSTR {char *units};

%pythonappend IcsGetImelUnits (ICS const *ics, double *origin, double *scale, char *units) {
    return raise_on_error(val)
}

Ics_Error IcsGetImelUnits (ICS const *ics, double *origin, double *scale, char *units);

%clear double *origin;
%clear double *scale;
%clear char *units;
/* Set the position of the pixel values: the offset and scaling, and the
 * units in which to measure. If you are not interested in one of the
 * parameters, set the pointer to NULL. Only valid if reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetImelUnits

%pythonappend IcsSetImelUnits (ICS *ics, double origin, double scale, char const *units) {
    return raise_on_error(val)
}

Ics_Error IcsSetImelUnits (ICS *ics, double origin, double scale, char const *units);
/* Set the position of the pixel values: the offset and scaling, and the
 * units in which to measure. If units is NULL or empty, it is set to the
 * default value of "relative". Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetScilType

%apply char *OUTSTR {char *sciltype};

%pythonappend IcsGetScilType (ICS const *ics, char *sciltype) {
    return raise_on_error(val)
}

Ics_Error IcsGetScilType (ICS const *ics, char *sciltype);

%clear char *sciltype;
/* Get the string for the SCIL_TYPE parameter. This string is used only
 * by SCIL_Image. Only valid if reading. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetScilType

%pythonappend IcsSetScilType (ICS *ics, char const *sciltype) {
    return raise_on_error(val)
}

Ics_Error IcsSetScilType (ICS *ics, char const *sciltype);
/* Set the string for the SCIL_TYPE parameter. This string is used only
 * by SCIL_Image. It is required if you want to read the image using
 * SCIL_Image. Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGuessScilType

%pythonappend IcsGuessScilType (ICS *ics) {
    return raise_on_error(val)
}

Ics_Error IcsGuessScilType (ICS *ics);
/* As IcsSetScilType, but creates a string according to the DataType
 * in the ICS structure. It can create a string for g2d, g3d, f2d, f3d,
 * c2d and c3d. Only valid if writing. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetErrorText

char const *IcsGetErrorText (Ics_Error error);
/* Returns a textual representation of an error. */

////////////////////////////////////////////////////////////////////////////////
// IcsAddHistoryString

%pythonappend IcsAddHistoryString (ICS *ics, char const *key, char const *value) {
    return raise_on_error(val)
}

Ics_Error IcsAddHistoryString (ICS *ics, char const *key, char const *value);
/* Add history lines to the ICS file. key can be NULL */

////////////////////////////////////////////////////////////////////////////////
// IcsDeleteHistory

%pythonappend IcsDeleteHistory (ICS *ics, char const *key) {
    return raise_on_error(val)
}

Ics_Error IcsDeleteHistory (ICS *ics, char const *key);
/* Delete all history lines with key from ICS file. key can be NULL,
 * deletes all. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetNumHistoryStrings

%apply int *OUTPUT {int *num};

%pythonappend IcsGetNumHistoryStrings (ICS *ics, int *num) {
    return raise_on_error(val)
}

Ics_Error IcsGetNumHistoryStrings (ICS *ics, int *num);

%clear int *num;
/* Get the number of HISTORY lines from the ICS file. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetHistoryString

%apply char *OUTSTR {char *string};

%pythonappend IcsGetHistoryString (ICS *ics, char *string, Ics_HistoryWhich which) {
    return raise_on_error(val)
}

Ics_Error IcsGetHistoryString (ICS *ics, char *string, Ics_HistoryWhich which);

%clear char *string;
/* Get history line from the ICS file. string must have at least
 * ICS_LINE_LENGTH characters allocated. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetHistoryKeyValue

%apply char *OUTSTR {char *key};
%apply char *OUTSTR {char *value};

%pythonappend IcsGetHistoryKeyValue (ICS *ics, char *key, char *value, Ics_HistoryWhich which) {
    return raise_on_error(val)
}

Ics_Error IcsGetHistoryKeyValue (ICS *ics, char *key, char *value, Ics_HistoryWhich which);

%clear char *key;
%clear char *value;
/* Get history line from the ICS file as key/value pair. key must have
 * ICS_STRLEN_TOKEN characters allocated, and value ICS_LINE_LENGTH.
 * key can be null, token will be discarded. */

////////////////////////////////////////////////////////////////////////////////
// IcsNewHistoryIterator

%apply Ics_HistoryIterator *OUTIT {Ics_HistoryIterator *it};

%pythonappend IcsNewHistoryIterator (ICS *ics, Ics_HistoryIterator *it, char const *key) {
    return raise_on_error(val)
}

Ics_Error IcsNewHistoryIterator (ICS *ics, Ics_HistoryIterator *it, char const *key);

%clear Ics_HistoryIterator *it;
/* Initializes history iterator. key can be NULL. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetHistoryStringI

%apply char *OUTSTR {char *string};

%pythonappend IcsGetHistoryStringI (ICS *ics, Ics_HistoryIterator *it, char *string) {
    return raise_on_error(val)
}

Ics_Error IcsGetHistoryStringI (ICS *ics, Ics_HistoryIterator *it, char *string);

%clear char *string;
/* Get history line from the ICS file using iterator. string must have at
 * least ICS_LINE_LENGTH characters allocated. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetHistoryKeyValueI

%apply char *OUTSTR {char *key};
%apply char *OUTSTR {char *value};

%pythonappend IcsGetHistoryKeyValueI (ICS *ics, Ics_HistoryIterator *it, char *key, char *value) {
    return raise_on_error(val)
}

Ics_Error IcsGetHistoryKeyValueI (ICS *ics, Ics_HistoryIterator *it, char *key, char *value);

%clear char *key;
%clear char *value;
/* Get history line from the ICS file as key/value pair using iterator.
 * key must have ICS_STRLEN_TOKEN characters allocated, and value
 * ICS_LINE_LENGTH. key can be null, token will be discarded. */

////////////////////////////////////////////////////////////////////////////////
// IcsDeleteHistoryStringI

%pythonappend IcsDeleteHistoryStringI (ICS *ics, Ics_HistoryIterator *it) {
    return raise_on_error(val)
}

Ics_Error IcsDeleteHistoryStringI (ICS *ics, Ics_HistoryIterator *it);
/* Delete last retrieved history line (iterator still points to the same string). */

////////////////////////////////////////////////////////////////////////////////
// IcsReplaceHistoryStringI

%pythonappend IcsReplaceHistoryStringI (ICS *ics, Ics_HistoryIterator *it,
                                        char const *key, char const *value) {
    return raise_on_error(val)
}

Ics_Error IcsReplaceHistoryStringI (ICS *ics, Ics_HistoryIterator *it,
                                    char const *key, char const *value);
/* Delete last retrieved history line (iterator still points to the same string). */

%include "libics_sensor.i"
%include "libics_test.i"
