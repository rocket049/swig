/* ------------------------------------------------------------
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%{
#if PY_VERSION_HEX >= 0x03020000
# define SWIGPY_UNICODE_ARG(obj) ((PyObject*) (obj))
#else
# define SWIGPY_UNICODE_ARG(obj) ((PyUnicodeObject*) (obj))
#endif
%}

%fragment("SWIG_AsWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(PyObject *obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  PyObject *tmp = 0;
  int isunicode = PyUnicode_Check(obj);
%#if PY_VERSION_HEX < 0x03000000 && !defined(SWIG_PYTHON_STRICT_UNICODE_WCHAR)
  if (!isunicode && PyString_Check(obj)) {
    tmp = PyUnicode_FromObject(obj);
    if (tmp) {
      isunicode = 1;
      obj = tmp;
    } else {
      PyErr_Clear();
      return SWIG_TypeError;
    }
  }
%#endif
  if (isunicode) {
%#if PY_VERSION_HEX >= 0x03030000
%# if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03070000
    Py_ssize_t len = PyUnicode_GetLength(obj);
%# else
    Py_ssize_t len = PyUnicode_AsWideChar(SWIGPY_UNICODE_ARG(obj), NULL, 0) - 1;
%# endif
%#else
    Py_ssize_t len = PyUnicode_GetSize(obj);
%#endif
    if (cptr) {
      Py_ssize_t length;
      *cptr = %new_array(len + 1, wchar_t);
      length = PyUnicode_AsWideChar(SWIGPY_UNICODE_ARG(obj), *cptr, len);
      if (length == -1) {
        PyErr_Clear();
        SWIG_Py_XDECREF(tmp);
        return SWIG_TypeError;
      }
      (*cptr)[length] = 0;
    }
    if (psize) *psize = (size_t) len + 1;
    if (alloc) *alloc = cptr ? SWIG_NEWOBJ : 0;
    SWIG_Py_XDECREF(tmp);
    return SWIG_OK;
  } else {
    swig_type_info* pwchar_descriptor = SWIG_pwchar_descriptor();
    if (pwchar_descriptor) {
      void * vptr = 0;
      if (SWIG_ConvertPtr(obj, &vptr, pwchar_descriptor, 0) == SWIG_OK) {
	if (cptr) *cptr = (wchar_t *)vptr;
	if (psize) *psize = vptr ? (wcslen((wchar_t *)vptr) + 1) : 0;
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor") {
SWIGINTERNINLINE PyObject *
SWIG_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  if (carray) {
    if (size > (size_t)PY_SSIZE_T_MAX) {
      swig_type_info* pwchar_descriptor = SWIG_pwchar_descriptor();
      return pwchar_descriptor ? 
	SWIG_InternalNewPointerObj(%const_cast(carray,wchar_t *), pwchar_descriptor, 0) : SWIG_Py_Void();
    } else {
      return PyUnicode_FromWideChar(carray, %numeric_cast(size, Py_ssize_t));
    }
  } else {
    return SWIG_Py_Void();
  }
}
}


