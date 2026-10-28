//+---------------------------------------------------------------------+
//|                                                          MaTMFI.mq5 |
//|                    Copyright © 2010,   VladMsk, contact@mqlsoft.com |
//|                                             http://www.becemal.ru// |
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+

//---- author of the indicator
#property copyright "Copyright © 2010, VladMsk, contact@mqlsoft.com"
//---- author of the indicator
#property link      "http://www.becemal.ru/"
//---- description of the indicator
#property description "True MFI. Based on code RSI.mq4"
//---- drawing indicator in a separate window
#property indicator_separate_window
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| MaTMFI indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- Teal color is used as the color of the bullish line of the indicator
#property indicator_color1  clrTeal
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "MaTMFI"
//+----------------------------------------------+
//| Trigger indicator drawing parameters         |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Orange color is used for the indicator bearish line
#property indicator_color2  clrOrange
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 68.169011381620932846223247325497
#property indicator_level2 50.0
#property indicator_level3 31.830988618379067153776752674503
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method - the enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint TMFIPeriod=10; //TMFI period
input Smooth_Method XMA_Method=MODE_JJMA; //smoothing method
input int XLength=5; //smoothing depth                    
input int XPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
  input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input int Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double MaTMFIBuffer[];
double SignalBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- Declaration of global variables
int Count[];
double Ma[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by the link
                          int Size)
  {
//----
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
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(XMA1.GetStartBars(XMA_Method,TMFIPeriod,XPhase)+XMA1.GetStartBars(XMA_Method,XLength,XPhase)+4);

//---- setting up alerts for unacceptable values of external parameters
   XMA1.XMALengthCheck("XLength", XLength);
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   
//---- Memory distribution for variables' arrays  
   ArrayResize(Count,4);
   ArrayResize(Ma,4);
   ArrayInitialize(Count,0);
   ArrayInitialize(Ma,0.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,MaTMFIBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"MaTMFI(",TMFIPeriod,", ",Smooth,", ",XLength,", ",XPhase,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   long Volume;
   int first,bar,bar1;
   double rel,negative,positive,sumn,sump,tmfi,price;
   static double negative_,positive_;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0; // starting number for calculation of all bars
      negative_=50;
      positive_=50;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- restore values of the variables
   negative=negative_;
   positive=positive_;
   
   bar1=rates_total-2;

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      Ma[Count[0]]=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,TMFIPeriod,price,bar,false);
      
      if(bar<3){Recount_ArrayZeroPos(Count,4); continue;}
      
      sumn=0.0;
      sump=0.0;
      rel=Ma[Count[0]]-Ma[Count[3]]+8*Ma[Count[1]]-8*Ma[Count[2]];
      
       if(VolumeType==VOLUME_TICK) Volume=tick_volume[bar]+2*tick_volume[bar-1]+2*tick_volume[bar-2]+tick_volume[bar-3];
      else  Volume=volume[bar]+2*volume[bar-1]+2*volume[bar-2]+volume[bar-3];

      if(rel>0) sump+=double(Volume);
      else      sumn+=double(Volume);
      
      positive=(positive*(TMFIPeriod-1)+sump)/TMFIPeriod;
      negative=(negative*(TMFIPeriod-1)+sumn)/TMFIPeriod;

      if(negative) tmfi=100.0*(1.0-1.0/(1.0+positive/negative));
      else tmfi=50.0; 
      
      MaTMFIBuffer[bar]=tmfi;      
      SignalBuffer[bar]=XMA2.XMASeries(TMFIPeriod,prev_calculated,rates_total,XMA_Method,XPhase,XLength,tmfi,bar,false);

      //---- memorize values of the variables before running at the current bar
      if(bar==bar1)
        {
         negative_=negative;
         positive_=positive;
        }
        
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,4);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
