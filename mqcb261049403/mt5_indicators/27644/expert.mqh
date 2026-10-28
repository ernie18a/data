#property strict

#ifndef __MQL5__
  #define ShortArrayToString CharArrayToString
  #define StringToShortArray StringToCharArray
  #define short uchar

// https://www.mql5.com/ru/docs/files/fileload
template <typename T>
long FileLoad( const string FileName, T &Buffer[], const int CommonFlag = 0 )
{
  long Res = -1;

  const int handle = FileOpen(FileName, FILE_READ | FILE_BIN | CommonFlag);

  if (handle != INVALID_HANDLE)
  {
    if (!(Res = FileReadArray(handle, Buffer)))
      Res = -1;

    FileClose(handle);
  }

  return(Res);
}

// https://www.mql5.com/ru/docs/files/filesave
template <typename T>
bool FileSave( const string FileName, const T &Buffer[], const int CommonFlag = 0 )
{
  const int handle = FileOpen(FileName, FILE_WRITE | FILE_BIN | CommonFlag);

  const bool Res = (handle != INVALID_HANDLE) && FileWriteArray(handle, Buffer);

  if (handle != INVALID_HANDLE)
    FileClose(handle);

  return(Res);
}

#endif // __MQL5__

#define FILENAME (__FILE__ + ".tpl")
#define PATH "\\Files\\"
#define STRING_END "\r\n"
#define EXPERT_BEGIN (STRING_END + STRING_END + "<expert>" + STRING_END)
#define EXPERT_END ("</expert>" + STRING_END)
#define EXPERT_INPUT_BEGIN ("<inputs>" + STRING_END)
#define EXPERT_INPUT_END ("</inputs>" + STRING_END)
#define EXPERT_CHART_BEGIN ("<chart>" + STRING_END)
#define EXPERT_NAME "name="
#define EXPERT_STOPLEVEL "stops_color="

#ifdef __MQL5__
  #define EXPERT_PATH "path="
  #define EXPERT_FLAGS "expertmode="
#else // __MQL5__
  #define EXPERT_PATH EXPERT_NAME
  #define EXPERT_FLAGS "flags="
#endif // __MQL5__

#define INPUT_BEGIN "!["
#define INPUT_END "]!"

