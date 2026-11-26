#include <Zip\Zip.mqh> // https://www.mql5.com/ru/articles/1971

#include "Files_Prices.mqh"
#include "CustomSymbol.mqh"

class THIRDPARTYTICKS : public DATA<string>
{
private:
  static const uchar CensoredURL[];
  static const uchar CensoredFolder[];

  FILES_PRICES FilesOffline;
  FILES_PRICES FilesOnline;

  uint Pos;

  static string GetSymbolName( const string Str )
  {
    return(::StringSubstr(Str, 0, ::StringFind(Str, "_")));
  }

  uint SetList( const FILES_PRICES* const Files )
  {
    const uint Size = this.SetReserve(Files.GetAmount());

    for (uint i = 0; i < Size; i++)
    {
      const string Symb = THIRDPARTYTICKS::GetSymbolName(Files[i].Name);

      if (!this.IsExist(Symb))
        this.Add(Symb);
    }

    return(this.GetAmount());
  }

public:
  uint Refresh( const bool Online = true )
  {
    this.Clear();

    if (!Online)
      this.FilesOnline.Clear();
    else
    {
      this.FilesOnline.Refresh();

      this.SetList(&this.FilesOnline);
    }

    this.FilesOffline.Refresh();

    return(this.SetList(&this.FilesOffline));
  }

  THIRDPARTYTICKS( const string Folder = NULL, const string URL = NULL ) :
                   FilesOffline((Folder == NULL) ? ::CharArrayToString(THIRDPARTYTICKS::CensoredFolder) : Folder),
                   FilesOnline((URL == NULL) ? ::CharArrayToString(THIRDPARTYTICKS::CensoredURL) : URL), Pos(0)
  {
    this.Refresh(false);
  }

  THIRDPARTYTICKS* operator []( const uint Index )
  {
    this.Pos = Index > this.GetAmount() ? 0 : Index;

    return(&this);
  }

  THIRDPARTYTICKS* operator []( const string Symb )
  {
    const int Index = STRING::GetIndex(this.Data, Symb);

    this.Pos = (Index == -1) ? 0 : Index;

    return(&this);
  }

  string GetName( void ) const
  {
    return(this.Pos < this.GetAmount() ? this.Data[this.Pos] : NULL);
  }

  bool Update( const bool Refresh = true )
  {
    const string Name = this.GetName();
    const uint Size = this.FilesOnline.GetAmount();

    if (Refresh)
      this.FilesOffline.Refresh();

    bool Res = ((Name != NULL) && Size);

    if (Res)
      ::Print("Updating symbol's history - " + (string)Name);

    for (uint i = 0; Res && (i < Size); i++)
    {
      const FILE_PRICES File = this.FilesOnline[i];

      if (File.IsBegin(Name) && !this.FilesOffline.IsExist(File))
      {
        uchar Bytes[];

        ::Print(File.ToString());
        Res = _CS(WEB::Get(Bytes, File.FullPath()) && ::FileSave(this.FilesOffline.Folder + Name + "\\" + File.Name, Bytes) && (!Refresh || this.FilesOffline.Refresh()));
      }
    }

    return(Res);
  }

  static long GetUncompressedSize( CZip &Zip )
  {
    long Res = 0;

    for (int i = Zip.TotalElements() - 1; i >= 0; i--)
        Res += Zip.ElementAt(i).UncompressedSize();

    return(Res);
  }

