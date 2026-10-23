//+------------------------------------------------------------------+
//|                                                          RMI.mq5 |
//|                                            Copyright 2013, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Relative Momentum Index"
//---
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot RMI
#property indicator_label1  "RMI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//---
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 30
#property indicator_level2 50
#property indicator_level3 70
//--- input parameters
input ushort   InpRmiPeriod = 14;   // RMI Period
input ushort   InpMomPeriod = 10;   // Momentum Period
//--- indicator buffers
double         RMIBuffer[];
double         PosBuffer[];
double         NegBuffer[];
//---
ushort         rmi_period;
ushort         mom_period;
ushort         min_required_bars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   if ( InpRmiPeriod < 1 ) {
      rmi_period = 14;
      printf("Incorrected input variable RMI Period = %d. Indicator will use value %d.",
            InpRmiPeriod, rmi_period);
   } else {
      rmi_period = InpRmiPeriod;
   }
   
   if ( InpMomPeriod < 1 ) {
      mom_period = 10;
      printf("Incorrected input variable Momentum Period = %d. Indicator will use value %d.",
            InpMomPeriod, mom_period);
   } else {
      mom_period = InpMomPeriod;
   }
   
   min_required_bars = rmi_period + mom_period + 1;
//--- indicator buffers mapping
   SetIndexBuffer(0, RMIBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, PosBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, NegBuffer, INDICATOR_CALCULATIONS);
//---
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, min_required_bars);
//---
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "RMI("+(string)rmi_period
                        +", "+(string)mom_period+")");
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
   if ( rates_total < min_required_bars ) {
      Print("Not enough bars for calculation");
      return(0);
   }
//---
   int start_bar;
   
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      start_bar = min_required_bars;
      ArrayInitialize(RMIBuffer, 0.0);
      ArrayInitialize(PosBuffer, 0.0);
      ArrayInitialize(NegBuffer, 0.0);
   } else {
      start_bar = prev_calculated - 1;
   }
//---
   for ( int bar = start_bar; bar < rates_total; bar++ ) {
      double diff = price[bar] - price[bar-mom_period];
      
      PosBuffer[bar] = (PosBuffer[bar-1] * (rmi_period - 1) + (diff > 0.0 ? diff : 0.0)) / rmi_period;
      NegBuffer[bar] = (NegBuffer[bar-1] * (rmi_period - 1) + (diff < 0.0 ? -diff :0.0)) / rmi_period;
      
      if ( NegBuffer[bar] != 0.0 ) {
         RMIBuffer[bar] = 100.0 - 100.0 / (1 + PosBuffer[bar] / NegBuffer[bar]);
      } else {
         RMIBuffer[bar] = 50.0;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
