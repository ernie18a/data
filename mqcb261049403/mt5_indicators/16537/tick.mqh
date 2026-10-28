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
    return(::TimeToString(this.time / THOUSAND, ::TIME_SECONDS) + " " + (string)(this.time % THOUSAND) + " ms. " +
           " bid = " + (string)this.bid + " ask = " + (string)this.ask);
  }
};