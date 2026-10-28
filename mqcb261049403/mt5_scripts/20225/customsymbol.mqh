//#include "String.mqh"
#include "Ticks.mqh"

class CUSTOMSYMBOL : public SYMBOL
{
private:
  TICKS Ticks;

public:
  CUSTOMSYMBOL( const string Symb = NULL, const string Path = NULL ) : SYMBOL(Symb, Path)
  {
  }

  uint AddTicks( const MqlTick &TicksArray[] )
  {
    return(this.Ticks.Add(TicksArray));
  }

  uint AddTicks( const string &Str[] )
  {
    return(this.Ticks.Add(Str));
  }

  uint AddTicks( const uchar &Bytes[], const uint StartPos = 0, const int Reserve = 0 )
  {
/*    string Str[];

    STRING::BytesToStrings(Bytes, Str);

    return(this.AddTicks(Str)); */

    this.Ticks.SetReserve(Reserve);

    return(this.Ticks.Add(Bytes, StartPos));
  }

  uint AddTicks( const string FileName, const uint StartPos = 0  )
  {
    uchar Bytes[];

    ::FileLoad(FileName, Bytes);

    return(this.AddTicks(Bytes, StartPos));
  }

  int CreateHistoryTicks( void )
  {
    ::Print("Correcting Ticks...");
    const int Errors = this.Ticks.Correct();

    if (Errors)
      ::Print("Corrected " + (string)Errors + " ticks.");

    ::Print("Calculating Digits...");
    this.SetProperty(SYMBOL_DIGITS, this.Ticks.GetDigits());

    this.SetProperty(SYMBOL_TRADE_CONTRACT_SIZE, ::MathPow(10, this.GetProperty(SYMBOL_DIGITS)));
    this.SetProperty(SYMBOL_TRADE_TICK_VALUE, 1);
    this.SetProperty(SYMBOL_TRADE_TICK_SIZE, this.GetProperty(SYMBOL_POINT));

    const string Currency = ::AccountInfoString(ACCOUNT_CURRENCY);

    this.SetProperty(SYMBOL_CURRENCY_PROFIT, Currency);
    this.SetProperty(SYMBOL_CURRENCY_MARGIN, Currency);
    this.SetProperty(SYMBOL_CURRENCY_BASE, Currency);


    ::Print("Saving Ticks...");
    const int Res = this.Ticks.ToSymbol(&this);
    ::Print("Saved ticks = " + (string)Res);

    return(Res);
  }

  int CreateHistoryRates( void ) const
  {
    RATES Rates((int)this.GetProperty(SYMBOL_DIGITS));

    ::Print("Generating Rates...");
    ::Print("Generated Rates = " + (string)this.Ticks.ToRates(&Rates));

    ::Print("Saving Rates...");
    const int Res = Rates.ToSymbol(&this);
    ::Print("Saved Rates = " + (string)Res);

    return(Res);
  }

  int DataToSymbol( void )
  {
    const int Res = this.CreateHistoryTicks();

    this.CreateHistoryRates();

    return(Res);
  }
};