//+------------------------------------------------------------------+
//|                                                         QEMA.mq5 |
//+------------------------------------------------------------------+
#property copyright   "Bruno Pio"
#property description "Quadruple Exponential Moving Average"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_width1  2
#property indicator_label1  "QEMA"
#property indicator_applied_price PRICE_CLOSE
//--- input parameters
input int                InpPeriodEMA=14;               // EMA period
input int                InpShift=0;                    // Indicator's shift
//--- indicator buffers
double                  QemaBuffer[];
double                  Ema[];
double                  EmaOfEma[];
double                  EmaOfEmaOfEma[];
double                  EmaOfEmaOfEmaOfEma[];
double                  EmaOfEmaOfEmaOfEmaOfEma[];

double Close[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,QemaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Ema,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,EmaOfEma,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,EmaOfEmaOfEma,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,EmaOfEmaOfEmaOfEma,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,EmaOfEmaOfEmaOfEmaOfEma,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,5*InpPeriodEMA-5);
//--- sets indicator shift
   PlotIndexSetInteger(0,PLOT_SHIFT,InpShift);
//--- name for indicator label
   IndicatorSetString(INDICATOR_SHORTNAME,"QEMA("+string(InpPeriodEMA)+")");
//--- name for index label
   PlotIndexSetString(0,PLOT_LABEL,"QEMA("+string(InpPeriodEMA)+")");

   ArraySetAsSeries(Close,true);

//--- initialization done
  }
//+------------------------------------------------------------------+
//| Triple Exponential Moving Average                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- check for data
   if(rates_total<5*InpPeriodEMA-5)
      return(0);
//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- calculate EMA
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpPeriodEMA,price,Ema);
//--- calculate EMA on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,InpPeriodEMA-1,InpPeriodEMA,Ema,EmaOfEma);
//--- calculate EMA on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,2*InpPeriodEMA-2,InpPeriodEMA,EmaOfEma,EmaOfEmaOfEma);
//--- calculate EMA on EMA array on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,3*InpPeriodEMA-3,InpPeriodEMA,EmaOfEmaOfEma,EmaOfEmaOfEmaOfEma);
//--- calculate EMA on EMA array on EMA array on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,4*InpPeriodEMA-4,InpPeriodEMA,EmaOfEmaOfEmaOfEma,EmaOfEmaOfEmaOfEmaOfEma);
//--- calculate QEMA

   for(int i=limit;i<rates_total && !IsStopped();i++)
      QemaBuffer[i]=5*Ema[i]-10*EmaOfEma[i]+10*EmaOfEmaOfEma[i]-5*EmaOfEmaOfEmaOfEma[i]+EmaOfEmaOfEmaOfEmaOfEma[i];

//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
