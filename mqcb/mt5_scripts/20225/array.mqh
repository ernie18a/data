class ARRAY
{
public:
  // Добавление элемента в конец произвольного массива
  template <typename T>
  static int AddElement( T &Array[], const T &Value, const int Reserve = 0 ) // https://www.mql5.com/ru/forum/1111/page2085#comment_6019715
  {
    const int Size = ::ArraySize(Array);
    const int Res = ::ArrayResize(Array, Size + 1, Reserve);

    Array[Size] = Value;

    return(Res);
  }

  template <typename T>
  static int GetIndex( const T &Array[], const T &Element )
  {
    const int Size = ::ArraySize(Array);

    for (int i = 0; i < Size; i++)
      if (Array[i] == Element)
        return(i);

    return(-1);
  }

#define EXCLUDE_GETINDEX(A) static int GetIndex( const A &[], const A& ) { return(-1); }
  EXCLUDE_GETINDEX(MqlBookInfo);
  EXCLUDE_GETINDEX(MqlDateTime);
  EXCLUDE_GETINDEX(MqlParam);
  EXCLUDE_GETINDEX(MqlRates);
  EXCLUDE_GETINDEX(MqlTick);

#ifdef __MQL5__
  EXCLUDE_GETINDEX(MqlTradeCheckResult);
  EXCLUDE_GETINDEX(MqlTradeRequest);
  EXCLUDE_GETINDEX(MqlTradeResult);
  EXCLUDE_GETINDEX(MqlTradeTransaction);
#endif // __MQL5__

#undef EXCLUDE_GETINDEX
};