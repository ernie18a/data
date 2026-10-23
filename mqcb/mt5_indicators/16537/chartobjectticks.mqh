#property strict

#include "ChartObjectResource.mqh"
#include "Ticks\TicksPicture.mqh"

class CHARTOBJECTTICKS : public CHARTOBJECTRESOURCE
{
public:
  const uint ColorBid;
  const uint ColorAsk;
  const uint ColorSpread;

  CHARTOBJECTTICKS( const long lChart_ID = 0, const color cColorBid = ::clrBlue, const color cColorAsk = ::clrRed, const color cColorSpread = ::clrYellow, const uchar Transparency = 0x7F )
                  : CHARTOBJECTRESOURCE(lChart_ID, 0, TRUE), ColorBid((cColorBid == ::clrNONE) ? 0 : ::ColorToARGB(cColorBid, Transparency)),
                                                             ColorAsk((cColorAsk == ::clrNONE) ? 0 : ::ColorToARGB(cColorAsk, Transparency)),
                                                             ColorSpread((cColorSpread == ::clrNONE) ? 0 : ::ColorToARGB(cColorSpread, Transparency))
  {
  }

  ~CHARTOBJECTTICKS( void )
  {
    ::Comment("");

    ::ChartRedraw();
  }

  virtual void Visual( void ) const
  {
    const ulong StartTime = ::GetMicrosecondCount();

    int X0;
    int Y0;

    BARS bars(this.Chart);

    TICKSPICTURE TicksPicture(this.Chart, &bars, X0, Y0);

    this.SetProperty(::OBJPROP_XDISTANCE, X0);
    this.SetProperty(::OBJPROP_YDISTANCE, Y0);

    TicksPicture.Fill(ColorBid, ::BID);
    TicksPicture.Fill(ColorAsk, ::ASK);
    TicksPicture.Fill(ColorSpread, ::AVG);

    TicksPicture.SendToResource(this.Resource);

    ::Comment("LastCalcTime = " + (string)::TimeLocal() +
              ", Ticks = " + (string)bars.GetAmountTicks() +
              ", CalcLength = " + (string)((::GetMicrosecondCount() - StartTime) / THOUSAND) + " ms.");

    ::ChartRedraw(this.Chart);

    return;
  }

  virtual void Event( const int id, const long &lparam, const double &dparam, const string &sparam )
  {
    if (id == ::CHARTEVENT_CHART_CHANGE)
      this.Visual();

    return;
  }
};