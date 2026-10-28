//+------------------------------------------------------------------+
//|                                                 NextBarColor.mq5 |
//|                            Copyright 01.08.2013, MetaDriver Lab. |
//|                         https://www.mql5.com/ru/users/metadriver |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaDriver Lab."
#property link      "https://www.mql5.com/ru/users/metadriver"
#property version   "1.00"
#property description   "The indicator 'predicts' the next bar color"
#property description   "        with the probability specified in the settings."
#property description   "        Useful for evaluation of strategies aimed"
#property description   "        at such a prediction."
#property description   "        Attention!: The indicator 'looks into the future',"
#property description   "        so do not apply it in real trading!."

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//---- plot ColorBars
#property indicator_label1  "NextBarColor"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red
#property indicator_width1   3
//+------------------------------------------------------------------+

input double       InpPrecision=100;   // The accuracy of the "prediction" in pecentage
double Precision;
//--- indicator buffers
double ExtBuffer[];
double ExtColorsBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- Set bounds
   Precision = (InpPrecision>100) ? 100 : InpPrecision;
   Precision = (Precision<50) ? 50 : Precision;
   Precision/= 100.0;
   MathSrand(uint(GetTickCount()));
//--- indicators
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//--- don't show indicator data in DataWindow
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   IndicatorSetString(INDICATOR_SHORTNAME,"NextBarColor("+DoubleToString(Precision*100,2)+"%)");
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
   int  i=0;
//--- set position for beginning
   if(i<prev_calculated) i=prev_calculated-2;
//--- start calculations
   while(i<(rates_total-1) && !IsStopped())
     {
      double P=rand()*1./32767.0;
      P=(P<Precision) ? 1. : -1;
      ExtBuffer[i]=(close[i]<close[i+1]) ? P : -P;
      ExtColorsBuffer[i]=(ExtBuffer[i]>0) ? 0 : 1;
      i++;
     }
   ExtBuffer[i]=0.; // last bar
   ExtColorsBuffer[i]=0;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
