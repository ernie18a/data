#property strict

#include <EventBase.mqh>

class RESOURCE : public EVENTBASE
{
public:
  const string Name;

  RESOURCE( const bool Add = FALSE ) : EVENTBASE(Add), Name("::" + (string)::MathRand())
  {
  }

  ~RESOURCE( void)
  {
    ::ResourceFree(this.Name);
  }

  virtual bool Set( const uint &Data[], const uint Width ) const
  {
    return(::ResourceCreate(this.Name, Data, Width, (Width == 0) ? ::ArraySize(Data) : ::ArraySize(Data) / Width, 0, 0, Width, ::COLOR_FORMAT_ARGB_NORMALIZE));
  }
};