//+------------------------------------------------------------------+
//|                                                i_Indexer_USD.mq5 |
//|                                           Copyright 2013, Silent |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Silent"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   1
//--- plot lUSD
#property indicator_label1  "USD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- inputs
input int      countBars=216; // bars for calculation
//--- puts
int i;
string   ShortName;
bool bad,success;
//--- indicator buffers
double   USDBufferPlot[];
//--- buffers
double   EURUSD[],GBPUSD[],USDCHF[],USDJPY[],AUDUSD[],USDCAD[],NZDUSD[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,USDBufferPlot,INDICATOR_DATA);
   SetIndexBuffer(1,EURUSD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,GBPUSD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,USDCHF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,USDJPY,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,AUDUSD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,USDCAD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,NZDUSD,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(USDBufferPlot,true);
   ArraySetAsSeries(EURUSD,true);
   ArraySetAsSeries(GBPUSD,true);
   ArraySetAsSeries(USDCHF,true);
   ArraySetAsSeries(USDJPY,true);
   ArraySetAsSeries(AUDUSD,true);
   ArraySetAsSeries(USDCAD,true);
   ArraySetAsSeries(NZDUSD,true);
//---
   copied();
   EventSetTimer(1);
   StringConcatenate(ShortName,"i_Indexer_USD ",_Symbol);
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);
   IndicatorSetInteger(INDICATOR_DIGITS,6);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-countBars+1);
//---
   if(prev_calculated==0)
     {
      ArrayInitialize(USDBufferPlot,EMPTY_VALUE);
      ArrayInitialize(EURUSD,EMPTY_VALUE);
      ArrayInitialize(GBPUSD,EMPTY_VALUE);
      ArrayInitialize(USDCHF,EMPTY_VALUE);
      ArrayInitialize(USDJPY,EMPTY_VALUE);
      ArrayInitialize(AUDUSD,EMPTY_VALUE);
      ArrayInitialize(USDCAD,EMPTY_VALUE);
      ArrayInitialize(NZDUSD,EMPTY_VALUE);
      if(!copied() || !_LastError) {success=false; return(prev_calculated);}
      if(copied()  &&  _LastError) {countBuf(); success=true;}
     }
//---
   if(rates_total-prev_calculated!=0)
     {
      if(!copied() || !_LastError) {success=false; return(prev_calculated);}
      if(copied()  &&  _LastError) {countBuf(); success=true;}
     }
//---
   if(!_LastError || success==false)
     {
      copied(); ResetLastError(); return(rates_total);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(copied() && _LastError && success==true) countBuf(); ChartRedraw();
  }
//+------------------------------------------------------------------+
//| deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {EventKillTimer(); ChartRedraw();}
//+------------------------------------------------------------------+
//| copying                                                          |
//+------------------------------------------------------------------+
bool copied()
  {
   if(!CopyClose("EURUSD",_Period,0,countBars,EURUSD) || 
      !CopyClose("GBPUSD",_Period,0,countBars,GBPUSD) || 
      !CopyClose("USDCHF",_Period,0,countBars,USDCHF) || 
      !CopyClose("USDJPY",_Period,0,countBars,USDJPY) || 
      !CopyClose("AUDUSD",_Period,0,countBars,AUDUSD) || 
      !CopyClose("USDCAD",_Period,0,countBars,USDCAD) || 
      !CopyClose("NZDUSD",_Period,0,countBars,NZDUSD))
      bad=false;
   if(CopyClose("EURUSD",_Period,0,countBars,EURUSD) && 
      CopyClose("GBPUSD",_Period,0,countBars,GBPUSD) && 
      CopyClose("USDCHF",_Period,0,countBars,USDCHF) && 
      CopyClose("USDJPY",_Period,0,countBars,USDJPY) && 
      CopyClose("AUDUSD",_Period,0,countBars,AUDUSD) && 
      CopyClose("USDCAD",_Period,0,countBars,USDCAD) && 
      CopyClose("NZDUSD",_Period,0,countBars,NZDUSD))
      bad=true; return(bad);
  }
//+------------------------------------------------------------------+
//| calculation                                                      |
//+------------------------------------------------------------------+
void countBuf()
  {
   for(i=0;i<countBars;i++)
     {
      USDBufferPlot[i]=(100*MathPow(EURUSD[i],0.125)+100*MathPow(GBPUSD[i],0.125)+100*MathPow(USDCHF[i],0.125)+100*MathPow(USDJPY[i],0.125)+100*MathPow(AUDUSD[i],0.125)+100*MathPow(USDCAD[i],0.125)+100*MathPow(NZDUSD[i],0.125))/8;
      //Print("USDBufferPlot "+IntegerToString(i)+" : "+DoubleToString(USDBufferPlot[i]));
     }
   success=false;
  }
//+------------------------------------------------------------------+
