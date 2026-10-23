#include <Symbol.mqh>  // https://www.mql5.com/ru/code/18855

#include "Casting.mqh" // https://www.mql5.com/ru/code/16280
#include "Data.mqh"

class RATES : public DATA<MqlRates>
{
private:
  static datetime TickToRates( const MqlTick &Tick, MqlRates &Rates, const bool Init = false )
  {
    if (Init)
    {
      Rates.time = Tick.time - (Tick.time % 60);

      Rates.open = Tick.bid;
      Rates.high = Rates.open;
      Rates.low = Rates.open;
      Rates.close = Rates.open;

      Rates.tick_volume = 1;
      Rates.spread = 0;

      Rates.real_volume = _C(long, Tick.ask);
    }
    else
    {
      if (Tick.bid > Rates.high)
        Rates.high = Tick.bid;
      else if (Tick.bid < Rates.low)
        Rates.low = Tick.bid;

      Rates.close = Tick.bid;

      if (Tick.ask < _C(double, Rates.real_volume))
        Rates.real_volume = _C(long, Tick.ask);

      Rates.tick_volume++;
    }

    return(Rates.time);
  }

public:
  const double point;

  RATES( const int digits ) : point(::MathPow(10, -digits))
  {
  }

  uint Add( const MqlTick &Ticks[] )
  {
    int Res = 0;

    this.Clear();

    const int Size = ::ArraySize(Ticks);

    if (Size)
    {
      this.SetReserve((int)(Ticks[Size - 1].time - Ticks[0].time) / PeriodSeconds(PERIOD_M1) + 1);

      MqlRates Rates;

      int NowTime = (int)(RATES::TickToRates(Ticks[0], Rates, true) / 60);

      for (int i = 1; _CS(i < Size); i++)
        if (NowTime != Ticks[i].time / 60)
        {
          if (Ticks[i].time / 60 - NowTime > 60) // Разрыв в котирах больше часа
            Rates.spread = (int)((_C(double, Rates.real_volume) - Rates.low) / this.point + 0.1);
          else
            Rates.spread = (int)((::MathMax(::MathMin(_C(double, Rates.real_volume), Ticks[i].ask), Rates.low) - Rates.low) / this.point + 0.1);

          Rates.real_volume = 0;

          this.Add(Rates);

          NowTime = (int)(TickToRates(Ticks[i], Rates, true) / 60);
        }
        else
          RATES::TickToRates(Ticks[i], Rates);

      Rates.spread = (int)((_C(double, Rates.real_volume) - Rates.low) / this.point + 0.1);
      Rates.real_volume = 0;

      this.Add(Rates);
    }

    return(this.GetAmount());
  }

  int ToSymbol( const SYMBOL* const CustomSymbol ) const
  {
    return(CustomSymbol.CloneRates(this.Data));
  }
};