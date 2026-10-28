#include "Web.mqh"
#include "File.mqh"
#include "File_Prices.mqh"
#include "Data.mqh"

class FILES_PRICES : public DATA<FILE_PRICES>
{
private:
  const bool IsWeb;

  virtual uint RefreshOffline( void )
  {
    this.Clear();

    string FileNames[];
    const int Amount = this.SetReserve(FILE::GetFileNames(FileNames, this.Folder + "*.zip"));

    FILE_PRICES File;

    for (int i = 0; i < Amount; i++)
    {
      File.Path = FILE::GetDirectory(FileNames[i]);

      File.Name = ::StringSubstr(FileNames[i], ::StringLen(File.Path));
      File.Size = (int)::FileGetInteger(FileNames[i], FILE_SIZE);

      this.Add(File);
    }

    return(this.GetAmount());
  }

  virtual uint RefreshOnline( void )
  {
    this.Clear();

    uchar Bytes[];

    if (WEB::Get(Bytes, this.Folder))
    {
      FILE_PRICES File;
      File.Path = this.Folder;

      string Res[];
      const int Amount = STRING::BytesToStrings(Bytes, Res);

      for (int i = 4; i < Amount - 3; i++)
      {
        string Str = Res[i];

        STRING::DeleteMultiStrings(Str);

        File.Name = STRING::Between(Str, "\"", "\"");

        STRING::Between(Str, SPACE_SYMBOL, SPACE_SYMBOL); // Date
        STRING::Between(Str, NULL, SPACE_SYMBOL);         // Time

        File.Size = (int)Str;

        this.Add(File);
      }
    }

    return(this.GetAmount());
  }

public:
  const string Folder;

  FILES_PRICES( const string sFolder ) : Folder(sFolder), IsWeb(WEB::IsURL(sFolder))
  {
  }

  uint Refresh( void )
  {
    return(this.IsWeb ? this.RefreshOnline() : this.RefreshOffline());
  }

  ulong GetSize( const string FilterName = NULL ) const
  {
    ulong Res = 0;
    const uint Amount = this.GetAmount();

    for (uint i = 0; i < Amount; i++)
      if (this[i].IsBegin(FilterName))
        Res += this[i].Size;

    return(Res);
  }
};