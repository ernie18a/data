#property strict

#ifdef __MQL4__
  #define COPY_TICKS_ALL -1
  #define COPY_TICKS_INFO 1
  #define COPY_TICKS_TRADE 2

  int CopyTicks( const string symbol_name, MqlTick &ticks_array[], const uint flags = COPY_TICKS_ALL, const ulong from = 0, const uint count = 0)
  {
    return(0);
  }
#endif

#ifdef __MQL5__
  #ifndef FALSE
    #define FALSE false
  #endif

  #ifndef TRUE
    #define TRUE true
  #endif
#endif

#include "Bar.mqh"
#include "..\..\Pointer.mqh"

class BARS
{
private:
  BAR* bars[];
  int Amount;
  const string Symb;

  void GetNextTicks( MqlTick &Ticks[], int &AmountTicks )
  {
    if (AmountTicks > 0)
      AmountTicks = ::CopyTicks(this.Symb, Ticks, ::COPY_TICKS_INFO, Ticks[AmountTicks - 1].time_msc + 1); // так могут быть потери тиков

    return;
  }

  void SkipTicks( MqlTick &Ticks[], int &AmountTicks, int &Pos, TICK &TmpTick, const datetime EndTime, BAR* &Bar, const bool SaveFlag = FALSE )
  {
    int Count = 0;

    TICK NewTmpTick = TmpTick;

    while (Pos < AmountTicks)
    {
      const MqlTick Tick = Ticks[Pos];

      if (Tick.time >= EndTime)
      {
        if (SaveFlag)
          Bar.AddData(TmpTick, Ticks, Pos - Count, Count);
        else
          Bar = new BAR(EndTime);

        break;
      }

      if (Tick.bid != 0)
        NewTmpTick.bid = Tick.bid;

      if (Tick.ask != 0)
        NewTmpTick.ask = Tick.ask;

      Count++;

      Pos++;

      if (Pos == AmountTicks)
      {
        if (SaveFlag)
          Bar.AddData(TmpTick, Ticks, Pos - Count, Count);

        GetNextTicks(Ticks, AmountTicks);

        Pos = 0;
        Count = 0;
      }
    }

    TmpTick = NewTmpTick;

    return;
  }

public:
  BARS( const long Chart_ID = 0 ) : Symb(::ChartSymbol(Chart_ID))
  {
    this.Amount = (int)::ChartGetInteger(Chart_ID, ::CHART_VISIBLE_BARS);
    int FirstBar = (int)::ChartGetInteger(Chart_ID, ::CHART_FIRST_VISIBLE_BAR) - this.Amount;

    if (FirstBar < 0)
      FirstBar = 0;
    else
      this.Amount++;

    const ENUM_TIMEFRAMES period = ::ChartPeriod(Chart_ID);

    datetime Times[];

    const int PrevAmount = this.Amount;

    this.Amount = ::CopyTime(this.Symb, period, FirstBar, this.Amount, Times);

    if (Amount > 0)
    {
      MqlTick Ticks[]; // Массив должен быть динамическим

      int AmountTicks = 1;

      ::ArrayResize(Ticks, AmountTicks);

      Ticks[0].time_msc = (long)(Times[0] * THOUSAND - 1);

      GetNextTicks(Ticks, AmountTicks);

      if (AmountTicks > 0)
        this.Amount = ::ArrayResize(this.bars, this.Amount);
      else
        this.Amount = 0;

      const int PeriodSec = ::PeriodSeconds(period);

      int Pos = 0;

      TICK TmpTick;

      for (int i = 0; i < this.Amount; i++)
      {
        SkipTicks(Ticks, AmountTicks, Pos, TmpTick, Times[i], this.bars[i], FALSE);
        SkipTicks(Ticks, AmountTicks, Pos, TmpTick, Times[i] + PeriodSec, this.bars[i], TRUE);

        if (AmountTicks <= 0)
        {
          this.Amount = ::ArrayResize(this.bars, i + 1);

          break;
        }
      }
    }
  }

  ~BARS( void )
  {
    POINTER::DeleteObject(this.bars);
  }

  int GetAmount( void ) const
  {
    return(this.Amount);
  }

  const BAR* operator []( const int Pos ) const
  {
    return(this.bars[Pos]);
  }

  const BAR* operator []( const datetime time ) const
  {
    BAR* Res = NULL;

    if (this.Amount > 0)
    {
      int i;

      for (i = 0; i < this.Amount; i++)
        if (this.bars[i].time >= time)
          break;

      Res = (i == this.Amount) ? this.bars[i - 1] : this.bars[i];
    }

    return(Res);
  }

  double GetMax( void ) const
  {
    double Res = ::DBL_MIN;

    for (int i = 0; i < this.Amount; i++)
    {
      const double Tmp = this.bars[i].GetMax();

      if (Tmp > Res)
        Res = Tmp;
    }

    return(Res);
  }

  double GetMin( void ) const
  {
    double Res = ::DBL_MAX;

    for (int i = 0; i < this.Amount; i++)
    {
      const double Tmp = this.bars[i].GetMin();

      if (Tmp < Res)
        Res = Tmp;
    }

    return(Res);
  }

  int GetAmountTicks( void ) const
  {
    int Sum = 0;

    for (int i = 0; i < this.Amount; i++)
      Sum += this.bars[i].GetAmount();

    return(Sum);
  }
};