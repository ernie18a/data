bool ResetLastError2()
{
  ResetLastError();

  return(true);
}

template <typename T>
T MyPrint_Error( const T Value, const string Str, const bool )
{
  if (_LastError)
    Print(Str + " = " + (string)Value + ", Error = " + (string)_LastError);

  return(Value);
}

#define _E(A) MyPrint_Error(A, __FUNCSIG__ ", Line = " + (string)__LINE__ + ": " + #A, ResetLastError2())
#define _E3(A, B) MyPrint_Error(A, __FUNCSIG__ ", Line = " + (string)__LINE__ + ": " + #A + " (" + (B) + ")", ResetLastError2())
#define _E2(A, B) _E3(A, #B + " = " + (string)(B))