class EXPERT
{
private:
  static bool StringReplace( string &Str, const string StrBegin, const string StrEnd, const string StrNew )
  {
    const int PosBegin = ::StringFind(Str, StrBegin);
    const bool Res = (PosBegin >= 0);

    if (Res)
    {
      const int PosEnd = ::StringFind(Str, StrEnd, PosBegin + ::StringLen(StrBegin));

      Str = ::StringSubstr(Str, 0, PosBegin) + StrNew + ((PosEnd >= 0) ? ::StringSubstr(Str, PosEnd + ::StringLen(StrEnd)): NULL);
    }

    return(Res);
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

  static string StringBetween2( string &Str, const string StrBegin, const string StrEnd = NULL )
  {
    return(StrBegin + EXPERT::StringBetween(Str, StrBegin, StrEnd) + StrEnd);
  }

  static string TemplateToString( const long Chart_ID = 0, const bool CheckExpert = false )
  {
    short Data[];

    return(((!CheckExpert || EXPERT::Is(Chart_ID)) && ::ChartSaveTemplate((ulong)Chart_ID, PATH + FILENAME) && (::FileLoad(FILENAME, Data) > 0)) ?
           ::ShortArrayToString(Data) : NULL);
  }

  static bool TemplateApply( const long Chart_ID, const string &Str, const bool Sync = true )
  {
    string TmpStr = Str;

    const bool SyncFlag = (Sync && Chart_ID && (Chart_ID != ::ChartID()) && !::IsStopped());

    if (SyncFlag)
    {
      const color ColorStopLevel = (color)::ChartGetInteger(Chart_ID, CHART_COLOR_STOP_LEVEL);

      if ((bool)(ColorStopLevel >> 24))
        ::ChartSetInteger(Chart_ID, CHART_COLOR_STOP_LEVEL, ColorStopLevel & 0xFFFFFF);

      const int NewColorStopLevel = (int)EXPERT::StringBetween(TmpStr, EXPERT_STOPLEVEL, STRING_END) | (0x01 << 24);

      TmpStr = Str;
      EXPERT::StringReplace(TmpStr, EXPERT_STOPLEVEL, STRING_END, EXPERT_STOPLEVEL + (string)NewColorStopLevel + STRING_END);
    }

    short Data[];
    const bool Res = ::StringToShortArray(TmpStr, Data, 0, ::StringLen(TmpStr)) &&
                     ::FileSave(FILENAME, Data) && ::ChartApplyTemplate((ulong)Chart_ID, PATH + FILENAME);

    if (Res && SyncFlag)
    {
      long Value;

      while ((!::IsStopped() && ::ChartGetInteger(Chart_ID, CHART_COLOR_STOP_LEVEL, 0, Value) && (!(bool)((int)Value >> 24))))
        ::Sleep(0);

      ::ChartSetInteger(Chart_ID, CHART_COLOR_STOP_LEVEL, (int)Value & 0xFFFFFF);
    }

    return(Res);
  }

  static int CorrectMqlParams( MqlParam &Params[] )
  {
    const int Amount = ::ArraySize(Params);

    for (int i = 1; i < Amount; i++)
    {
      const ENUM_DATATYPE Type = Params[i].type;

      if ((Type == TYPE_FLOAT) || (Type == TYPE_DOUBLE))
        Params[i].string_value = (string)Params[i].double_value;
      else if (Type != TYPE_STRING)
        Params[i].string_value = (string)Params[i].integer_value;
    }

    return(Amount);
  }

  static string GetInputName( MqlParam &Param )
  {
    return(EXPERT::StringBetween(Param.string_value, INPUT_BEGIN, INPUT_END));
  }

  static bool GetInputNames( MqlParam &Parameters[], string &InputNames[] )
  {
    const int Size = ::ArraySize(Parameters);
    bool Res = (Size > 1);

    if (Res)
    {
      ::ArrayResize(InputNames, Size - 1);

      for (int i = 1; (i < Size) && Res; i++)
      {
        InputNames[i - 1] = EXPERT::GetInputName(Parameters[i]);
        Res &= (InputNames[i - 1] != NULL);
      }
    }

    return(Res);
  }

  static int GetLastPos( const string &Str, const short Char )
  {
    int Pos = ::StringLen(Str) - 1;

    while ((Pos >= 0) && (Str[Pos] != Char))
      Pos--;

    return(Pos);
  }

  static string GetName( const string &Path )
  {
    const int BeginPos = EXPERT::GetLastPos(Path, '\\') + 1;
    const int LastPos = EXPERT::GetLastPos(Path, '.');

    return((LastPos > BeginPos) ? ::StringSubstr(Path, BeginPos, LastPos - BeginPos) : NULL);
  }

public:
  // Запущен ли советник на соответствующем чарте?
  static bool Is( const long Chart_ID = 0 )
  {
  #ifdef __MQL5__
    return(::ChartGetString(Chart_ID, CHART_EXPERT_NAME) != NULL);
  #else // __MQL5__
    string Template = EXPERT::TemplateToString(Chart_ID);

    return(EXPERT::StringBetween(Template, EXPERT_BEGIN + EXPERT_NAME, STRING_END) != NULL);
  #endif //__MQL5__
  }

  // Удаляет с соответствующего чарта советник
  static bool Remove( const long Chart_ID = 0 )
  {
    string Str = EXPERT::TemplateToString(Chart_ID, true);

    return((Str != NULL) && EXPERT::StringReplace(Str, EXPERT_BEGIN, EXPERT_END, NULL) && EXPERT::TemplateApply(Chart_ID, Str));
  }

  // Перезапускает советник на соответствующем чарте
  static bool Reopen( const long Chart_ID = 0 )
  {
    const string Str = EXPERT::TemplateToString(Chart_ID, true);

    return((Str != NULL) && EXPERT::TemplateApply(Chart_ID, Str));
  }

  // Получает данные о запущенном советнике на соответствующем чарте
  static int Parameters( const long Chart_ID,
                         MqlParam &Parameters[], // Путь к советнику и значения его входных параметров
                         string &Names[] )       // Имена входных параметров
  {
    string Str = EXPERT::TemplateToString(Chart_ID, true);
    int Res = 0;

    if (Str != NULL)
    {
      Str = EXPERT::StringBetween(Str, EXPERT_BEGIN, EXPERT_END);

      ::ArrayFree(Parameters);
      ::ArrayFree(Names);

      int Amount = ::ArrayResize(Parameters, 1) - 1;

      Parameters[Amount].type = TYPE_STRING;
      Parameters[Amount].integer_value = 0;
      Parameters[Amount].double_value = 0;
      Parameters[Amount].string_value = EXPERT::StringBetween(Str, EXPERT_PATH, STRING_END);

      Res = (int)EXPERT::StringBetween(Str, EXPERT_FLAGS, STRING_END);
      Str = EXPERT::StringBetween(Str, EXPERT_INPUT_BEGIN, EXPERT_INPUT_END);

      while (Str != NULL)
      {
        ::ArrayResize(Names, Amount + 1);
        Names[Amount] = EXPERT::StringBetween(Str, NULL, "=");
        Amount++;

        ::ArrayResize(Parameters, Amount + 1);
        Parameters[Amount].type = TYPE_STRING;
        Parameters[Amount].string_value = EXPERT::StringBetween(Str, NULL, STRING_END);
        Parameters[Amount].integer_value = (long)Parameters[Amount].string_value;
        Parameters[Amount].double_value = (double)Parameters[Amount].string_value;
      }
    }

    return(Res);
  }

  // Запускает советник на соответствующем чарте
  static bool Run( const long Chart_ID,
                   MqlParam &Parameters[] ) // Путь к советнику и значения его входных параметров
  {
    static bool FirstRun = true;

    string StrTemplate = EXPERT::TemplateToString(Chart_ID, false);

    bool Res = (StrTemplate != NULL);

    if (Res)
    {
      string InputNames[];
      const bool FlagInput = GetInputNames(Parameters, InputNames);

      if (EXPERT::Is(Chart_ID))
      {
        string Str = StrTemplate;
        Str = EXPERT::StringBetween(Str, EXPERT_BEGIN, EXPERT_END);

        string StrTmp = Str;

        if (EXPERT::StringBetween(StrTmp, EXPERT_PATH, STRING_END) == Parameters[0].string_value)
        {
          string StrNew = EXPERT::StringBetween2(Str, NULL, EXPERT_INPUT_BEGIN);
          Str = EXPERT::StringBetween(Str, NULL, EXPERT_INPUT_END);

          const int Amount = EXPERT::CorrectMqlParams(Parameters);
          int i = 1;

          while (Str != NULL)
            if (i < Amount)
            {
              StrNew += EXPERT::StringBetween2(Str, NULL, "=") + Parameters[i].string_value + STRING_END;

              EXPERT::StringBetween(Str, NULL, STRING_END);

              i++;
            }
            else
              StrNew += EXPERT::StringBetween2(Str, NULL, STRING_END);

          StrNew = EXPERT_BEGIN + StrNew + EXPERT_INPUT_END + EXPERT_END;

          Res = EXPERT::StringReplace(StrTemplate, EXPERT_BEGIN, EXPERT_END, StrNew) && EXPERT::TemplateApply(Chart_ID, StrTemplate);
        }
        else if (FirstRun)
        {
          const string Path = Parameters[0].string_value;
          const string Name = EXPERT::GetName(Path);

          const string StrNew = EXPERT_BEGIN +
                              #ifdef __MQL5__
                                EXPERT_NAME + Name + STRING_END +
                              #endif // __MQL5__
                                EXPERT_PATH + Path + STRING_END + EXPERT_END;

          FirstRun = false;
          Res = EXPERT::StringReplace(StrTemplate, EXPERT_BEGIN, EXPERT_END, StrNew) && EXPERT::TemplateApply(Chart_ID, StrTemplate) &&
                EXPERT::Run(Chart_ID, Parameters);

          FirstRun = true;
        }
        else
        {
          FirstRun = true;

          Res = false;
        }
      }
      else if (FlagInput)
      {
        const int Amount = EXPERT::CorrectMqlParams(Parameters);
        string StrNew = NULL;

        for (int i = 1; i < Amount; i++)
          StrNew += InputNames[i - 1] + "=" + Parameters[i].string_value + STRING_END;

        const string Path = Parameters[0].string_value;
        const string Name = EXPERT::GetName(Path);

        StrTemplate = EXPERT::StringBetween2(StrTemplate, NULL, EXPERT_CHART_BEGIN) + EXPERT_BEGIN +
                    #ifdef __MQL5__
                      EXPERT_NAME + Name + STRING_END +
                    #endif // __MQL5__
                      EXPERT_PATH + Path + STRING_END +
                      ((StrNew == NULL) ? NULL : EXPERT_INPUT_BEGIN + StrNew + EXPERT_INPUT_END) + EXPERT_END + StrTemplate;

        Res = EXPERT::TemplateApply(Chart_ID, StrTemplate);

        FirstRun = true;
      }
      else if (FirstRun)
      {
        const string Path = Parameters[0].string_value;
        const string Name = EXPERT::GetName(Path);

        StrTemplate = EXPERT::StringBetween2(StrTemplate, NULL, EXPERT_CHART_BEGIN) + EXPERT_BEGIN +
                    #ifdef __MQL5__
                      EXPERT_NAME + Name + STRING_END +
                    #endif // __MQL5__
                      EXPERT_PATH + Path + STRING_END + EXPERT_END + StrTemplate;

        FirstRun = false;
        Res = EXPERT::TemplateApply(Chart_ID, StrTemplate) && ((::ArraySize(Parameters) > 1) ? EXPERT::Run(Chart_ID, Parameters) : true);

        FirstRun = true;
      }
      else
      {
        FirstRun = true;

        Res = false;
      }
    }

    return(Res);
  }

  // Прописывает в Param название входного параметра, чтобы можно было в один проход запустить скрипт/советник.
  static void AddInputName( MqlParam &Param, const string InputName = NULL )
  {
    EXPERT::StringBetween(Param.string_value, INPUT_BEGIN, INPUT_END);

    if (InputName != NULL)
      Param.string_value = INPUT_BEGIN + InputName + INPUT_END + Param.string_value;

    return;
  }
};

#undef INPUT_END
#undef INPUT_BEGIN

#undef EXPERT_FLAGS
#undef EXPERT_PATH
#undef EXPERT_STOPLEVEL
#undef EXPERT_NAME
#undef EXPERT_CHART_BEGIN
#undef EXPERT_INPUT_END
#undef EXPERT_INPUT_BEGIN
#undef EXPERT_END
#undef EXPERT_BEGIN
#undef STRING_END
#undef PATH
#undef FILENAME

#ifndef __MQL5__
  #undef short
  #undef StringToShortArray
  #undef ShortArrayToString
#endif // __MQL5__