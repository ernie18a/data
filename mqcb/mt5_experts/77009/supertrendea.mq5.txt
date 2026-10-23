//+------------------------------------------------------------------+
//|                                                 SuperTrendEA.mq5 |
//|                                 Copyright 2026, Mykyta Samoiliuk |
//|                                                     www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Mykyta Samoiliuk"
#property link        "https://www.mql5.com"
#property version     "1.00"
#property description "Trades the SuperTrendTV indicator through iCustom."
#property description "Acts on closed bars only, so a signal cannot appear and then vanish."
#property description "Writes every decision to a log that audit_trades.py checks against the indicator."

#include <Trade\Trade.mqh>
//--- The indicator is compiled into the expert, so it runs anywhere the expert
//--- runs and needs nothing installed alongside it. Editing SuperTrendTV.mq5
//--- therefore requires recompiling this file as well.
#resource "\\Indicators\\SuperTrendTV.ex5"
#define INDICATOR_PATH "::Indicators\\SuperTrendTV.ex5"
//--- input parameters
input int    InpPeriod=10;                          // ATR period
input double InpFactor=3.0;                         // Factor
input double InpLots=0.10;                          // Lot size
input int    InpStopBufferPoints=0;                 // Extra points beyond the line
input ulong  InpMagic=20260905;                     // Magic number
input ulong  InpSlippage=30;                        // Slippage in points
input bool   InpWriteLog=true;                      // Write decision log
input string InpLogName="supertrend_ea_log.csv";    // Log file (common folder)

CTrade   ExtTrade;
int      ExtHandle=INVALID_HANDLE;
int      ExtLog=INVALID_HANDLE;
datetime ExtLastBar=0;
double   ExtLots=0.10;   // InpLots after correction
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ExtHandle=iCustom(_Symbol,_Period,INDICATOR_PATH,InpPeriod,InpFactor);
   if(ExtHandle==INVALID_HANDLE)
     {
      PrintFormat("Cannot create the indicator, error %d",GetLastError());
      return(INIT_FAILED);
     }
//--- A lot the symbol does not accept gives a stream of rejected orders. It is
//--- corrected here rather than refused, the way the standard examples handle a bad
//--- input, because refusing to start is a heavier answer than the mistake deserves.
//--- The limits are only trusted when the terminal actually reports them: on a symbol
//--- that is not ready yet they come back as zeroes.
   ExtLots=InpLots;
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double vstep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(vmin>0.0 && vmax>0.0)
     {
      if(vstep>0.0)
         ExtLots=MathRound(ExtLots/vstep)*vstep;
      ExtLots=MathMax(vmin,MathMin(vmax,ExtLots));
      if(MathAbs(ExtLots-InpLots)>0.0000001)
         PrintFormat("Incorrect input parameter InpLots = %.4f. Expert will use value %.4f.",
                     InpLots,ExtLots);
     }

   ExtTrade.SetExpertMagicNumber(InpMagic);
   ExtTrade.SetDeviationInPoints(InpSlippage);
   ExtTrade.SetTypeFillingBySymbol(_Symbol);
//--- The log records the indicator value on every closed bar, not only the flips.
//--- That way the audit compares trades against the very series this run consumed,
//--- instead of against an export taken from somewhere else, where the bar set can
//--- differ and half the signals turn into phantoms.
   if(InpWriteLog)
     {
      ExtLog=FileOpen(InpLogName,FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON,',');
      if(ExtLog==INVALID_HANDLE)
         PrintFormat("Cannot open %s for writing, error %d. Running without a log.",
                     InpLogName,GetLastError());
      else
         FileWrite(ExtLog,"bar_time","direction","line","action","price","stop","ticket");
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ExtLog!=INVALID_HANDLE)
     {
      FileClose(ExtLog);
      ExtLog=INVALID_HANDLE;
     }
   if(ExtHandle!=INVALID_HANDLE)
      IndicatorRelease(ExtHandle);
  }
//+------------------------------------------------------------------+
//| Our position on this symbol, or -1                               |
//+------------------------------------------------------------------+
int OurPositionType()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
         PositionGetInteger(POSITION_MAGIC)==(long)InpMagic)
         return((int)PositionGetInteger(POSITION_TYPE));
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//| Close our position, false if the server refused                  |
//+------------------------------------------------------------------+
bool CloseOurPosition()
  {
   bool all_closed=true;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
         PositionGetInteger(POSITION_MAGIC)==(long)InpMagic)
         if(!ExtTrade.PositionClose(ticket))
           {
            PrintFormat("Close of #%I64u refused, retcode %d, %s",ticket,
                        ExtTrade.ResultRetcode(),ExtTrade.ResultRetcodeDescription());
            all_closed=false;
           }
     }
   return(all_closed);
  }
//+------------------------------------------------------------------+
//| Smallest stop distance the server will accept                    |
//+------------------------------------------------------------------+
double MinStopDistance()
  {
//--- Both limits matter, and a stop exactly on the boundary still gets refused
//--- once the spread widens, so the spread and a couple of points are added.
   long   stops=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long   freeze=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   double limit=(double)MathMax(stops,freeze)*_Point;
   double spread=SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SymbolInfoDouble(_Symbol,SYMBOL_BID);
   return(MathMax(limit,MathMax(spread,0.0))+2*_Point);
  }
