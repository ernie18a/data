#include "String.mqh"

struct FILE_PRICES
{
  int Size;

  string Name;
  string Path;

  string FullPath( void ) const
  {
    return(this.Path + this.Name);
  }

  bool operator ==( const FILE_PRICES &File ) const
  {
    return((this.Name == File.Name) && (this.Size == File.Size));
  }

  bool IsBegin( const string &Str ) const
  {
    return(STRING::IsBegin(this.Name, Str));
  }

  string ToString() const
  {
    return(this.FullPath() + " " + (string)this.Size + " bytes");
  }
};