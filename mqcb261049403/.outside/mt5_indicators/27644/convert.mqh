#include <TypeToBytes.mqh> // https://www.mql5.com/ru/code/16280

class CONVERT
{
private:
#define CONVERT_MACROS(A, B) A / B + !(A / B) // (A >= B) ? A / B : 1

  template <typename SOURCE, typename TARGET>
  union CONVERT_UNION
  {
    SOURCE Source;
//    TARGET Target[sizeof(SOURCE) / sizeof(TARGET)]; // '[' - invalid index value
    TARGET Target[CONVERT_MACROS(sizeof(SOURCE), sizeof(TARGET))];
  };

#undef CONVERT_MACROS

#define MACRO_STRUCT(T)        \
  struct CONVERT_STRUCT        \
  {                            \
    T Data[CONVERT_AMOUNT];    \
  };                           \
                               \
  CONVERT_UNION<CONVERT_STRUCT

#define CONVERT_AMOUNT 128

  template <typename SOURCE, typename TARGET>
  static int StructToArray( const SOURCE &Src_Array[], TARGET &Dst_Array[] )
  {
    CONVERT_UNION<SOURCE, TARGET> Union1;
    MACRO_STRUCT(SOURCE), TARGET> Union2;

    const int SizeSource = ::ArraySize(Src_Array);
    const int SizeTarget = ::ArrayResize(Dst_Array, SizeSource * sizeof(SOURCE) / sizeof(TARGET));

    const int EndPos = SizeSource - (SizeSource % sizeof(Union2));
    int i = 0;
    int j = 0;

    while (j < EndPos)
    {
      j += ::ArrayCopy(Union2.Source.Data, Src_Array, 0, j, sizeof(Union2) / sizeof(SOURCE));
      i += ::ArrayCopy(Dst_Array, Union2.Target, i);
    }

    while (i < SizeTarget)
    {
      Union1.Source = Src_Array[j++];

      i += ::ArrayCopy(Dst_Array, Union1.Target, i);
      //for (int k = 0; k < sizeof(SOURCE) / sizeof(TARGET); k++)
      //  Dst_Array[i++] = Union1.Target[k];
    }

    return(i);
  }

// https://www.mql5.com/ru/forum/277866/page5#comment_12374941
#undef MACRO_STRUCT
#define MACRO_STRUCT(T)         \
  struct CONVERT_STRUCT2        \
  {                             \
    T Data[CONVERT_AMOUNT];     \
  };                            \
                                \
  CONVERT_UNION<CONVERT_STRUCT2

  template <typename SOURCE, typename TARGET>
  static int ArrayToStruct( const SOURCE &Src_Array[], TARGET &Dst_Array[] )
  {
    CONVERT_UNION<TARGET, SOURCE> Union1 = {0};
    MACRO_STRUCT(TARGET), SOURCE> Union2;

    const int SizeSource = ::ArraySize(Src_Array);
    const int SizeTarget = ::ArrayResize(Dst_Array, SizeSource * sizeof(SOURCE) / sizeof(TARGET));

    const int EndPos = SizeSource - (SizeSource % (sizeof(Union2) / sizeof(SOURCE)));
    int i = 0;
    int j = 0;

    while (j < EndPos)
    {
      j += ::ArrayCopy(Union2.Target, Src_Array, 0, j, sizeof(Union2) / sizeof(SOURCE));
      i += ::ArrayCopy(Dst_Array, Union2.Source.Data, i);
    }

    while (i < SizeTarget)
    {
      j += ::ArrayCopy(Union1.Target, Src_Array, 0, j, sizeof(Union1) / sizeof(SOURCE));
      //for (int k = 0; k < sizeof(Union1) / sizeof(SOURCE); k++)
      //  Union1.Target[k] = Src_Array[j++];

      Dst_Array[i++] = Union1.Source;
    }

    return(i);
  }

#undef CONVERT_AMOUNT
#undef MACRO_STRUCT

public:
  template <typename SOURCE, typename TARGET>
  static int ArrayToArray( const SOURCE &Src_Array[], TARGET &Dst_Array[] )
  {
    return((bool)(sizeof(SOURCE) % sizeof(TARGET))
           ? ((bool)(sizeof(TARGET) % sizeof(SOURCE)) ? _ArrayCopy(Dst_Array, Src_Array) / sizeof(TARGET)
                                                      : CONVERT::ArrayToStruct(Src_Array, Dst_Array))
           : CONVERT::StructToArray(Src_Array, Dst_Array));
  }
};