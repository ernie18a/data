//+------------------------------------------------------------------+
//|                                                ImpulseCandle.mq5 |
//|   Marks impulse candles as defined in the EA specification:      |
//|   body >= ATR x multiplier, body/range >= minimum ratio, close   |
//|   in the top part (bull) or bottom part (bear) of the candle,    |
//|   optional tick-volume confirmation against a rolling average.   |
//+------------------------------------------------------------------+
#property copyright   "Sergej Michajlik"
#property version     "1.00"
#property description "Impulse candle marker: body >= ATR x mult, body/range >= ratio,"
#property description "close near the extreme, optional tick-volume confirmation."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "Bull impulse"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_label2  "Bear impulse"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  2
//--- inputs (defaults from the specification)
input int    InpAtrPeriod      = 14;    // ATR period
input double InpImpulseAtrMult = 1.20;  // Body >= ATR x this
input double InpMinBodyRatio   = 0.65;  // Body / range >= this
input double InpMinCloseLoc    = 0.70;  // Close location in range (0.70 = top 30% for bull, bottom 30% for bear)
input bool   InpUseVolume      = true;  // Require tick volume above average
input int    InpVolumePeriod   = 20;    // Volume average period
input double InpVolumeMult     = 1.30;  // Volume >= average x this
//--- buffers and handles
double BullBuf[];
double BearBuf[];
int    ExtAtrHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,BullBuf,INDICATOR_DATA);
   SetIndexBuffer(1,BearBuf,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_ARROW,233);            // up arrow
   PlotIndexSetInteger(1,PLOT_ARROW,234);            // down arrow
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- ATR of the chart symbol and timeframe
   ExtAtrHandle=iATR(_Symbol,_Period,InpAtrPeriod);
   if(ExtAtrHandle==INVALID_HANDLE)
     {
      Print("ImpulseCandle: cannot create ATR handle");
      return(INIT_FAILED);
     }
   IndicatorSetString(INDICATOR_SHORTNAME,"ImpulseCandle("+(string)InpAtrPeriod+","+DoubleToString(InpImpulseAtrMult,2)+")");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int lookback=MathMax(InpAtrPeriod,InpVolumePeriod)+1;
   if(rates_total<=lookback)
      return(0);
//--- ATR values for every bar
   double atr[];
   if(CopyBuffer(ExtAtrHandle,0,0,rates_total,atr)<rates_total)
      return(0);
//--- recalculate only the new bars (and the current one)
   int start=(prev_calculated>lookback) ? prev_calculated-1 : lookback;
   for(int i=start; i<rates_total; i++)
     {
      BullBuf[i]=0.0;
      BearBuf[i]=0.0;
      double body=MathAbs(close[i]-open[i]);
      double range=high[i]-low[i];
      if(range<=0.0 || atr[i]<=0.0)
         continue;
      //--- size of the body against ATR and against the candle range
      if(body<atr[i]*InpImpulseAtrMult || body/range<InpMinBodyRatio)
         continue;
      //--- optional tick-volume confirmation
      if(InpUseVolume)
        {
         double sum=0.0;
         for(int k=1; k<=InpVolumePeriod; k++)
            sum+=(double)tick_volume[i-k];
         if((double)tick_volume[i]<sum/InpVolumePeriod*InpVolumeMult)
            continue;
        }
      //--- close location inside the candle: 1.0 = closed at the high
      double loc=(close[i]-low[i])/range;
      if(close[i]>open[i] && loc>=InpMinCloseLoc)
         BullBuf[i]=low[i]-atr[i]*0.3;
      else if(close[i]<open[i] && loc<=1.0-InpMinCloseLoc)
         BearBuf[i]=high[i]+atr[i]*0.3;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
