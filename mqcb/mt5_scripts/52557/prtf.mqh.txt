//+------------------------------------------------------------------+
//|                                                         PRTF.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

#include <MQL5Book/MqlError.mqh>

#define PRTF(A) ResultPrint(#A, (A))
#define PRTE(V,A) ErrorPrint((string)V + #A, (A))

//+------------------------------------------------------------------+
//| Helper printer returning result and checking errors              |
//+------------------------------------------------------------------+
template<typename T>
T ResultPrint(const string s, const T retval = NULL)
{
   const int snapshot = _LastError; // required because _LastError is volatile
   const string err = E2S(snapshot) + "(" + (string)snapshot + ")";
   Print(s, "=", retval, " / ", (snapshot == 0 ? "ok" : err));
   ResetLastError(); // cleanup for next execution
   return retval;
}

//+------------------------------------------------------------------+
//| Helper error printer, valid results to be returned silently      |
//+------------------------------------------------------------------+
template<typename T>
T ErrorPrint(const string s, const T retval = NULL)
{
   if(_LastError)
   {
      return ResultPrint(s, retval);
   }
   return retval;
}
//+------------------------------------------------------------------+
