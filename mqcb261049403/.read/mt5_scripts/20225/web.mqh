class WEB
{
public:
  static bool Get( uchar &Data[], const string URL, const int TimeOut = 5000 )
  {
    string Headers;
    char Post[];

    ::Print("Downloading " + URL);

    ulong StartTime = ::GetTickCount();

    const bool Res = (::WebRequest("GET", URL, NULL, NULL, TimeOut, Post, 0, Data, Headers) != -1);

    if (Res)
    {
      StartTime = ::GetTickCount() - StartTime;

      ::Print("Done! - " + (string)::ArraySize(Data) + " bytes" + (StartTime ? " (" + (string)(::ArraySize(Data) / StartTime) + " Kb/s.)" : NULL));
    }
    else
    {
      ::Print("WebRequest Error - " + (string)::GetLastError());

      if (::GetLastError() == ERR_FUNCTION_NOT_ALLOWED)
        ::Print("Please add \"" + URL + "\" domain name to the list of allowed URLs!");
    }

    return(Res);
  }

  static bool IsURL( const string Str )
  {
    return(::StringFind(Str, "://") != -1);
  }
};