#property strict

#include "Bars.mqh"
#include "..\Resource.mqh"

enum ENUM_PRICE_TYPE
{
  BID,
  ASK,
  AVG
};

class TICKSPICTURE
{
private:
  static int GetBarWidth( const long Chart_ID = 0 )
  {
    return((int)(1 << ::ChartGetInteger(Chart_ID, ::CHART_SCALE)));
  }

  static datetime GetVisibleTime( const long Chart_ID = 0 )
  {
    datetime TmpTime;
    double TmpPrice;
    int TmpSubWindow;

    ::ChartXYToTimePrice(Chart_ID, 0, 0, TmpSubWindow, TmpTime, TmpPrice); // находим корректные координаты для ChartTimePriceToXY

    return(TmpTime);
  }

  static double GetVisiblePrice( const long Chart_ID = 0 )
  {
    return(::ChartGetDouble(Chart_ID, ::CHART_PRICE_MAX));
  }

  static int PriceToX( const datetime dtime, const long Chart_ID = 0 )
  {
    int X, Y;

    ::ChartTimePriceToXY(Chart_ID, 0, dtime, TICKSPICTURE::GetVisiblePrice(), X, Y);

    return(X);
  }

  static int PriceToY( const double Price, const long Chart_ID )
  {
    int X, Y;

    ::ChartTimePriceToXY(Chart_ID, 0, TICKSPICTURE::GetVisibleTime(Chart_ID), Price, X, Y);

    return(Y);
  }

protected:
  const BARS* bars;

  const int Amount;

  const double PriceMin;
  const double PriceMax;

  const int WidthBar;

  const int X0;
  const int Y0;

  const int Width;
  const int Height;

  const long Step;

  uint Pixels[];

  int PriceToY( const double Price ) const
  {
    return((this.PriceMax == this.PriceMin) ? 0 : (int)((this.PriceMax - Price) * (this.Height - 1) / (this.PriceMax - this.PriceMin)));
  }

public:

  TICKSPICTURE( const int Chart_ID, const BARS* bBars, int &x0, int &y0 ) :
               bars(bBars),
               Amount((::CheckPointer(bars) == POINTER_INVALID) ? 0 : bars.GetAmount()),
               PriceMin(Amount > 0 ? bars.GetMin() : 0),
               PriceMax(Amount > 0 ? bars.GetMax() : 0),
               WidthBar(TICKSPICTURE::GetBarWidth(Chart_ID)),
               X0((Amount > 0) ? TICKSPICTURE::PriceToX(bars[0].time, Chart_ID) - (WidthBar >> 1) : 0),
               Y0(TICKSPICTURE::PriceToY(PriceMax, Chart_ID)),
               Width(WidthBar * Amount),
               Height(TICKSPICTURE::PriceToY(PriceMin, Chart_ID) - Y0 + 1),
               Step(::PeriodSeconds(::ChartPeriod(Chart_ID)) * THOUSAND / WidthBar) // 60 * 1000 кратно 32-м - потери крайних тиков баров не будет
  {
    if (Amount > 0)
    {
      if (::ArrayResize(this.Pixels, this.Width * this.Height) > 0)
        ::ArrayFill(this.Pixels, 0, ::ArraySize(this.Pixels), 0);
    }

    x0 = this.X0;
    y0 = this.Y0;
  }

  void Fill( const color Color, const ENUM_PRICE_TYPE PriceType = ::BID )
  {
    const uint AmountPixels = ::ArraySize(this.Pixels);

    if ((Amount <= 0) || (Color == 0) || (AmountPixels < (uint)(this.Width * this.Height)))
      return;

    int Pos = 0;
    double high = ::DBL_MIN;
    double low = ::DBL_MAX;
    double PriceHigh = 0;
    double PriceLow = 0;
/*
    // Если хочется, чтобы свежий/текущий бар рисовался частично
    const BAR* LastBar = this.bars[Amount - 1];
    const int LastSize = LastBar.GetAmount();

    int NewWidth = this.Width;

    if (LastSize > 0)
    {
      const datetime NowTime = ::TimeCurrent();
      const datetime BeginTime = NowTime - (NowTime % ::PeriodSeconds());

      if (LastBar[LastSize - 1].time >= (long)BeginTime * THOUSAND)
        NewWidth -= (int)((BeginTime + ::PeriodSeconds() - NowTime) * THOUSAND / this.Step);
    }

    for (int X = 0; X < NewWidth; X++)
*/
    for (int X = 0; X < this.Width; X++)
    {
      const BAR* Bar = bars[X / this.WidthBar];
      const long Interval = Bar.time * THOUSAND + this.Step * (X % this.WidthBar);

      const int Size = Bar.GetAmount();

      if (X % this.WidthBar == 0)
        Pos = 0;

      while (Pos < Size)
      {
        if (Bar[Pos].time > Interval)
          break;

        PriceLow = (PriceType == ::ASK) ? Bar[Pos].ask : Bar[Pos].bid;
        PriceHigh = (PriceType == ::BID) ? Bar[Pos].bid : Bar[Pos].ask;

        if (PriceHigh > high)
          high = PriceHigh;

        if (PriceLow < low)
          low = PriceLow;

        Pos++;
      }

      if ((PriceHigh != 0) && (PriceLow != 0))
      {
        const int MinY = this.PriceToY(high);
        const int MaxY = this.PriceToY(low);

        uint j = X + MinY * this.Width;

        for (int Y = MinY; (Y <= MaxY) && (j < AmountPixels); Y++)
        {
          if ((PriceType != ::AVG))
            Pixels[j] |= Color;
          else if (Pixels[j] == 0)
            Pixels[j] = Color;

          j += this.Width;
        }

        high = PriceHigh;
        low = PriceLow;
      }
    }

    return;
  }

  bool SendToResource( const RESOURCE &Resource ) const
  {
    return(Resource.Set(this.Pixels, this.Width));
  }
};