//+---------------------------------------------------------------------+ 
//|                                                  ytg_Price_Peak.mq5 | 
//|                                      Copyright © 2009, Yuriy Tokman | 
//|                                               yuriytokman@gmail.com | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link "yuriytokman@gmail.com"
#property description "Indicator of the peak price values"
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
#property indicator_color1  clrBlueViolet,clrGray,clrMagenta
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "ytg_Price_Peak"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
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
//|  Declaration of enumerations      |
//+-----------------------------------+
enum VolumeMode
  {
   VOLUME_TICK_,  //Tick volume
   VOLUME_REAL_,  //Trade volume
   NO_VOLUME      //Without volume
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_EMA; //first smoothing averaging method 
input uint Length1=5; //first smoothing depth                    
input int Phase1=15; //first smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method MA_Method2=MODE_EMA; //second smoothing averaging method 
input uint Length2=12; //second smoothing depth 
input int Phase2=15;  //second smoothing parameter,
                      // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input VolumeMode VolumeType=NO_VOLUME;  //volume
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];

//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+   
//| ytg_Price_Peak indicator initialization function                 | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=MathMax(min_rates_1,min_rates_2)+1;
//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

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
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"ytg_Price_Peak(",Length1,", ",Length2,", ",Smooth1,", ",
                     Smooth2,", ",EnumToString(IPC),", ",EnumToString(VolumeType),", ",Shift,")");
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| ytg_Price_Peak iteration function                                | 
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
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double price_,xma1,xma2,macd,XL,XH;
//---- Declaration of integer variables
   int first,bar;
   long Volume=1;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- Two calls of the XMASeries function.  
      xma1=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price_,bar,false);
      xma2=XMA2.XMASeries(0,prev_calculated,rates_total,MA_Method2,Phase2,Length2,price_,bar,false);

      switch(VolumeType)
        {
         case int(VOLUME_TICK): Volume=tick_volume[bar]; break;
         case int(VOLUME_REAL): Volume=volume[bar]; break;
         case NO_VOLUME: Volume=1;
        }

      macd=xma1-xma2;
      XL =low[bar]-xma1;
      XH =high[bar]-xma1;
      ColorIndBuffer[bar]=1;
      IndBuffer[bar]=0.0;

      if(macd>0&&XL>0) {IndBuffer[bar]=XL*Volume/_Point; ColorIndBuffer[bar]=0;}
      if(macd<0&&XH<0) {IndBuffer[bar]=XH*Volume/_Point; ColorIndBuffer[bar]=2;}
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
