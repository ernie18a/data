class RESOURCE
{
public:
  const string Name;

  RESOURCE( const string sName = "::" + __FILE__ ) : Name(sName )
  {
  }

  ~RESOURCE( void)
  {
    ::ResourceFree(this.Name);
  }

  virtual bool Set( const uint &Data[], const uint Width = 1, const ENUM_COLOR_FORMAT ColorFormat = COLOR_FORMAT_XRGB_NOALPHA ) const
  {
    return(::ResourceCreate(this.Name, Data, Width, (Width == 0) ? ::ArraySize(Data) : ::ArraySize(Data) / Width, 0, 0, Width, ColorFormat));
  }

  int Get( uint &Data[] ) const
  {
    uint Width;
    uint Height;

    return(::ResourceReadImage(this.Name, Data, Width, Height) ? ::ArraySize(Data) : 0);
  }
};