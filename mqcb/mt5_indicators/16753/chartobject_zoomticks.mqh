#property strict

#include "ChartObjectResource.mqh"
#include "Ticks\TicksPicture2.mqh"

#define SETCOLOR(A) Color##A((cColor##A == ::clrNONE) ? 0 : ::ColorToARGB(cColor##A, Transparency))

class CHARTOBJECT_ZOOMTICKS : public CHARTOBJECTRESOURCE
{
private:
  void SetMaxMin( void ) const
  {
    const double PriceMax = this.Ticks.GetMax();
    const double PriceMin = this.Ticks.GetMin();
    const double PriceHeight = this.Scale * (PriceMax - PriceMin) / 2;
    const double Avg = (PriceMax + PriceMin) / 2;

    this.SetProperty(CHART_FIXED_MAX, Avg + PriceHeight); // Фиксированный максимум графика
    this.SetProperty(CHART_FIXED_MIN, Avg - PriceHeight); // Фиксированный минимум графика

    return;
  }

protected:
  ulong time;

  ulong HalfInterval;
  double Scale;

  TICKS* Ticks;

public:
  const uint ColorBid;
  const uint ColorAsk;
  const uint ColorSpread;

  CHARTOBJECT_ZOOMTICKS( TICKS* tTicks, const long lChart_ID = 0,
                         const color cColorBid = ::clrBlue, const color cColorAsk = ::clrRed,
                         const color cColorSpread = ::clrYellow, const uchar Transparency = 0x7F ) :
                         CHARTOBJECTRESOURCE(lChart_ID), Ticks(tTicks),
                         SETCOLOR(Bid), SETCOLOR(Ask), SETCOLOR(Spread),
                         Scale(1), HalfInterval((THOUSAND * ::PeriodSeconds(::ChartPeriod(this.Chart))) >> 1), time(0)
  {
  }

  ~CHARTOBJECT_ZOOMTICKS( void )
  {
    this.Comment();
  }

  virtual void operator =( const double Value )
  {
    this.Scale = Value;

    return;
  }

  virtual void operator =( const datetime Value )
  {
    this.HalfInterval = Value >> 1;

    return;
  }

  virtual void operator =( const long Value )
  {
    this.time = Value;

    return;
  }

  virtual void Visual( void ) const
  {
    const ulong StartTime = ::GetMicrosecondCount();

    const ulong From = this.time - this.HalfInterval;
    const ulong To = this.time + this.HalfInterval;

    this.Ticks.Init(From, To);

    if (this.Ticks.GetAmount() > 0)
    {
      this.SetMaxMin();

      int X0;
      int Y0;

      TICKSPICTURE2 TicksPicture(this.Chart, this.Ticks, X0, Y0);

      this.SetProperty(::OBJPROP_XDISTANCE, X0);
      this.SetProperty(::OBJPROP_YDISTANCE, Y0);

      TicksPicture.Fill(this.ColorBid, ::BID);
      TicksPicture.Fill(this.ColorAsk, ::ASK);
      TicksPicture.Fill(this.ColorSpread, ::AVG);

      TicksPicture.SendToResource(this.Resource);

      this.Comment("LastCalcTime = " + (string)::TimeLocal() +
                   ", Ticks = " + (string)this.Ticks.GetAmount() +
                   ", CalcLength = " + (string)((::GetMicrosecondCount() - StartTime) / THOUSAND) + " ms.\n" +
                   "Interval = " + (string)((this.HalfInterval << 1) / THOUSAND) +
                   "." + ::IntegerToString((this.HalfInterval << 1) % THOUSAND, 3, '0') + " seconds. (" +
                   CHARTOBJECT::TimeToString(From) + " - " + CHARTOBJECT::TimeToString(To) + ")\n" +
                   "Scale = " + (string)this.Scale);

      CHARTOBJECT::Visual();
    }

    return;
  }
};

#undef SETCOLOR