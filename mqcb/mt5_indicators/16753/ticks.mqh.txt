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

#include "Tick.mqh"

class TICKS
{
private:
  TICK Ticks[];
  int Amount;

  ulong From;
  ulong To;

  ulong NowTime;
  ulong LastNewTickTime;
  ulong LastNewTickTimeOriginal;

  double Min;
  double Max;

  long LastTime; // time_msc-время последнего тика (самого свежего), полученного из истории
  int Count;     // Количество тиков в последенем запросе, у которых time_msc == LastTime

  // Возвращает свежие тики, пришедшие после предыдущего вызова
  int GetFreshTicks( MqlTick &tTicks[], const uint flags = COPY_TICKS_ALL, const uint count = 100000 )
  {
    int Res = 0;

    MqlTick NewTicks[];
    const int NewAmount = ::CopyTicks(this.Symb, NewTicks, flags, this.LastTime, count);

    if ((NewAmount > 0) && (this.Count < NewAmount))
    {
      Res = ::ArrayCopy(tTicks, NewTicks, 0, this.Count);

      // Взяли крайнее время из текущей истории
      this.LastTime = NewTicks[NewAmount - 1].time_msc;
      this.Count = 1;

      // Находим (Count) в текущей истории количество тиков со временем LastTime
      for (int i = NewAmount - 2; i >= 0; i--)
      {
        if (NewTicks[i].time_msc < this.LastTime)
          break;

        this.Count++;
      }
    }

    return(Res);
  }

  void AddLastData( void )
  {
    if (this.Amount > 0)
    {
      if ((this.To >= this.NowTime))
      {
        this.Ticks[this.Amount] = this.Ticks[this.Amount - 1];
        this.Ticks[this.Amount].time = (long)this.NowTime;

        this.Amount++;
      }
      else if ((long)this.To > this.Ticks[this.Amount - 1].time)
      {
        this.Ticks[this.Amount] = this.Ticks[this.Amount - 1];
        this.Ticks[this.Amount].time = (long)this.To;

        this.Amount++;
      }
    }

    return;
  }

  ulong GetOriginalLastTime( void ) const
  {
    MqlTick Tick;

    ::SymbolInfoTick(this.Symb, Tick);

    return(Tick.time_msc);
  }

public:
  const string Symb;

  ulong GetFrom( void ) const
  {
    return(this.From);
  }

  ulong GetTo( void ) const
  {
    return(this.To);
  }

  ulong GetNowTime( void )
  {
    const ulong NewTimeOriginal = this.GetOriginalLastTime();

    const ulong NewLastNewTickTime = ::GetMicrosecondCount();
    const ulong NewTime = this.LastNewTickTimeOriginal + (NewLastNewTickTime - this.LastNewTickTime) / THOUSAND;

    if (NewTimeOriginal >= NewTime)
    {
      this.NowTime = NewTimeOriginal;

      this.LastNewTickTimeOriginal = NewTimeOriginal;
      this.LastNewTickTime = NewLastNewTickTime;
    }
    else
      this.NowTime = NewTime;

    return(this.NowTime);
  }

  void Init( const ulong uFrom, const ulong uTo )
  {
    this.Min = DBL_MAX;
    this.Max = -DBL_MAX;

    this.GetNowTime();

    this.Amount = 0;

    this.From = uFrom;
    this.To = uTo;

    this.LastTime = (long)this.From;
    this.Count = 0;


    MqlTick NewTicks[];
    TICK Tick;

    int AmountTicks = 1;

    while (AmountTicks > 0)
    {
      AmountTicks = this.GetFreshTicks(NewTicks, COPY_TICKS_INFO, (uint)MathMax((this.To - this.LastTime) >> 5, 2000)); // ~2000 ticks/minute

      ::ArrayResize(this.Ticks, this.Amount + AmountTicks + 1);

      for (int i = 0; i < AmountTicks; i++)
      {
        const MqlTick TmpTick = NewTicks[i];

        if (TmpTick.time_msc > (long)this.To)
        {
          AmountTicks = 0;

          break;
        }
        else
        {
          Tick.time = TmpTick.time_msc;

          if (TmpTick.bid != 0)
            Tick.bid = TmpTick.bid;

          if (TmpTick.ask != 0)
            Tick.ask = TmpTick.ask;

          if (Tick > 0)
          {
            this.Ticks[this.Amount] = Tick;

            const double TmpMin = Tick.GetMin();
            const double TmpMax = Tick.GetMax();

            if (TmpMin < this.Min)
              this.Min = TmpMin;

            if (TmpMax > this.Max)
              this.Max = TmpMax;

            this.Amount++;
          }
        }
      }
    }

    this.AddLastData();

    this.Amount = ::ArrayResize(this.Ticks, this.Amount);

    return;
  }

  TICKS( const string sSymb ) : Amount(0), Symb(sSymb), From(0), To(0),
                                LastNewTickTimeOriginal(this.GetOriginalLastTime()), LastNewTickTime(::GetMicrosecondCount())
  {
  }

  const TICK operator []( const int Pos ) const
  {
    return(this.Ticks[Pos]);
  }

  int GetAmount( void ) const
  {
    return(this.Amount);
  }

  double GetMax( void ) const
  {
    return(this.Max);
  }

  double GetMin( void ) const
  {
    return(this.Min);
  }

  const TICK GetTick( const long lTime ) const
  {
    TICK Res;

    for (int i = this.Amount - 1; i >= 0; i--)
      if (this.Ticks[i].time <= lTime)
      {
        Res = this.Ticks[i];

        break;
      }

    return(Res);
  }

  ulong GetTime( void ) const
  {
    return((this.From + this.To) >> 1);
  }

  int GetInterval( void ) const
  {
    return((int)(this.To - this.From));
  }

  string ToString( void ) const
  {
    string Str = "";

    for (int i = 0; i < this.Amount; i++)
      Str += "\n" + this.Ticks[i].ToString();

    return(Str);
  }
};