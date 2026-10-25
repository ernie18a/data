//+------------------------------------------------------------------+ 
//|                                                   Fisher_mbk.mq5 | 
//|                                    Copyright © 2005, Matt Kennel | 
//|                                         Yura.prokofiev@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Matt Kennel"
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
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- the following colors are used in the four color histogram
#property indicator_color1 clrMagenta,clrViolet,clrGray,clrDeepSkyBlue,clrBlue
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1 2
//--- displaying the indicator label
#property indicator_label1 "Fisher_mbk"
//+-----------------------------------+
//| Scale limits of indicator window  |
//+-----------------------------------+
#property indicator_maximum +1    // The upper limits of a separate indicator window scale
#property indicator_minimum -1    // The lower limits of a separate indicator window scale
//+-----------------------------------+
//| indicator input parameters        |
//+-----------------------------------+
input   uint period=10;
input double HMALenHiLo=5.0;
input double HMALenZ=3.0;
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//---
double mix_a,mix_b,mixprime_a,mixprime_b;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| Fisher_mbk indicator initialization function                     | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(period+1);
//--- initialization of constants
   mix_a=3.0/(2.0+HMALenHiLo);
   mix_b=3.0/(2.0+HMALenZ);
   mixprime_a=1.0-mix_a;
   mixprime_b=1.0-mix_b;
//--- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- set dynamic array as a color index buffer
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Fisher_mbk");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Fisher_mbk iteration function                                    | 
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
   double MaxH,MinL,HiLo,Range,ma1,ma2,HMAofHiLo,Value,Diff,Ztransformed;
   static double ma1_a,ma2_a,ma1_b,ma2_b;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
      int barl=limit+1;
      MaxH=High[ArrayMaximum(High,barl,period)];
      MinL=Low[ArrayMinimum(Low,barl,period)];
      Range=MaxH-MinL;
      if(Range) HiLo=2.0*(Close[barl]-MinL)/Range-1.0;
      else HiLo=0.0;
      ma1_a=HiLo;
      ma2_a=ma1_a;
      HMAofHiLo=1.5*ma1-ma2;
      Value=MathMin(MathMax(HMAofHiLo,-0.999),0.999);
      Diff=1-Value;
      if(Diff) Ztransformed=MathLog((1+Value)/Diff);
      else Ztransformed=0.0;
      ma1_b=Ztransformed;
      ma2_b=ma1_b;
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MaxH=High[ArrayMaximum(High,bar,period)];
      MinL=Low[ArrayMinimum(Low,bar,period)];
      Range=MaxH-MinL;
      if(Range) HiLo=2.0*(Close[bar]-MinL)/Range-1.0;
      else HiLo=0.0;
      ma1=mixprime_a*ma1_a+mix_a*HiLo;
      ma2=mixprime_a*ma2_a+mix_a*ma1;
      HMAofHiLo=1.5*ma1-ma2;
      //---
      if(bar)
        {
         ma1_a=ma1;
         ma2_a=ma2;
        }
      //---  
      Value=MathMin(MathMax(HMAofHiLo,-0.999),0.999);
      Diff=1-Value;
      if(Diff) Ztransformed=MathLog((1+Value)/Diff);
      else Ztransformed=0.0;
      ma1=mixprime_b*ma1_b+mix_b*Ztransformed;
      ma2=mixprime_b*ma2_b+mix_b*ma1;
      IndBuffer[bar]=1.5*ma1-ma2;
      //---
      if(bar)
        {
         ma1_b=ma1;
         ma2_b=ma2;
        }
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
