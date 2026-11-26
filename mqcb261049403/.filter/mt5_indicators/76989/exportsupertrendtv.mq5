//+------------------------------------------------------------------+
//|                                           ExportSuperTrendTV.mq5 |
//|                                 Copyright 2026, Mykyta Samoiliuk |
//|                                                     www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Mykyta Samoiliuk"
#property link        "https://www.mql5.com"
#property version     "1.00"
#property description "Writes OHLC together with SuperTrendTV output to a CSV file,"
#property description "so the Pine reference can be recomputed from the very same bars."
#property script_show_inputs
//--- input parameters
input string          InpSymbol="";                    // Symbol (empty = current)
input ENUM_TIMEFRAMES InpTimeframe=PERIOD_CURRENT;     // Timeframe
input int             InpBars=0;                       // Bars (0 = all history)
input int             InpPeriod=10;                    // ATR period
input double          InpFactor=3.0;                   // Factor
input string          InpFileName="supertrend_mt5.csv";// File name
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string symbol=(InpSymbol=="") ? _Symbol : InpSymbol;
   ENUM_TIMEFRAMES timeframe=(InpTimeframe==PERIOD_CURRENT) ? _Period : InpTimeframe;
//--- the indicator must be compiled and sit in MQL5\Indicators
   int handle=iCustom(symbol,timeframe,"SuperTrendTV",InpPeriod,InpFactor);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Cannot create SuperTrendTV, error %d. Is it compiled?",GetLastError());
      return;
     }
//--- how much history we actually have
   int available=Bars(symbol,timeframe);
   if(available<InpPeriod+2)
     {
      PrintFormat("%s %s: only %d bars available",symbol,EnumToString(timeframe),available);
      IndicatorRelease(handle);
      return;
     }
   int wanted=(InpBars<=0) ? available : MathMin(InpBars,available);
//--- the indicator is calculated asynchronously, without this wait the copy
//--- below quietly comes back short
   int ready=0;
   for(int attempt=0; attempt<200 && !IsStopped(); attempt++)
     {
      ready=BarsCalculated(handle);
      if(ready>=wanted)
         break;
      Sleep(50);
     }
   if(ready<wanted)
     {
      PrintFormat("Only %d of %d bars calculated, aborting",ready,wanted);
      IndicatorRelease(handle);
      return;
     }
//--- index 0 must be the oldest bar, same order the reference walks
   MqlRates rates[];
   double super_trend[],direction[],atr[];
   ArraySetAsSeries(rates,false);
   ArraySetAsSeries(super_trend,false);
   ArraySetAsSeries(direction,false);
   ArraySetAsSeries(atr,false);

   if(CopyRates(symbol,timeframe,0,wanted,rates)!=wanted ||
      CopyBuffer(handle,0,0,wanted,super_trend)!=wanted ||
      CopyBuffer(handle,2,0,wanted,direction)!=wanted ||
      CopyBuffer(handle,3,0,wanted,atr)!=wanted)
     {
      PrintFormat("Copying failed, error %d",GetLastError());
      IndicatorRelease(handle);
      return;
     }
//--- write the file
   int file=FileOpen(InpFileName,FILE_WRITE|FILE_CSV|FILE_ANSI,',');
   if(file==INVALID_HANDLE)
     {
      PrintFormat("Cannot open %s for writing, error %d",InpFileName,GetLastError());
      IndicatorRelease(handle);
      return;
     }
//--- digits of the exported symbol, not of the chart this script runs on
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   if(digits<=0)
      digits=_Digits;

   FileWrite(file,"time","open","high","low","close","atr","supertrend","direction");

   int written=0;
   for(int i=0; i<wanted-1 && !IsStopped(); i++)   // the last bar is still forming
     {
      bool ready_bar=(super_trend[i]!=EMPTY_VALUE);
      FileWrite(file,
                TimeToString(rates[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                DoubleToString(rates[i].open,digits),
                DoubleToString(rates[i].high,digits),
                DoubleToString(rates[i].low,digits),
                DoubleToString(rates[i].close,digits),
                ready_bar ? DoubleToString(atr[i],10) : "",
                ready_bar ? DoubleToString(super_trend[i],10) : "",
                ready_bar ? DoubleToString(direction[i],0) : "");
      written++;
     }
   FileClose(file);
   IndicatorRelease(handle);
//---
   PrintFormat("%d bars of %s %s written to MQL5\\Files\\%s",
               written,symbol,EnumToString(timeframe),InpFileName);
   if(InpBars>0 && InpBars<available)
      Print("Partial export: the reference seeds its ATR at the first exported bar, use verify.py --skip");
  }
//+------------------------------------------------------------------+
