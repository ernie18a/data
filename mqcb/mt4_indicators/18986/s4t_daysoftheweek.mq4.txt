//+------------------------------------------------------------------+
//|                                            S4T_DaysOfTheWeek.mq4 |
//|                                                 soft4traders.com |
//|                                                 soft4traders.com |
//+------------------------------------------------------------------+
#property copyright "soft4traders.com"
#property link      "soft4traders.com"
#property version   "1.00"
#property strict
#property indicator_separate_window

#property description "The indicator marks the days of the week with a colored histogram in the chart sub-window."
#property description "Индикатор размечает дни недели разноцветной гистограммой в подокне графика."

#property indicator_buffers 7
#property indicator_maximum 1
#property indicator_minimum 0
// ================= INPUTS ==========================================
input color Sunday = clrDarkSlateGray;
input color Monday = clrGreen;
input color Tuesday= clrLime;
input color Wednesday= clrBlue;
input color Thursday = clrOrangeRed;
input color Friday=clrCrimson;
input color Saturday=clrRed;
// ================= VARIABLES =======================================
//---- buffers
double ExtMapBuffer1[];         //
double ExtMapBuffer2[];         //
double ExtMapBuffer3[];         //
double ExtMapBuffer4[];         //
double ExtMapBuffer5[];         //
double ExtMapBuffer6[];         //
double ExtMapBuffer7[];         //
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,4,Sunday);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"Sunday");
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,4,Monday);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"Monday");
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,4,Tuesday);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexLabel(2,"Tuesday");
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,4,Wednesday);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexLabel(3,"Wednesday");
   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(4,DRAW_HISTOGRAM,EMPTY,4,Thursday);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexLabel(4,"Thursday");
   SetIndexEmptyValue(4,0.0);
   SetIndexStyle(5,DRAW_HISTOGRAM,EMPTY,4,Friday);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexLabel(5,"Friday");
   SetIndexEmptyValue(5,0.0);
   SetIndexStyle(6,DRAW_HISTOGRAM,EMPTY,4,Saturday);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexLabel(6,"Saturday");
   SetIndexEmptyValue(6,0.0);
//---
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
//---
   int i=rates_total-prev_calculated-1;
   while(i>=0)
     {
      int curDay=TimeDayOfWeek(Time[i]);
      switch(curDay)
        {
         case  0:ExtMapBuffer1[i] = 1;break;
         case  1:ExtMapBuffer2[i] = 1;break;
         case  2:ExtMapBuffer3[i] = 1;break;
         case  3:ExtMapBuffer4[i] = 1;break;
         case  4:ExtMapBuffer5[i] = 1;break;
         case  5:ExtMapBuffer6[i] = 1;break;
         case  6:ExtMapBuffer7[i] = 1;break;
         default:
            break;
        }
      i--;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
