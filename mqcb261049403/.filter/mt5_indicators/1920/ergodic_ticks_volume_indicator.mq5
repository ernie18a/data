//+------------------------------------------------------------------+
//|                               Ergodic_Ticks_Volume_Indicator.mq5 |
//|                                    Copyright © 2006, Profitrader | 
//|                                             profitrader@inbox.ru | 
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2006, Profitrader"
//---- link to the website of the author
#property link "profitrader@inbox.ru"
#property description "Ergodic Ticks Volume Indicator"
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//----two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- Red color is used as the color of the indicator line
#property indicator_color1  clrRed
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Ergodic_Ticks_Volume_Indicator"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- BlueViolet color is used as the color of the indicator line
#property indicator_color2  clrBlueViolet
//---- the line of the indicator 1 is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "Signal"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3,XMA4,XMA5,XMA6,XMA7,XMA8;
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume
input Smooth_Method XMA_Method=MODE_EMA; // Averaging method
input uint XLength1=12;                            // Depth of the first averaging
input uint XLength2=12;                            // Depth of the second averaging
input uint XLength3=1;                             // Depth of the third averaging
input uint XLength4=5;                             // Depth of the first averaging
input uint XLength5=5;                             // Depth of the second averaging
input uint XLength6=5;                             // Depth of the third averaging                     
input int XPhase=15;                               // Smoothing parameter
                                                   // for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input int Shift=0;                                 // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ETVIBuffer[],SigBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_1,min_rates_2,min_rates_3,min_rates_4,min_rates_5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_1=XMA1.GetStartBars(XMA_Method,XLength1,XPhase);
   min_rates_2=min_rates_1+XMA1.GetStartBars(XMA_Method,XLength2,XPhase);
   min_rates_3=min_rates_2+XMA1.GetStartBars(XMA_Method,XLength3,XPhase);
   min_rates_4=min_rates_3+XMA1.GetStartBars(XMA_Method,XLength4,XPhase);
   min_rates_5=min_rates_4+XMA1.GetStartBars(XMA_Method,XLength5,XPhase);
   min_rates_total=min_rates_5+XMA1.GetStartBars(XMA_Method,XLength6,XPhase);
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ETVIBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the beginning of calculation of indicator 1 drawing by 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,SigBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the beginning of calculation of indicator 2 drawing by 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Ergodic_Ticks_Volume_Indicator");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   double UpTicks,DownTicks,EMA_UpTicks,EMA_DownTicks,DEMA_UpTicks;
   double DEMA_DownTicks,res,TVI_calculate,TVI,EMA_TVI,Ergodic_TVI,Ergodic_Signal;
   int first,bar;
   long Vol;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0;                   // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total; bar++)
     {
      if(VolumeType==VOLUME_TICK) Vol=long(tick_volume[bar]);
      else Vol=long(volume[bar]);

      UpTicks=(Vol+(close[bar]-open[bar])/_Point)/2;
      DownTicks=Vol-UpTicks;

      EMA_UpTicks=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength1,UpTicks,bar,false);
      EMA_DownTicks=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength1,DownTicks,bar,false);

      DEMA_UpTicks=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength2,EMA_UpTicks,bar,false);
      DEMA_DownTicks=XMA4.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength2,EMA_DownTicks,bar,false);

      res=(DEMA_UpTicks+DEMA_DownTicks);

      if(res) TVI_calculate=100.0*(DEMA_UpTicks-DEMA_DownTicks)/res;
      else TVI_calculate=0.0;

      TVI=XMA5.XMASeries(min_rates_2,prev_calculated,rates_total,XMA_Method,XPhase,XLength3,TVI_calculate,bar,false);

      EMA_TVI=XMA6.XMASeries(min_rates_3,prev_calculated,rates_total,XMA_Method,XPhase,XLength4,TVI,bar,false);
      Ergodic_TVI=XMA7.XMASeries(min_rates_4,prev_calculated,rates_total,XMA_Method,XPhase,XLength5,EMA_TVI,bar,false);
      Ergodic_Signal=XMA8.XMASeries(min_rates_5,prev_calculated,rates_total,XMA_Method,XPhase,XLength6,Ergodic_TVI,bar,false);

      ETVIBuffer[bar]=Ergodic_TVI;
      SigBuffer[bar]=Ergodic_Signal;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