//+------------------------------------------------------------------+
//| Volume the free margin can actually pay for, 0 when none fits    |
//+------------------------------------------------------------------+
double AffordableVolume(ENUM_ORDER_TYPE type,double price,double wanted)
  {
//--- An expert that keeps firing orders it cannot pay for fills the journal with
//--- "not enough money" instead of trading. The size is reduced to what the account
//--- covers, and when even the smallest allowed lot does not fit, the signal is skipped.
   double margin=0.0;
   double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(!OrderCalcMargin(type,_Symbol,wanted,price,margin))
      return(0.0);
   if(margin<=free)
      return(wanted);

   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vstep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(margin<=0.0 || vmin<=0.0 || vstep<=0.0 || free<=0.0)
      return(0.0);

   double scaled=MathFloor((wanted*free/margin)/vstep)*vstep;
   if(scaled<vmin)
      return(0.0);
   if(!OrderCalcMargin(type,_Symbol,scaled,price,margin) || margin>free)
      return(0.0);
   return(scaled);
  }
//+------------------------------------------------------------------+
//| Push the stop away if it sits closer than the broker allows      |
//+------------------------------------------------------------------+
double StopWithinLimits(double price,double stop,bool is_buy)
  {
   double minimum=MinStopDistance();
   if(is_buy && price-stop<minimum)
      stop=price-minimum;
   if(!is_buy && stop-price<minimum)
      stop=price+minimum;
   return(NormalizeDouble(stop,_Digits));
  }
//+------------------------------------------------------------------+
//| One line into the decision log                                   |
//+------------------------------------------------------------------+
void LogRow(datetime bar_time,int direction,double line,string action,
            double price,double stop,ulong ticket)
  {
   if(ExtLog==INVALID_HANDLE)
      return;
   FileWrite(ExtLog,TimeToString(bar_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             IntegerToString(direction),DoubleToString(line,_Digits),action,
             DoubleToString(price,_Digits),DoubleToString(stop,_Digits),
             IntegerToString((int)ticket));
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- work once per finished bar. Reading the forming bar is the classic way to
//--- get a signal that shows up on the chart and disappears before the close.
   datetime bar_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   if(bar_time==ExtLastBar)
      return;

   double dir[],line[];
   ArraySetAsSeries(dir,true);
   ArraySetAsSeries(line,true);
//--- start at 1, so element 0 is the bar that has just closed and 1 is the one before it
   if(CopyBuffer(ExtHandle,2,1,2,dir)!=2 || CopyBuffer(ExtHandle,0,1,2,line)!=2)
      return;                                   // indicator not ready yet, try next tick

   ExtLastBar=bar_time;

   datetime signal_bar=(datetime)iTime(_Symbol,_Period,1);
   int      new_dir=(int)dir[0];
   int      prev_dir=(int)dir[1];
//--- every closed bar is recorded, flip or not, so the audit sees the same series
   LogRow(signal_bar,new_dir,line[0],"bar",0.0,0.0,0);

   if(new_dir==0 || prev_dir==0 || new_dir==prev_dir)
      return;                                   // warm-up or no flip on the closed bar

   int have=OurPositionType();
   if(have!=-1)
     {
      double exit_price=SymbolInfoDouble(_Symbol,have==POSITION_TYPE_BUY ? SYMBOL_BID : SYMBOL_ASK);
      //--- opening the reverse trade over a position that is still open would break
      //--- the one position rule, so a refused close ends the bar right here
      if(!CloseOurPosition())
        {
         LogRow(signal_bar,new_dir,line[0],"close_failed",exit_price,0.0,0);
         return;
        }
      LogRow(signal_bar,new_dir,line[0],"close",exit_price,0.0,0);
     }
//--- direction is -1 while the trend is up, exactly as in TradingView
   double stop=line[0];
   if(InpStopBufferPoints>0)
     {
      double shift=InpStopBufferPoints*_Point;
      stop+=(new_dir==-1) ? -shift : shift;
     }

   bool   buying=(new_dir==-1);
   double price=SymbolInfoDouble(_Symbol,buying ? SYMBOL_ASK : SYMBOL_BID);
//--- The line is computed on the close of the finished bar while the entry happens
//--- at the next price. If price has already travelled past the line, the stop would
//--- land on the wrong side of the entry, and the setup that produced the signal no
//--- longer exists. Nudging the stop to the other side would open a trade that is one
//--- point from being stopped out, so the signal is dropped instead.
   if((buying && stop>=price) || (!buying && stop<=price))
     {
      LogRow(signal_bar,new_dir,line[0],"stale",price,stop,0);
      PrintFormat("Signal dropped, the line %.*f is already past the price %.*f",
                  _Digits,stop,_Digits,price);
      return;
     }
   stop=StopWithinLimits(price,stop,buying);
//--- nothing is sent unless the account can pay for it
   double volume=AffordableVolume(buying ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,price,ExtLots);
   if(volume<=0.0)
     {
      LogRow(signal_bar,new_dir,line[0],"no_margin",price,stop,0);
      PrintFormat("Signal dropped, free margin %.2f does not cover %.2f lots",
                  AccountInfoDouble(ACCOUNT_MARGIN_FREE),ExtLots);
      return;
     }

   bool ok=buying ? ExtTrade.Buy(volume,_Symbol,price,stop,0.0,"SuperTrendTV up")
          : ExtTrade.Sell(volume,_Symbol,price,stop,0.0,"SuperTrendTV down");

   LogRow(signal_bar,new_dir,line[0],ok ? (buying ? "buy" : "sell") : "failed",
          price,stop,ok ? ExtTrade.ResultOrder() : 0);
   if(!ok)
      PrintFormat("Order failed, retcode %d, %s",ExtTrade.ResultRetcode(),
                  ExtTrade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------+
