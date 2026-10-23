//+--------------------------------------------------------------------------------------+
//|                                                                       FIR_filter.mq5 |
//|                                                                      Copyright gpwr. |
//+--------------------------------------------------------------------------------------+
#property copyright "gpwr"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "FIR filter"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_applied_price PRICE_OPEN

//--- global constants
#define pi 3.141592653589793238462643383279502884197169399375105820974944592

//--- indicator inputs
input int Per=50; // # of filter taps (period)

//--- global variables
double w[],wsum;

//--- indicator buffers
double x[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- calculate weights according to Hann window
   ArrayResize(w,Per);
   ArrayInitialize(w,0);
   for(int k=0;k<Per;k++)
     {
      w[k]=0.5-0.5*MathCos(2.*pi*(k+1)/(Per+1));
      wsum+=w[k];
     }

//--- map indicator buffer
   SetIndexBuffer(0,x,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,5);
   IndicatorSetString(INDICATOR_SHORTNAME,"FIR_filter("+string(Per)+")");
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Per);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- check for insufficient data
   if(rates_total<Per) return(0);

//--- main cycle
   int i=prev_calculated-1;
   if(i<Per-1) i=Per-1;
   while(i<rates_total)
     {
      x[i]=0.0;
      for(int k=0;k<Per;k++) x[i]+=price[i-k]*w[k];
      x[i]/=wsum;
      i++;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
