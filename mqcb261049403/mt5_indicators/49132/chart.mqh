#property strict

class CHART_BASE
{
public:
  static const ENUM_CHART_PROPERTY_INTEGER IndexInteger[];
};

static const ENUM_CHART_PROPERTY_INTEGER CHART_BASE::IndexInteger[] = {CHART_SHOW_OHLC, CHART_SHOW_GRID, CHART_SHOW_VOLUMES,
                                                                       CHART_SHOW_DATE_SCALE, CHART_SHOW_PRICE_SCALE, CHART_SCALEFIX};

class CHART : private CHART_BASE
{
private:
  bool FlagOn;

  // https://www.mql5.com/ru/forum/1111/page2650#comment_15022016
  long PropertyInteger[sizeof(CHART_BASE::IndexInteger) / sizeof(ENUM_CHART_PROPERTY_INTEGER)];
//  long PropertyInteger[sizeof(CHART::IndexInteger) / sizeof(ENUM_CHART_PROPERTY_INTEGER)];

  void Remember( void )
  {
    for (int i = sizeof(CHART::IndexInteger) / sizeof(ENUM_CHART_PROPERTY_INTEGER) - 1; i >= 0; i--)
      this.PropertyInteger[i] = ::ChartGetInteger(this.ChartId, CHART::IndexInteger[i]);

    this.FlagOn = true;

    return;
  }

public:
  const long ChartId;

  CHART( const int iChartId = 0 ) : ChartId(iChartId) // С нулем не все гладко - см. MyChart и т.д.
  {
    this.Remember();
  }

  ~CHART( void )
  {
    this.On();
  }

  void On( long Chart = 0 )
  {
    if (Chart == 0)
      Chart = this.ChartId;

    for (int i = sizeof(CHART::IndexInteger) / sizeof(ENUM_CHART_PROPERTY_INTEGER) - 1; i >= 0; i--)
      ::ChartSetInteger(Chart, CHART::IndexInteger[i], this.PropertyInteger[i]);

    ::ChartRedraw(Chart);

    this.FlagOn = (Chart == this.ChartId);

    return;
  }

  void Off( void )
  {
    this.Remember();

    ::ChartSetInteger(this.ChartId, CHART_SHOW_OHLC, false);
    ::ChartSetInteger(this.ChartId, CHART_SHOW_GRID, false);
    ::ChartSetInteger(this.ChartId, CHART_SHOW_VOLUMES, false);
    ::ChartSetInteger(this.ChartId, CHART_SHOW_DATE_SCALE, false);
     ::ChartSetInteger(this.ChartId, CHART_SHOW_PRICE_SCALE, false);

    ::ChartSetInteger(this.ChartId, CHART_SCALEFIX, true);
    ::ChartSetDouble(this.ChartId, CHART_FIXED_MAX, ::ChartGetDouble(this.ChartId, CHART_PRICE_MAX) * 1e3);
    ::ChartSetDouble(this.ChartId, CHART_FIXED_MIN, ::ChartGetDouble(this.ChartId, CHART_PRICE_MIN) * 1e3);

    ::ChartRedraw(this.ChartId);

    this.FlagOn = false;

    return;
  }

  void Swap( void )
  {
    if (this.FlagOn)
      this.Off();
    else
      this.On();

    return;
  }

  bool IsOn( void ) const
  {
    return(this.FlagOn);
  }
};