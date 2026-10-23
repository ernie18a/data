class FILE
{
private:
  static int GetFileNames( string &FileNames[], int Pos = 0, string Filter = "*", const int Common_Flag = 0 )
  {
      string FileName;
      const long handle = ::FileFindFirst(Filter, FileName, Common_Flag);

      if (handle != INVALID_HANDLE)
      {
        const string Directory = FILE::GetDirectory(Filter);
        Filter = ::StringSubstr(Filter, ::StringLen(Directory));

        do
        {
          const string TmpFileName = Directory + FileName;

          if (::FileIsExist(TmpFileName, Common_Flag))
          {
            ::ArrayResize(FileNames, Pos + 1, 10000);
            FileNames[Pos] = TmpFileName;
            Pos++;
          }
        }
        while (::FileFindNext(handle, FileName));

        ::FileFindClose(handle);
      }

    return(Pos);
  }

public:
  static string GetDirectory( const string FileName )
  {
    int Pos = ::StringFind(FileName, "\\");
    int LastPos = Pos;

    while (Pos >= 0)
    {
      LastPos = Pos;

      Pos = ::StringFind(FileName, "\\", Pos + 1);
    }

    return((LastPos >= 0) ? ::StringSubstr(FileName, 0, LastPos + 1) : "");
  }

  static int GetDirectories( string &Directories[], int Pos = 0, string Filter = "*", const int Common_Flag = 0 )
  {
    string FileName;
    const long handle = ::FileFindFirst(Filter, FileName, Common_Flag);

    if (handle != INVALID_HANDLE)
    {
      const string Directory = FILE::GetDirectory(Filter);
      Filter = ::StringSubstr(Filter, ::StringLen(Directory));

      do
      {
        const string TmpFileName = Directory + FileName;

        if (!::FileIsExist(TmpFileName, Common_Flag))
        {
          ::ArrayResize(Directories, Pos + 1, 10000);
          Directories[Pos] = TmpFileName;
          Pos++;

          Pos = FILE::GetDirectories(Directories, Pos, TmpFileName + Filter, Common_Flag);
        }
      }
      while (::FileFindNext(handle, FileName));

      ::FileFindClose(handle);
    }

    return(Pos);
  }

  // Возвращает список всех файлов по фильтру
  static int GetFileNames( string &FileNames[], string Filter = "*", const int Common_Flag = 0 )
  {
    int Pos = FILE::GetFileNames(FileNames, 0, Filter, Common_Flag);

    const string Directory = FILE::GetDirectory(Filter);
    Filter = ::StringSubstr(Filter, ::StringLen(Directory));

    string Directories[];

    const int Size = FILE::GetDirectories(Directories, 0, Directory + "*", Common_Flag);

    for (int i = 0; i < Size; i++)
      Pos = FILE::GetFileNames(FileNames, Pos, Directories[i] + Filter, Common_Flag);

    return(Pos);
  }
};