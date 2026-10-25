//+------------------------------------------------------------------+
//|                   Vortex Oscillator(barabashkakvn's edition).mq5 |
//|An adaptation of the Vortex Indicator described in the            |
//|January 2010 issue of Technical Analysis of Stocks & Commodities  |
//|This version plots the difference of VI+ - VI- to create an       |
//|oscillator indicator, as suggested by Michael Moses.              |
//+------------------------------------------------------------------+
#property  copyright "Copyright 2009 under Creative Commons BY-SA License by Neil D. Rosenthal & Michael Moses"
#property  link      "http://creativecommons.org/licenses/by-sa/3.0/"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots 1
#property indicator_label1  "Vortex Oscillator" 
#property indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1  clrBlue 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- input parameters
input int      VI_Length=14;
//--- indicator buffers 
double VortexOsc[];     //The Vortex Oscialltor - the difference betweeen VI+ and VI-
double PlusVI[];        //VI+ : + Vortex Indicator buffer
double MinusVI[];       //VI- : - Vortex Indicator buffer
double PlusVM[];        //VM+ : + Vortex Movement buffer
double MinusVM[];       //VM- : - Vorext Movement buffer
double SumPlusVM[];     //Sum of VI_Length PlusVM values
double SumMinusVM[];    //Sum of VI_Length MinusVM values
double SumTR[];         //True Range buffer
double ExtTRBuffer[];   //ATR buffer
double ExtATRBuffer[];  //ATR calculation buffer
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,VortexOsc,INDICATOR_DATA);
   SetIndexBuffer(1,PlusVI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,MinusVI,INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,VI_Length);
   SetIndexBuffer(3,PlusVM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,MinusVM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,SumPlusVM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,SumMinusVM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,SumTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,ExtTRBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,ExtATRBuffer,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
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
   if(rates_total<VI_Length+1)
      return(0);
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=0;
      //--- clear caching buffers
      for(int i=limit;i<rates_total;i++)
        {
         PlusVI[i]=0.0;
         MinusVI[i]=0.0;
         PlusVM[i]=0.0;
         MinusVM[i]=0.0;
         SumPlusVM[i]=0.0;
         SumMinusVM[i]=0.0;
         SumTR[i]=0.0;
         ExtTRBuffer[i]=0.0;
         ExtATRBuffer[i]=0.0;
        }
      limit=VI_Length;
     }
   for(int i=limit;i<rates_total;i++) // left #0 ... n ... right #rates_total
     {
      //--- store the values of PlusVM and MinusVM
      PlusVM[i]=MathAbs(high[i]-low[i-1]);         // PlusVM = |Today's High - Yesterday's Low|
      MinusVM[i]=MathAbs(low[i]-high[i-1]);        // MinusVM = |Today's Low - Yesterday's High|
      //---
      ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-1])/1.0;
      //--- sum VI_Length values of PlusVM, MinusVM and the True Range
      for(int j=0; j<VI_Length; j++)
        {
         SumPlusVM[i]+=PlusVM[i-j];
         SumMinusVM[i]+=MinusVM[i-j];
         SumTR[i]+=ExtATRBuffer[i-j];              //Sum VI_Length values of the True Range by using a 1-period ATR
        }
      //--- draw the indicator
      PlusVI[i]=SumPlusVM[i]/SumTR[i];
      MinusVI[i]=SumMinusVM[i]/SumTR[i];
      VortexOsc[i]=PlusVI[i]-MinusVI[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
