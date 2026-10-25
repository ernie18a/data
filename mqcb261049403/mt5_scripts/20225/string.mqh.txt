#define SPACE_SYMBOL " "

class STRING
{
public:
  static void DeleteMultiStrings( string &Str, const string StrDelete = SPACE_SYMBOL )
  {
    while (::StringReplace(Str, StrDelete + StrDelete, StrDelete))
      ;

    return;
  }

  static string Between( string &Str, const string StrBegin, const string StrEnd = NULL )
  {
    int PosBegin = ::StringFind(Str, StrBegin);
    PosBegin = (PosBegin >= 0) ? PosBegin + ::StringLen(StrBegin) : 0;

    const int PosEnd = ::StringFind(Str, StrEnd, PosBegin);

    const string Res = ::StringSubstr(Str, PosBegin, (PosEnd >= 0) ? PosEnd - PosBegin : -1);
    Str = (PosEnd >= 0) ? ::StringSubstr(Str, PosEnd + ::StringLen(StrEnd)) : NULL;

    if (Str == "")
      Str = NULL;

    return(Res);
  }

  static int BytesToStrings( const uchar &Bytes[], string &Str[] )
  {
//    return(::StringSplit(::CharArrayToString(Bytes), '\n', Str));
    return((::StringSplit(::CharArrayToString(Bytes), '\n', Str) > 0) ? ::ArrayResize(Str, ::ArraySize(Str) - 1) : 0);
  }

  static bool IsBegin( const string &Str, const string StrBegin )
  {
    return((StrBegin != NULL ) ? !::StringFind(Str, StrBegin) : true);
  }

  static int GetIndex( const string &Array[], const string &Element )
  {
    const int Size = ::ArraySize(Array);

    for (int i = 0; i < Size; i++)
      if (STRING::IsBegin(Array[i], Element))
        return(i);

    return(-1);
  }

  // https://www.mql5.com/ru/forum/170952/page83#comment_7121066
  static double ToDouble( const string Str, const uint StartPos = 0 )
  {
    const uint Size = ::StringLen(Str);

    bool Sign = false;
    uint i = StartPos;

    while (i < Size)
    {
      const int Digit = Str[i];

      if ((Digit != ' ') && (Digit != '\t') && (Digit != '\n') && (Digit != '\r'))
      {
        if ((Sign = (Digit == '-')) || (Digit == '+'))
          i++;

        break;
      }

      i++;
    }

    long Res = 0;
    int point = 0;

    while (i < Size)
    {
      const int Digit = Str[i];

      if (!point && (Digit == '.'))
        point = 1;
      else if (((Digit >= '0') && (Digit <= '9')))
      {
        Res = Res * 10 + Digit - '0';

        if (point)
          point *= 10;
      }
      else
        break;

      i++;
    }

    if (Sign)
      Res = -Res;

    return((point > 1) ? Res / (double)point : Res); // Возможна потеря точности при делении
  }
};