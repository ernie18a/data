//+------------------------------------------------------------------+
//|                                                        BB-HL.mq5 |
//|                                Copyright © 2005, David W. Thomas |
//|                                           mailto:davidwt@usa.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, David W. Thomas"
#property link      "mailto:davidwt@usa.net"
#property description ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- 5 graphical plots are used
#property indicator_plots   3
//+-----------------------------------+
//| Indicator drawing parameters      |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- DeepPink color is used as the indicator line color
#property indicator_color1 clrDeepPink
//--- indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "X2MA"
//+--------------------------------------------+
//| BB levels indicator drawing parameters     |
//+--------------------------------------------+
//--- drawing Bollinger bands as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//--- selection of Bollinger Bands colors
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrDodgerBlue
//--- Bollinger bands are solid curves
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//--- Bollinger Bands width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//--- display of Bollinger Bands labels
#property indicator_label2  "+2Sigma"
#property indicator_label3  "-2Sigma"
//+-----------------------------------+
//| Description of smoothing classes  |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
CStdDeviation STD;
//+-----------------------------------+
//| declaration of enumerations       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE_,        //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA;  // First smoothing method
input uint Length1=100;                   // Depth of the first smoothing                    
input int Phase1=15;                      // First smoothing parameter
//--- Phase1: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- Phase1: for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method MA_Method2=MODE_JJMA; // Second smoothing method
input uint Length2=20;                    // Depth of the second smoothing 
input int Phase2=100;                     // Second smoothing parameter
//--- Phase2: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- Phase2: for VIDIA it is a CMO period, for AMA it is a slow average period
input uint BandsPeriod=100;               // BB averaging period
input double BandsDeviation=2.0;          // Number of deviations
input Applied_price_ IPC=PRICE_CLOSE;     // Price constant
input int Shift=0;                        // Horizontal shift of the indicator in bars
input int PriceShift=0;                   // Vertical shift of the indicator in points
//+-----------------------------------+
//--- declaration of a dynamic array that will be used as an indicator buffer
double X2MA[];
//--- declaration of dynamic arrays that will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[];
//--- declaration of the average vertical shift value variable
double dPriceShift;
//--- declaration of integer variables of data starting point
int min_rates_total,min_rates_1,min_rates_2;
//--- declaration of global variables
int Count[];
double Value[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by reference
                          int Size)
  {
//---
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//---
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_1=XMA1.GetStartBars(MA_Method1,Length1,Phase1)+1;
   min_rates_2=min_rates_1+XMA2.GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total=min_rates_2+int(BandsPeriod);
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length1",Length1);
   XMA2.XMALengthCheck("Length2",Length2);
   XMA2.XMALengthCheck("BandsPeriod",BandsPeriod);
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase1",Phase1,MA_Method1);
   XMA2.XMAPhaseCheck("Phase2",Phase2,MA_Method2);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- memory distribution for variables' arrays  
   ArrayResize(Count,BandsPeriod);
   ArrayResize(Value,BandsPeriod);
//---  
   ArrayInitialize(Count,0);
   ArrayInitialize(Value,0.0);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//--- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"BB-HL(",Length1,", ",Length2,", ",BandsPeriod,", ",Smooth1,", ",Smooth2,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
//--- declaration of variables with a floating point  
   double price,x1xma,x2xma,Sum,diff1,diff2,res;
//--- declaration of integer variables and getting already calculated bars
   int first,bar;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;                   // starting number for calculating all bars
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- call of the PriceSeries function to get the input price 'price_'
      price=PriceSeries(IPC,bar,open,low,high,close);
      //--- two calls of the XMASeries function 
      x1xma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,false);
      x2xma=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,x1xma,bar,false);
      //---    
      X2MA[bar]=x2xma+dPriceShift;   
      diff1=high[bar]-x2xma;
      diff1*=diff1;
      diff2=low[bar]-x2xma;
      diff2*=diff2;
      Value[Count[0]]=MathMax(diff1,diff2);      
      Sum=0;
      for(int iii=0; iii<int(BandsPeriod); iii++) Sum+=Value[iii];
      res=Sum/BandsPeriod;
      res=BandsDeviation*MathSqrt(res);
      ExtLineBuffer1[bar]=x2xma+res+dPriceShift;
      ExtLineBuffer2[bar]=x2xma-res+dPriceShift;
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,BandsPeriod);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
