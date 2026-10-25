#property strict

#include "Tick.mqh"

class BAR
{
private:
  TICK Ticks[];
  int Amount;

  void Add( const TICK &Tick )
  {
    this.Ticks[this.Amount] = Tick;

    this.Amount++;

    return;
  }

public:
  void AddData( TICK &TmpTick, const MqlTick &Source[], int Pos, const int iAmount )
  {
    const int Size = (this.Amount == 0) ? ::ArrayResize(this.Ticks, iAmount + 1) : ::ArrayResize(this.Ticks, iAmount + this.Amount);

    if ((this.Amount == 0) && (Size > 0) && (TmpTick > 0))
      if ((iAmount > 0) && (Source[Pos].time_msc > this.time * THOUSAND))
      {
        TmpTick.time = this.time * THOUSAND;

        this.Add(TmpTick);
      }

    for (int i = 0; (i < iAmount) && (this.Amount < Size); i++)
    {
      const MqlTick Tick = Source[Pos];

      if ((Tick.bid != 0) || (Tick.ask != 0))
      {
        const TICK NewTmpTick((Tick.bid == 0) ? TmpTick.bid : Tick.bid, (Tick.ask == 0) ? TmpTick.ask : Tick.ask);

        if ((NewTmpTick != TmpTick) && (NewTmpTick > 0))
        {
          TmpTick = NewTmpTick;
          TmpTick.time = Tick.time_msc;

          this.Add(TmpTick);
        }
      }

      Pos++;
    }

    this.Amount = ::ArrayResize(this.Ticks, this.Amount);
  }

  const datetime time;

  BAR( const datetime dTime ) : time(dTime), Amount(0)
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
    double Res = ::DBL_MIN;

    for (int i = 0; i < this.Amount; i++)
    {
      const TICK Tick = this.Ticks[i];

      if (Tick.ask > Res)
        Res = Tick.ask;

      if (Tick.bid > Res)
        Res = Tick.bid;
    }

    return(Res);
  }

  double GetMin( void ) const
  {
    double Res = ::DBL_MAX;

    for (int i = 0; i < this.Amount; i++)
    {
      const TICK Tick = this.Ticks[i];

      if (Tick.bid < Res)
        Res = Tick.bid;

      if (Tick.ask < Res)
        Res = Tick.ask;
    }

    return(Res);
  }

  string ToString( void ) const
  {
    string Str = (string)this.time;

    for (int i = 0; i < this.Amount; i++)
      Str += "\n" + this.Ticks[i].ToString();

    return(Str);
  }
};