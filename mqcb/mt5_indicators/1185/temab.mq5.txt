//+------------------------------------------------------------------+
//|                                                        TEMAB.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "2010, MetaQuotes Software Corp."
#property link        "https://forge.mql5.io"
#property description "Triple Exponential Moving Average Band"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_color2  LightSeaGreen
#property indicator_type3   DRAW_LINE
#property indicator_color3  LightSeaGreen
#property indicator_label1  "Bands middle"
#property indicator_label2  "Bands upper"
#property indicator_label3  "Bands lower"
#property indicator_applied_price PRICE_CLOSE
//--- input parameters
input int                InpPeriodEMA=14;               // EMA period
input int                InpShift=0;                    // Indicator's shift
input double             ExtBandsDeviations=1.5;
//--- indicator buffers
double                  TemaBuffer[];
double                  Ema[];
double                  EmaOfEma[];
double                  EmaOfEmaOfEma[];
double ExtStdDevBuffer[],UpBuffer[],DnBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,TemaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,Ema,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,EmaOfEma,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,EmaOfEmaOfEma,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtStdDevBuffer,INDICATOR_CALCULATIONS);

//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,3*InpPeriodEMA-3);
//--- sets indicator shift
   PlotIndexSetInteger(0,PLOT_SHIFT,InpShift);

   PlotIndexSetString(0,PLOT_LABEL,"Bands("+string(InpPeriodEMA)+") Middle");
   PlotIndexSetString(1,PLOT_LABEL,"Bands("+string(InpPeriodEMA)+") Upper");
   PlotIndexSetString(2,PLOT_LABEL,"Bands("+string(InpPeriodEMA)+") Lower");

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
   if(rates_total<3*InpPeriodEMA-3)
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
//--- calculate TEMA
   for(int i=limit;i<rates_total && !IsStopped();i++)
     {
      TemaBuffer[i]=3*Ema[i]-3*EmaOfEma[i]+EmaOfEmaOfEma[i];
      ExtStdDevBuffer[i]=StdDev_Func(i,price,TemaBuffer,InpPeriodEMA);
      UpBuffer[i]=TemaBuffer[i]+ExtBandsDeviations*ExtStdDevBuffer[i];
      DnBuffer[i]=TemaBuffer[i]-ExtBandsDeviations*ExtStdDevBuffer[i];
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position<period) return(StdDev_dTmp);
//--- calcualte StdDev
   for(int i=0;i<period;i++) StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
   StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
//--- return calculated value
   return(StdDev_dTmp);
  }
//+------------------------------------------------------------------+
