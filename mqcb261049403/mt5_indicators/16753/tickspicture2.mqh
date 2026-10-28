#property strict

#include "Ticks.mqh"
#include "..\Resource.mqh"

enum ENUM_PRICE_TYPE
{
  BID,
  ASK,
  AVG
};

class TICKSPICTURE2
{
private:
  int GetDataWidth( const long Chart_ID = 0 ) const
  {
    int Res = 0;

    if (this.Amount > 0)
    {
      Res = (int)((double)::ChartGetInteger(Chart_ID, CHART_WIDTH_IN_PIXELS) *
                  (this.TimeWidth) / (this.Ticks.GetTo() - this.Ticks.GetFrom()) + 1 - DBL_MIN); // + 1 - DBL_MIN - целая часть сверху.

      if (Res == 0)
        Res = 1;
    }

    return(Res);
  }

  int GetDataHeight( const long Chart_ID = 0 ) const
  {
    int Res = 0;

    if (this.Amount > 0)
    {
      Res = (int)(::ChartGetInteger(Chart_ID, CHART_HEIGHT_IN_PIXELS) * this.PriceHeight /
                  (::ChartGetDouble(Chart_ID, CHART_PRICE_MAX) - ::ChartGetDouble(Chart_ID, CHART_PRICE_MIN)) + 1 - DBL_MIN); // + 1 - DBL_MIN - целая часть сверху.

      if (Res == 0)
        Res = 1;
    }

    return(Res);
  }

  int TimeToX( const ulong utime, const long Chart_ID )
  {
    return((int)((double)(utime - this.Ticks.GetFrom()) * ::ChartGetInteger(Chart_ID, CHART_WIDTH_IN_PIXELS) / (this.Ticks.GetTo() - this.Ticks.GetFrom())));
  }

  static int PriceToY( const double Price, const long Chart_ID )
  {
    const double PriceMaxMin = ::ChartGetDouble(Chart_ID, CHART_PRICE_MAX) - ::ChartGetDouble(Chart_ID, CHART_PRICE_MIN);

    return((PriceMaxMin == 0) ? 0 :
           (int)((::ChartGetDouble(Chart_ID, CHART_PRICE_MAX) - Price) * (::ChartGetInteger(Chart_ID, CHART_HEIGHT_IN_PIXELS) - 1) / PriceMaxMin));
  }

protected:
  const TICKS* Ticks;

  uint Pixels[];

  int PriceToY( const double Price ) const
  {
    return((int)((this.PriceMax - Price) * (this.Height - 1) / this.PriceHeight));
  }

  int TimeToX( const ulong time ) const
  {
    return((int)((time - this.TimeFrom) * (this.Width - 1) / this.TimeWidth));
  }

public:
  const int Amount;

  const double PriceMax;
  const double PriceHeight;

  const ulong TimeFrom;
  const int TimeWidth;

  const int X0;
  const int Y0;

  const int Width;
  const int Height;

  TICKSPICTURE2( const long Chart_ID, const TICKS* tTicks, int &x0, int &y0 ) :
               Ticks(tTicks),
               Amount((::CheckPointer(this.Ticks) == POINTER_INVALID) ? 0 : this.Ticks.GetAmount()),
               PriceMax(Amount > 0 ? this.Ticks.GetMax() : 0),
               PriceHeight(this.PriceMax - (Amount > 0 ? this.Ticks.GetMin() : 0)),
//               TimeFrom(this.Ticks.GetFrom()),                       // Широкий вариант - предположительно меньше мерцаний.
//               TimeWidth((int)(this.Ticks.GetTo() - this.TimeFrom)), // Широкий вариант - предположительно меньше мерцаний.
               TimeFrom((Amount > 0) ? this.Ticks[0].time : 0),                                    // Узкий вариант - предположительно больше мерцаний.
               TimeWidth((int)(((Amount > 0) ? this.Ticks[Amount - 1].time : 0) - this.TimeFrom)), // Узкий вариант - предположительно больше мерцаний.
               X0((Amount > 0) ?  this.TimeToX(this.TimeFrom, Chart_ID) : 0),
               Y0(TICKSPICTURE2::PriceToY(this.PriceMax, Chart_ID)),
               Width(this.GetDataWidth(Chart_ID)),
               Height(this.GetDataHeight(Chart_ID))
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
    double high = 0;
    double low = ::DBL_MAX;
    double PriceHigh = 0;
    double PriceLow = 0;

    for (int X = 0; (X < this.Width) && (Pos < this.Amount); X++)
    {
      const ulong NextTime = (X + 1) * this.TimeWidth / this.Width + this.TimeFrom;

      while (Pos < this.Amount)
      {
        const TICK Tick = this.Ticks[Pos];

        if (this.Ticks[Pos].time > (long)NextTime)
          break;

        PriceLow = (PriceType == ::ASK) ? this.Ticks[Pos].ask : this.Ticks[Pos].bid;
        PriceHigh = (PriceType == ::BID) ? this.Ticks[Pos].bid : this.Ticks[Pos].ask;

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