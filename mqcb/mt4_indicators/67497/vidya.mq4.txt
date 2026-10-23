//+------------------------------------------------------------------+
//|                                                        VIDYA.mq4 |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2000-2025, MetaQuotes Ltd."
#property link        "https://forge.mql5.io"
#property description "Variable Index Dynamic Average"
#property strict
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers         1
#property indicator_plots           1
#property indicator_type1           DRAW_LINE
#property indicator_color1          Red
#property indicator_width1          1
#property indicator_label1          "VIDYA"
//--- input parameters
input int InpPeriodCMO=9;              // Period CMO
input int InpPeriodEMA=12;             // Period EMA
input int InpShift=0;                  // Indicator's shift
//--- indicator buffer
double VIDYA_Buffer[];

double ExtF; // smooth factor
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,VIDYA_Buffer,INDICATOR_DATA);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPeriodEMA+InpPeriodCMO-1);
//--- sets indicator shift
   PlotIndexSetInteger(0,PLOT_SHIFT,InpShift);
//--- name for indicator label
   string short_name=StringFormat("VIDYA(%d,%d)",InpPeriodCMO,InpPeriodEMA);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- calculate smooth factor
   ExtF=2.0/(1.0+InpPeriodEMA);
  }
//+------------------------------------------------------------------+
//| Variable Index Dynamic Average                                   |
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
   if(rates_total<InpPeriodEMA+InpPeriodCMO-1)
      return(0);
//---
   int i,start_;
   if(prev_calculated<InpPeriodEMA+InpPeriodCMO-1)
     {
      start_=rates_total - (InpPeriodEMA+InpPeriodCMO+1);
      for(i=rates_total-1; i>=start_; i--)
         VIDYA_Buffer[i]=close[i];
     }
   else
      start_=rates_total - prev_calculated+1;
//--- main cycle
   for(i=start_; i>=0 && !IsStopped(); i--)
     {
      double mul_CMO=MathAbs(CalculateCMO(i,InpPeriodCMO,close));
      //--- calculate VIDYA
      VIDYA_Buffer[i]=close[i]*ExtF*mul_CMO+VIDYA_Buffer[i+1]*(1-ExtF*mul_CMO);
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Chande Momentum Oscillator                                       |
//+------------------------------------------------------------------+
double CalculateCMO(int pos,const int period,const double &price[])
  {
   double res=0.0;
   double sum_up=0.0,sum_down=0.0;
//---
   if(pos<ArraySize(price))
     {
      for(int i=0; i<period; i++)
        {
         double diff=price[pos+i]-price[pos+i+1]; //20-0 - 19,  0 - 1
         if(diff>0.0)
            sum_up+=diff;
         else
            sum_down+=(-diff);
        }
      if(sum_up+sum_down!=0.0)
         res=(sum_up-sum_down)/(sum_up+sum_down);
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
