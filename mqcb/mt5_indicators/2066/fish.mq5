//+------------------------------------------------------------------+ 
//|                                                         Fish.mq5 | 
//|                                 Copyright © 2005, Yura Prokofiev | 
//|                                         Yura.prokofiev@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Yura Prokofiev"
#property link "Yura.prokofiev@gmail.com" 
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//| Parameters of indicator drawing   |
//+-----------------------------------+
//--- drawing indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- the following colors are used in the four color histogram
#property indicator_color1 clrDarkOrange,clrViolet,clrGray,clrDeepSkyBlue,clrLimeGreen
//--- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1 2
//--- displaying the indicator label
#property indicator_label1 "Fish"
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input   uint period=10;
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| Fish indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(period+1);
//--- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Fish");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Fish iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int limit,bar;
   double price,MaxH,MinL,Range,Value,Diff;
   static double Value1;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
      int barl=limit+1;
      MaxH=High[ArrayMaximum(High,barl,period)];
      MinL=Low[ArrayMinimum(Low,barl,period)];
      price=(High[barl]+Low[barl])/2;
      Range=MaxH-MinL;
      if(Range) Value1=0.33*2*((price-MinL)/Range-0.5);
      Value1=MathMin(MathMax(Value1,-0.999),0.999);
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MaxH=High[ArrayMaximum(High,bar,period)];
      MinL=Low[ArrayMinimum(Low,bar,period)];
      price=(High[bar]+Low[bar])/2;
      Range=MaxH-MinL;
      if(Range) Value=0.33*2*((price-MinL)/Range-0.5)+0.67*Value1;
      Value=MathMin(MathMax(Value,-0.999),0.999);
      Diff=1-Value;
      if(Diff) IndBuffer[bar]=0.5*MathLog((1+Value)/Diff)+0.5*IndBuffer[bar+1];
      else IndBuffer[bar]=1.0;
      if(bar) Value1=Value;
     }
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//--- main cycle of the indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=3;
        }
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
