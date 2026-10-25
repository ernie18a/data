//+------------------------------------------------------------------+
//|                                                         HofP.mq5 |
//|                                                            Nofx  |
//|                                         http://noodls.narod2.ru/ |
//+------------------------------------------------------------------+
#property copyright "Nofx"
#property link      "https://www.mql5.com/ru/users/nofx"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Height
#property indicator_label1  "Height"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#include <Arrays\ArrayDouble.mqh>

//--- input parameters
input int      PeriodH=14;
//--- indicator buffers
double         HeightBuffer[];
//--- global variables
int            ExtPeriodH;
double         HightP[];//high price for the period
double         LowP[];//low price for the period
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping
   SetIndexBuffer(0,HeightBuffer,INDICATOR_DATA);
   if(PeriodH<=0)
     {
      ExtPeriodH=10;
      printf("Input parameter Period has incorrect value (%d). Indicator will use value %d for calculations.",
             PeriodH,ExtPeriodH);
     }
   else ExtPeriodH=PeriodH;
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtPeriodH);
//--- name for Dindicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"The height of the period ("+string(ExtPeriodH)+")");
   ArrayResize(HightP,ExtPeriodH,0);
   ArrayResize(LowP,ExtPeriodH,0);
//---

   return(0);
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
//---

//--- check for data
   if(rates_total<=ExtPeriodH)
      return(0);

   int  start,i;
//  Determine the initial bar for indicator buffer calculation:
   if(prev_calculated==0)
     {
      start=ExtPeriodH;
     }
   else
     {
      start=prev_calculated-1;
     }

//      Loop of calculating the indicator buffer values:
   for(i=start; i<rates_total; i++)
     {
      int f=0;
      for(int j=i-ExtPeriodH; j<i; j++)
        {
         //            Print(i);
         HightP[f]=high[j];
         LowP[f]=low[j];
         f++;

        }
      HeightBuffer[i]=HightP[ArrayMaximum(HightP,0,WHOLE_ARRAY)]-LowP[ArrayMinimum(LowP,0,WHOLE_ARRAY)];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
