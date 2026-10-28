#include "PriceChange.mqh"

class PRICECHANGES
{
private:
  PRICECHANGE Changes[];
  int Current;
  double MaxValue;

  int Sort( const bool SortByMinMax = false )
  {
  #define VALUE 0
  #define INDEX 1
    this.MaxValue = -DBL_MAX;
    this.Current = -1;

    double Index[][2];

    const int Size = ::ArrayResize(Index, ::ArraySize(this.Changes));

    for (uint i = Size; (bool)i--;)
    {
      const double Value = ::MathAbs(SortByMinMax ? this.Changes[i].MinMax : this.Changes[i].Value);

      Index[i][VALUE] = Value;
      Index[i][INDEX] = i;

      if (Value > this.MaxValue)
        this.MaxValue = Value;
    }

    ::ArraySort(Index);

    PRICECHANGE Changes2[];

    for (uint i = ::ArrayResize(Changes2, Size); (bool)i--;)
    {
      Changes2[i] = this.Changes[(int)Index[i][INDEX]];

      if ((this.Current == -1) && (Changes2[i].Name == _Symbol))
        this.Current = (int)i;
    }

    ::ArraySwap(this.Changes, Changes2);

    if (SortByMinMax)
      this.MaxValue = -this.MaxValue;

  #undef INDEX
  #undef VALUE

    return(Size);
  }

  int GetCorrectIndex( const int Index ) const
  {
    const int Size = ::ArraySize(this.Changes);

    return(((Index % Size) + Size) % Size);
  }

  string ToString( const int Index ) const
  {
    const int Size = ::ArraySize(this.Changes);

    return("\n" + ::IntegerToString(Size - Index, 2, '0') + ": " + this.Changes[Index].ToString(this.MaxValue));
  }

  static string StringBetween( string &Str, const string StrBegin, const string StrEnd = NULL )
  {
    string Res = NULL;
    int PosBegin = ::StringFind(Str, StrBegin);

    if ((PosBegin >= 0) || (StrBegin == NULL))
    {
      PosBegin = (PosBegin >= 0) ? PosBegin + ::StringLen(StrBegin) : 0;

      const int PosEnd = ::StringFind(Str, StrEnd, PosBegin);

      if (PosEnd != PosBegin)
        Res = ::StringSubstr(Str, PosBegin, (PosEnd >= 0) ? PosEnd - PosBegin : -1);

      Str = (PosEnd >= 0) ? ::StringSubstr(Str, PosEnd + ::StringLen(StrEnd)) : NULL;

      if (Str == "")
        Str = NULL;
    }

    return((Res == "") ? NULL : Res);
  }

  static bool IsIntersection( const string &Name1[], const string &Name2[])
  {
    bool Res = false;

    for (uint i = ::ArraySize(Name1); !Res && (bool)i--;)
      if (Name1[i] != NULL)
        for (uint j = ::ArraySize(Name2); !Res && (bool)j--;)
          Res = (Name1[i] == Name2[j]);

    return(Res);
  }

  static bool IsIntersection( const string &Symb1, const string &Symb2 )
  {
    string Str1 = ::SymbolInfoString(Symb1, SYMBOL_DESCRIPTION);
    const string Name1[] = {PRICECHANGES::StringBetween(Str1, NULL, " vs "), Str1,
                            ::SymbolInfoString(Symb1, SYMBOL_CURRENCY_PROFIT)};

    string Str2 = ::SymbolInfoString(Symb2, SYMBOL_DESCRIPTION);
    const string Name2[] = {PRICECHANGES::StringBetween(Str2, NULL, " vs "), Str2,
                            ::SymbolInfoString(Symb2, SYMBOL_CURRENCY_PROFIT)};

    return(PRICECHANGES::IsIntersection(Name1, Name2));
  }

public:
  int Calc( const datetime Time1, const datetime Time2, const bool SortByMinMax = false, const string SymbBase = NULL )
  {
    int Amount = 0;


    for (uint i = ::ArrayResize(this.Changes, ::SymbolsTotal(true)); (bool)i--;)
    {
      const string Symb = ::SymbolName(i, true);

      if (!::SymbolInfoInteger(Symb, SYMBOL_CUSTOM) &&
          ::SymbolInfoInteger(Symb, SYMBOL_VISIBLE) &&
          ((SymbBase == NULL) || PRICECHANGES::IsIntersection(Symb, SymbBase)))
        this.Changes[Amount++].Calc(Symb, Time1, Time2);
    }

    ::ArrayResize(this.Changes, Amount);

    return(this.Sort(SortByMinMax));
  }

  string ToString( void ) const
  {
    string Str = (this.Current != -1) ? this.ToString(this.Current) + "\n" : NULL;

    for (uint i = ::ArraySize(this.Changes); (bool)i--;)
      Str += this.ToString(i);

    return(Str);
  }

  string GetNextSymbol( void ) const
  {
    return(this.Changes[this.GetCorrectIndex(this.Current - 1)].Name);
  }

  string GetPrevSymbol( void ) const
  {
    return(this.Changes[this.GetCorrectIndex(this.Current + 1)].Name);
  }

  string GetFirstSymbol( void ) const
  {
    return(this.Changes[::ArraySize(this.Changes) - 1].Name);
  }

  bool IsCalc( void ) const
  {
    return((bool)::ArraySize(this.Changes));
  }
};