//+------------------------------------------------------------------+
//|                                                        ExVol.mq5 |
//|                           Copyright © 2006, Alex Sidd (Executer) |
//|                                           mailto:work_st@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Alex Sidd (Executer)"
#property link      "mailto:work_st@mail.ru" 
//--- indicator version
#property version   "1.01"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//| Indicator drawing parameters      |
//+-----------------------------------+
//--- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- colors of the four-color histogram are as follows
#property indicator_color1 clrRed,clrLightSalmon,clrGray,clrSkyBlue,clrBlue
//--- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1 2
//--- displaying the indicator label
#property indicator_label1 "ExVol"
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input uint ExPeriod=15;
//+-----------------------------------+
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(ExPeriod);
//--- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"ExVol("+string(ExPeriod)+")");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of local variables 
   int first,bar;
   double;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=min_rates_total;  // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double negative=0;
      double positive=0;
      int kkk=int(bar-ExPeriod+1);
      while(kkk<=bar)
        {
         double res=(close[kkk]-open[kkk])/_Point;
         if(res>0) positive+=res;
         if(res<0) negative-=res;
         kkk++;
        }
      IndBuffer[bar]=(positive-negative)/ExPeriod;
     }
   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//--- main cycle of the indicator coloring
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=0;

      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=3;
        }

      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