  string ToCustomSymbol( const bool Refresh = true, const bool OpenChart = false,  )
  {
//    static ulong FullTicks = 0;

    string Res = NULL;

    if (Refresh)
      this.FilesOffline.Refresh();

    const string Name = this.GetName();
    const uint Size = this.FilesOffline.GetAmount();

    if ((Name != NULL) && Size)
    {
      const string Folder = this.FilesOffline.Folder;
      const string Bank = ::StringSubstr(Folder, 0, ::StringLen(Folder) - 1);
      CUSTOMSYMBOL CustomSymbol(Name + "_" + Bank, Folder);

      CustomSymbol.SetProperty(SYMBOL_PAGE, this.FilesOnline.Folder);
      CustomSymbol.SetProperty(SYMBOL_BANK, Bank); // build 1755 - не работает
      CustomSymbol.SetProperty(SYMBOL_DESCRIPTION, "Created by " + __FILE__);

      CustomSymbol.SetProperty(SYMBOL_TRADE_STOPS_LEVEL, 0);

      ::Print("Creating symbol - " + CustomSymbol.Name);

      int FirstRun = 0;
      int TicksReserve = 0;
      long TotalTicks = 0;

      const ulong StartTime = ::GetMicrosecondCount();

      for (uint i = 0; _CS(i < Size); i++)
      {
        const FILE_PRICES File = this.FilesOffline[i];

        if (File.IsBegin(Name))
        {
          CZip Zip;

          Zip.LoadZipFromFile(File.FullPath(), 0);
          const int Amount = Zip.TotalElements();

          for (int index = 0; _CS(index < Amount); index++)
          {
            CZipContent* ZipContent = Zip.ElementAt(index);

            if (ZipContent.ZipType() == ZIP_TYPE_FILE)
            {
              uchar Bytes[];

              ((CZipFile*)ZipContent).GetUnpackFile(Bytes);
              ::Print("UnZip " + File.ToString() + " - unpack size " + (string)::ArraySize(Bytes) + " bytes.");

  //            ::Print("Parsing...");

              TotalTicks = CustomSymbol.AddTicks(Bytes, 0, TicksReserve);
              const ulong Interval = ::GetMicrosecondCount() - StartTime;

              if ((!FirstRun) && TotalTicks)
              {
                TicksReserve = (int)(5 *TotalTicks * THIRDPARTYTICKS::GetUncompressedSize(Zip) / (::ArraySize(Bytes) * 4));

                FirstRun++;
              }

              ::Print("Total Ticks (" + Name + ") = " +
                      (_CS(true) ? (string)TotalTicks + (Interval ? " (" + (string)(TotalTicks * 1000000 / Interval) + " ticks/sec.), Reserve = " + (string)TicksReserve : NULL)
                                 : "Stopped!"));
            }
          }

          if (FirstRun == 1)
          {
            TicksReserve = (int)(5 * TotalTicks * this.GetSize(false, Name) / (File.Size * 4));

            FirstRun++;
          }
        }
      }
/*
      FullTicks += TotalTicks;
      ::Print("FullTicks = " + (string)FullTicks);

      if (TotalTicks > TicksReserve)
        ::Alert(Name + ", TotalTicks = " + (string)TotalTicks + ", Reserve = " + (string)TicksReserve + ", Koef = " + DoubleToString((double)TotalTicks / TicksReserve, 3));
*/
      ::Print("Recording...");
      const int Amount = _CS(true) ? CustomSymbol.DataToSymbol() : -1;
//      const int Amount = 0;

      if (Amount <= 0)
      {
        ::Print(CustomSymbol.Name + " error write ticks - " + (_CS(true) ? (string)::GetLastError() : "Stopped!"));

        CustomSymbol.Delete();
      }
      else if (CustomSymbol.On())
      {
        ::Print((Res = CustomSymbol.Name) + " saved ticks = " + (string)Amount);

        if  (OpenChart)
          ::ChartOpen(CustomSymbol.Name, PERIOD_M1);
      }
    }

    return(Res);
  }

  ulong GetSize( const bool Online = true, const string FilterName = NULL ) const
  {
    return(Online ? this.FilesOnline.GetSize(FilterName) : this.FilesOffline.GetSize(FilterName));
  }
};

static const uchar THIRDPARTYTICKS::CensoredURL[] =
{
  0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x72, 0x61, 0x6E, 0x6E, 0x66, 0x6F, 0x72, 0x65,
  0x78, 0x2E, 0x63, 0x6F, 0x6D, 0x2F, 0x73, 0x74, 0x61, 0x74, 0x69, 0x63, 0x2F, 0x74, 0x69, 0x63,
  0x6B, 0x73, 0x5F, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x2F
};

static const uchar THIRDPARTYTICKS::CensoredFolder[] = {0x52, 0x61, 0x6E, 0x6E, 0x46, 0x6F, 0x72, 0x65, 0x78, 0x5C};