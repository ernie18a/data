#property strict

#define THOUSAND 1000

struct TICK
{
  double bid;
  double ask;

  long time;

  TICK( const double dBid = 0, const double dAsk = 0 ) : bid(dBid), ask(dAsk), time(0)
  {
  }

  double GetMin( void ) const
  {
    return(::MathMin(this.bid, this.ask));
  }

  double GetMax( void ) const
  {
    return(::MathMax(this.bid, this.ask));
  }

  bool operator >( const double Price ) const
  {
    return((this.bid > Price) && (this.ask > Price));
  }

  bool operator !=( const TICK &Tick ) const
  {
    return((this.bid != Tick.bid) || (this.ask != Tick.ask));
  }

  string ToString( void ) const
  {
    return(::TimeToString(this.time / THOUSAND, TIME_DATE | TIME_SECONDS) + "." + ::IntegerToString(this.time % THOUSAND, 3, '0') +
           " bid = " + (string)this.bid + " ask = " + (string)this.ask);
  }
};