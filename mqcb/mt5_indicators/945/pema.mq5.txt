//+------------------------------------------------------------------+
//|                                                         PEMA.mq5 |
//+------------------------------------------------------------------+
#property copyright   "Bruno Pio"
#property description "Pentuple Exponential Moving Average"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_width1  2
#property indicator_label1  "PEMA"
#property indicator_applied_price PRICE_CLOSE
//--- input parameters
input int                InpPeriodEMA=14;               // EMA period
input int                InpShift=0;                    // Indicator's shift
//--- indicator buffers
double                  PemaBuffer[];
double                  Ema1[];
double                  Ema2[];
double                  Ema3[];
double                  Ema4[];
double                  Ema5[];
double                  Ema6[];
double                  Ema7[];
double                  Ema8[];

   double Close[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,PemaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Ema1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,Ema2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,Ema3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,Ema4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,Ema5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,Ema6,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,Ema7,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,Ema8,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,8*InpPeriodEMA-8);
//--- sets indicator shift
   PlotIndexSetInteger(0,PLOT_SHIFT,InpShift);
//--- name for indicator label
   IndicatorSetString(INDICATOR_SHORTNAME,"PEMA("+string(InpPeriodEMA)+")");
//--- name for index label
   PlotIndexSetString(0,PLOT_LABEL,"PEMA("+string(InpPeriodEMA)+")");
   
   
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
   if(rates_total<8*InpPeriodEMA-8)
      return(0);
//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- calculate EMA
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpPeriodEMA,price,Ema1);
//--- calculate EMA on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,InpPeriodEMA-1,InpPeriodEMA,Ema1,Ema2);
//--- calculate EMA on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,2*InpPeriodEMA-2,InpPeriodEMA,Ema2,Ema3);
   //--- calculate EMA on EMA array on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,3*InpPeriodEMA-3,InpPeriodEMA,Ema3,Ema4);
   //--- calculate EMA on EMA array on EMA array on EMA array on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,4*InpPeriodEMA-4,InpPeriodEMA,Ema4,Ema5);
   ExponentialMAOnBuffer(rates_total,prev_calculated,5*InpPeriodEMA-5,InpPeriodEMA,Ema5,Ema6);
   ExponentialMAOnBuffer(rates_total,prev_calculated,6*InpPeriodEMA-6,InpPeriodEMA,Ema6,Ema7);
   ExponentialMAOnBuffer(rates_total,prev_calculated,7*InpPeriodEMA-7,InpPeriodEMA,Ema7,Ema8);
   
//--- calculate PEMA
   
   
   for(int i=limit;i<rates_total && !IsStopped();i++)
      PemaBuffer[i]=8*Ema1[i]-28*Ema2[i]+56*Ema3[i]-70*Ema4[i]+56*Ema5[i]-28*Ema6[i]+8*Ema7[i]-Ema8[i];
      
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
