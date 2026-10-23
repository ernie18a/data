#include "Resource.mqh"
#include "Convert.mqh"

template <typename T>
class RESOURCEDATA : private RESOURCE
{
public:
  RESOURCEDATA( const string sName = "::" + __FILE__ ) : RESOURCE(sName)
  {
  }

  void Free( void ) const
  {
    ::ResourceFree(this.Name);

    return;
  }

  int Total( void ) const
  {
    uint Data[];

    return(RESOURCE::Get(Data) * sizeof(uint) / sizeof(T));
  }

  int Get( T &Array[] ) const
  {
    uint Data[];

    return(RESOURCE::Get(Data) ? CONVERT::ArrayToArray(Data, Array) : 0);
  }

  const T operator[]( const uint Pos ) const
  {
    const T Res = {0};
    uint Data[];
    T Array[];

    return(RESOURCE::Get(Data) && (Pos < (uint)this.Get(Array)) ? Array[Pos] : Res);
  }

  void operator =( const T &Value ) const
  {
    uint Data[];
    T Array[1];

    Array[0] = Value;

    CONVERT::ArrayToArray(Array, Data);
    this.Set(Data);

    return;
  }

  void operator =( const T &Value[] ) const
  {
    uint Data[];

    CONVERT::ArrayToArray(Value, Data);
    this.Set(Data);

    return;
  }

  void operator +=( const T &Value ) const
  {
    T Array[];

    Array[::ArrayResize(Array, this.Get(Array) + 1) - 1] = Value;

    this = Array;

    return;
  }

  void operator +=( const T &Value[] ) const
  {
    T Array[];

    ::ArrayCopy(Array, Value, this.Get(Array));

    this = Array;

    return;
  }

  string GetName( void ) const
  {
    return(this.Name);
  }

  string GetFullName( void ) const
  {
    return((this.GetName()[0] == ':') ? ::StringSubstr(::MQLInfoString(MQL_PROGRAM_PATH), ::StringLen(::TerminalInfoString(TERMINAL_DATA_PATH)) + 5) + this.GetName() : this.GetName());
  }
};