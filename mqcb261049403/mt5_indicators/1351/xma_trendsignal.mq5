//+---------------------------------------------------------------------+
//|                                                 XMA_TrendSignal.mq5 | 
//|                                  Copyright © 2011, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Indicator of the maximal trend"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a multy-color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the histogram
#property indicator_color1  clrMagenta,clrOrangeRed,clrPurple,clrGray,clrMediumBlue,clrDodgerBlue,clrLime
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "XMA_TrendSignal"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0   // The constant for getting the command for the indicator recalculation back to the terminal

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
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
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
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
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_T3;  // smoothing method
input int XLength=12;                    // smoothing depth                    
input int XPhase=15;                     // smoothing parameter,
                                         // for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_DEMARK_;  // price constant
input uint MomPeriod=1;                  // Period for the difference
input uint MA1_Level=20;                 // Flat trigger
input uint MA2_Level=60;                 // Trend trigger                            
input int Shift=0;                       // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//----
double dLevel1,dLevel2;
//---- Declaration of integer variables of data starting point
int min_rates_total,MomPeriod1;
//---- declaration of global variables
int Count[];
double XMA[];
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
//| XMA_TrendSignal indicator initialization function                | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=XMA1.GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_total+=int(MomPeriod);
   MomPeriod1=int(MomPeriod)+1;
//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//----  
   dLevel1=_Point*MA1_Level;
   dLevel2=_Point*MA2_Level;

//---- memory allocation for arrays of variables  
   ArrayResize(Count,MomPeriod1);
   ArrayResize(XMA,MomPeriod1);

   ArrayInitialize(Count,0);
   ArrayInitialize(XMA,0.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
   
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"XMA_TrendSignal(",XLength,", ",Shift,")");
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,5);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+2.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,+1.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-1.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,-2.0);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrChocolate);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrChocolate);
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASHDOTDOT);

//---- end of initialization
   return(0);
  }
//+------------------------------------------------------------------+ 
//| XMA_TrendSignal iteration function                               | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of variables with a floating point 
   double price_,dxma,res,clr;
//---- Declaration of integer variables
   int first,bar,rates_tot1;
   
   rates_tot1=rates_total-1;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0; // starting number for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      XMA[Count[0]]=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price_,bar,false);
      dxma=XMA[Count[0]]-XMA[Count[MomPeriod]];
      //----
      res=0;
      clr=3;
      //----      
      if(dxma>+dLevel2) {res=+3; clr=6;} else if(dxma>+dLevel1) {res=+2; clr=5;} else if(dxma>0) {res=+1; clr=4;}
      if(dxma<-dLevel2) {res=-3; clr=0;} else if(dxma<-dLevel1) {res=-2; clr=1;} else if(dxma<0) {res=-1; clr=2;}
      //----
      IndBuffer[bar]=res;
      ColorIndBuffer[bar]=clr;
      //----
      if(bar<rates_tot1) Recount_ArrayZeroPos(Count,MomPeriod1);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
