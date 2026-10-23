//+------------------------------------------------------------------+
//|                                               ColorXMACD_HTF.mq5 |
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| For the indicator to work, place the SmoothAlgorithms.mqh        |
//| in the directory: MetaTrader\\MQL5\Include                       |
//| ColorXMACD.mq5 in the directory: MetaTrader\\MQL5\Indicators     |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers 4
#property indicator_buffers 4 
//--- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- the following colors are used in the four color histogram
#property indicator_color1 Gray,Teal,BlueViolet,IndianRed,Magenta
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is equal to 5
#property indicator_width1 5
//--- displaying the indicator label
#property indicator_label1 "XMACD HTF"

//--- drawing the indicator as colored labels
#property indicator_type2 DRAW_COLOR_ARROW
//--- the following colors are used in a signal line
#property indicator_color2 Gray,Lime,Red
//--- indicator width is equal to 5
#property indicator_width2 5
//--- displaying label of the signal line
#property indicator_label2  "Signal Line"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Averagings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
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
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Chart period
input Smooth_Method XMA_Method=MODE_T3; //histogram smoothing method
input int Fast_XMA = 12; ///Fast moving average period
input int Slow_XMA = 26; //Slow moving average period
input int XPhase=100;  //moving averages smoothing parameter,
                       // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method Signal_Method=MODE_JJMA; //Signal line smoothing method
input int Signal_XMA=9; //signal line period 
input int Signal_XPhase=100; //Ssignal line parameter,
                             //that changes within the range -100 ... +100,
//impacts the transitional process quality;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input bool ReDraw=false; //repeat display of information in the empty bars
//+-----------------------------------+
//--- Declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int XMACD_Handle;
//--- declaration of dynamic arrays that further 
//--- will be used as indicator buffers
double XMACDBuffer[],SignBuffer[],ColorXMACDBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- Initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;

//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("ColorXMACD indicator chart period cannot be less than the current chart period");
      Init=false;
      return;
     }

//--- getting handle of the ColorXMACD indicator
   XMACD_Handle=iCustom(Symbol(),TimeFrame,"ColorXMACD",XMA_Method,Fast_XMA,Slow_XMA,XPhase,Signal_Method,Signal_XMA,Signal_XPhase,AppliedPrice);
   if(XMACD_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ColorXMACD indicator");
      Init=false;
      return;
     }

//--- set XMACDBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,XMACDBuffer,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XMACD_HTF");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(XMACDBuffer,true);

//--- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorXMACDBuffer,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorXMACDBuffer,true);

//--- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Signal XMA");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SignBuffer,true);

//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorSignBuffer,true);

//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
   CXMA XMA;
   string Smooth1=XMA.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA.GetString_MA_Method(Signal_Method);
//--- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"XMACD HTF( ",GetStringTimeframe(TimeFrame),", ",
                     Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- end of initialization
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
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
//--- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(XMACD_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- Declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double XMACD[2],SIGN[2];
   datetime XMACDTime[1];
   static uint LastCountBar;

//--- calculations of the necessary amount of data to be copied and
//---the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      XMACDBuffer[bar]=EMPTY_VALUE;
      SignBuffer[bar]=EMPTY_VALUE;
      ColorXMACDBuffer[bar]=0;
      ColorSignBuffer[bar]=0;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,XMACDTime)<=0) return(RESET);

      if(time[bar]>=XMACDTime[0] && time[bar+1]<XMACDTime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(XMACD_Handle,0,time[bar],2,XMACD)<=0) return(RESET);
         if(CopyBuffer(XMACD_Handle,2,time[bar],2,SIGN)<=0) return(RESET);
         //--- loading the obtained values in the indicator buffers
         XMACDBuffer[bar]=XMACD[1];
         SignBuffer[bar]=SIGN[1];
         if(XMACDBuffer[bar]>0)
           {
            if(XMACD[1]>XMACD[0]) ColorXMACDBuffer[bar]=1;
            if(XMACD[1]<XMACD[0]) ColorXMACDBuffer[bar]=2;
           }
         if(XMACDBuffer[bar]<0)
           {
            if(XMACD[1]<XMACD[0]) ColorXMACDBuffer[bar]=3;
            if(XMACD[1]>XMACD[0]) ColorXMACDBuffer[bar]=4;
           }
         if(XMACDBuffer[bar]>SignBuffer[bar]) ColorSignBuffer[bar]=1;
         if(XMACDBuffer[bar]<SignBuffer[bar]) ColorSignBuffer[bar]=2;
        }

      if(ReDraw)
        {
         if(XMACDBuffer[bar+1]!=EMPTY_VALUE && XMACDBuffer[bar]==EMPTY_VALUE)
           {
            XMACDBuffer[bar]=XMACDBuffer[bar+1];
            ColorXMACDBuffer[bar]=ColorXMACDBuffer[bar+1];
            SignBuffer[bar]=SignBuffer[bar+1];
            ColorSignBuffer[bar]=ColorSignBuffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
