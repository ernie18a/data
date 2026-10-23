//+------------------------------------------------------------------+ 
//|                                          OzFX_D1_IndAES_v1.0.mq5 | 
//|                                            Copyright © 2008, DGC |
//|                                          http://www.ozfx.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, DGC"
#property link      "http://www.ozfx.com.au/" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 5
#property indicator_buffers 5 
//---- only three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the three-color histogram are as follows
#property indicator_color1 clrMagenta,clrGray,clrTeal
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "OzFX Signals"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- colors of the three-color histogram are as follows
#property indicator_color2 clrRed,clrGray,clrBlue
//---- indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2 2
//---- displaying the indicator label
#property indicator_label2 "AES Signals"

//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- gold color is used as the color of the bullish line of the indicator
#property indicator_color3 clrGold
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width3  2
//---- displaying the indicator label
#property indicator_label3  "SMA Filter"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint SMA_Filter_Period=200;
//+-----------------------------------+
//---- indicator buffers
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
double ColorIndBuffer1[];
double ColorIndBuffer2[];
double ColorIndBuffer3[];
//---- Declaration of integer variables of data starting point
int min_rates_total,KPer,DPer,Slow,ACLim;
//---- Declaration of integer variables for the indicator handles
int MA_Handle,AC_Handle,STO_Handle;
//+------------------------------------------------------------------+    
//| 2pbIdealXOSMA indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   KPer=5;
   DPer=3;
   Slow=3;
   ACLim=37;
   min_rates_total=int(MathMax(MathMax(ACLim,KPer+DPer+Slow),SMA_Filter_Period));

//---- Getting indicator handles  
   STO_Handle=iStochastic(NULL,0,KPer,DPer,Slow,MODE_SMA,STO_LOWHIGH);
   if(STO_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic indicator");

//---- getting the iMA indicator handle
   MA_Handle=iMA(NULL,0,SMA_Filter_Period,0,MODE_SMA,PRICE_CLOSE);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting the Accelerator Oscillator indicator handle 
   AC_Handle=iAC(NULL,0);
   if(AC_Handle==INVALID_HANDLE) Print(" Failed to get handle of the Accelerator Oscillator indicator");

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer1,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer1,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorIndBuffer1,true);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,IndBuffer2,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer2,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorIndBuffer2,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorIndBuffer2,true);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(4,IndBuffer3,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer3,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"OzFX_D1_IndAES_v1.0");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| 2pbIdealXOSMA iteration function                                 | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(STO_Handle)<rates_total
      || BarsCalculated(AC_Handle)<rates_total
      || BarsCalculated(MA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- Declaration of integer variables
   int limit,bar,to_copy;
//---- declaration of variables with a floating point  
   double Stoc[],Main[],AC[],MA[];
   
   static int trend1,trend2;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      trend1=0;
      trend2=0;
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Stoc,true);
   ArraySetAsSeries(Main,true);
   ArraySetAsSeries(AC,true);
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(close,true);

   to_copy=limit+1;

//--- copy newly appeared data in the array
   if(CopyBuffer(STO_Handle,MAIN_LINE,0,to_copy,Stoc)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,SIGNAL_LINE,0,to_copy,Main)<=0) return(RESET);
   if(CopyBuffer(AC_Handle,0,0,to_copy+1,AC)<=0) return(RESET);
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      IndBuffer1[bar]=0;
      ColorIndBuffer1[bar]=1;

      if(AC[bar]>0 && AC[bar]>AC[bar+1] && Stoc[bar]>50)
        {
         if(trend1!=+1)
           {
            IndBuffer1[bar]=+2;
            ColorIndBuffer1[bar]=2;
           }

         if(bar) trend1=+1;
        }

      if(AC[bar]<0 && AC[bar]<AC[bar+1] && Stoc[bar]<50)
        {
         if(trend1!=-1)
           {
            IndBuffer1[bar]=-2;
            ColorIndBuffer1[bar]=0;
           }

         if(bar) trend1=-1;
        }

      IndBuffer2[bar]=0;
      ColorIndBuffer2[bar]=1;

      if(AC[bar]>AC[bar+1] && Stoc[bar]>Main[bar])
        {
         if(trend2!=+1)
           {
            IndBuffer2[bar]=+1;
            ColorIndBuffer2[bar]=2;
           }

         if(bar) trend2=+1;
        }

      if(AC[bar]<AC[bar+1] && Stoc[bar]<Main[bar])
        {
         if(trend2!=-1)
           {
            IndBuffer2[bar]=-1;
            ColorIndBuffer2[bar]=0;
           }

         if(bar) trend2=-1;
        }

      IndBuffer3[bar]=0;
      if(close[bar]>MA[bar]) IndBuffer3[bar]=+2;
      if(close[bar]<=MA[bar]) IndBuffer3[bar]=-2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
