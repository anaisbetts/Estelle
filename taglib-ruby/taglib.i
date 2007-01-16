%module libtagruby 
%{
#include "taglib.h"
#include "tlist.h"
#include "tstring.h"
#include "tstringlist.h"
#include "audioproperties.h"
#include "tag.h"
#include "fileref.h"
using namespace TagLib;


SWIGINTERN int
SWIG_AsVal_long (VALUE obj, long* val); 

SWIGINTERN int
SWIG_AsCharArray(VALUE obj, char *val, size_t size);

SWIGINTERN int
SWIG_AsVal_wchar_t (VALUE obj, wchar_t *val)
{    
  int res = SWIG_AsCharArray(obj, (char*)val, 1);
  if (!SWIG_IsOK(res)) {
    long v;
    res = SWIG_AddCast(SWIG_AsVal_long (obj, &v));
    if (SWIG_IsOK(res)) {
      if ((CHAR_MIN <= v) && (v <= CHAR_MAX)) {
	if (val) *val = static_cast<wchar_t >(v);
      }
    }
  }
  return res;
}


%}
        
%rename(to_s) TagLib::String::toCString;
%ignore TagLib::FileRef::addFileTypeResolver;
%include "taglib.h"
%include "tlist.h"
%include "tstring.h"
%include "tstringlist.h"
%include "audioproperties.h"
%include "tag.h"
%include "fileref.h"

namespace TagLib
{
        %template(StringList) TagLib::List<String>;
}

