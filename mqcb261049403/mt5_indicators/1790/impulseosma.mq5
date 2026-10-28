//+---------------------------------------------------------------------+
//|                                                     ImpulseOsMA.mq5 | 
//|                               Copyright © 2008, Nikolay Dzencharski | 
//|                                                  dzenchar@gmail.com | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file |
//| in the directory: terminal_data_folder\MQL5\Include        |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, Nikolay Dzencharski"
#property link "dzenchar@gmail.com" 
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- two plots are used
#property indicator_plots   2

//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the indicator
#property indicator_color1  clrBlueViolet,clrRed
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Up Trend;Down Trend"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color2 clrMagenta,clrBlue,clrTeal
//---- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width2 2
//---- displaying the indicator label
#property indicator_label2 "XMACD"

//+-----------------------------------+
//|  Description of smoothing classes |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3,XMA4;
//+-----------------------------------+
//|  Declaration of enumerations      |
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
input Smooth_Method MACD_Method=MODE_EMA; //Histogram averaging method
input uint Fast_XMA = 12; //Period of fast MA
input uint Slow_XMA = 26; //Period of slow MA
input  int MACD_Phase = 100;  //MA averaging parameter
                       //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ MACD_Price=PRICE_CLOSE_;//MACD price constant

input Smooth_Method Signal_Method=MODE_EMA; //Signal line averaging method
input uint Signal_XMA=9; //Period of the signal line 
input int Signal_Phase=100; // signal line parameter,
                            //varying within the range -100 ... +100,
//affects the transitional process quality;


input Smooth_Method Ma_Method=MODE_SMA; //MA averaging method
input uint Ma=12; //MA period
input int Ma_Phase=100; //MA averaging period,
                       //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ Ma_Price=PRICE_CLOSE_;//MA price constant
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_1;
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double XMACDBuffer[],ColorXMACDBuffer[],SignBuffer[],XSignBuffer[];
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_1=MathMax(XMA1.GetStartBars(MACD_Method,Fast_XMA,MACD_Phase),XMA1.GetStartBars(MACD_Method,Slow_XMA,MACD_Phase))+1;
   int min_rates_2=min_rates_1+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase);
   int min_rates_3=XMA1.GetStartBars(Ma_Method,Ma,Ma_Phase);
   min_rates_total=MathMax(min_rates_2,min_rates_3)+1;

//---- Setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,SignBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,XSignBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,XMACDBuffer,INDICATOR_DATA);    
   SetIndexBuffer(3,ColorXMACDBuffer,INDICATOR_COLOR_INDEX);  
   
//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"ImpulseOsMA");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
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
//---- Checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables
   int first,bar;
//---- Declaring floating point variables  
   double price,fast_xma,slow_xma,xmacd,sign_xma,curMA,cur,prev;
   static double prevMA;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      first=1;
     }
   else // starting number for the calculation of new bars
     {
      first=prev_calculated-1;
     }

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(MACD_Price,bar,open,low,high,close);

      fast_xma=XMA1.XMASeries(1,prev_calculated,rates_total,MACD_Method,MACD_Phase,Fast_XMA,price,bar,false);
      slow_xma=XMA2.XMASeries(1,prev_calculated,rates_total,MACD_Method,MACD_Phase,Slow_XMA,price,bar,false);
      xmacd=(fast_xma-slow_xma)/_Point;
      sign_xma=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xmacd,bar,false);
      cur=xmacd-sign_xma;
      prev=SignBuffer[bar-1]-XSignBuffer[bar-1];

      //---- Loading the obtained values in the indicator buffers            
      SignBuffer[bar]=xmacd;     
      XSignBuffer[bar]=sign_xma;
      XMACDBuffer[bar]=cur*3;
      
      price=PriceSeries(Ma_Price,bar,open,low,high,close);
      curMA=XMA4.XMASeries(1,prev_calculated,rates_total,Ma_Method,Ma_Phase,Ma,price,bar,false);   
            
      int clr=1;
      if(cur>prev && curMA>prevMA) clr=2;
      else if(cur<prev && curMA<prevMA) clr=0;
      ColorXMACDBuffer[bar]=clr;      
      
      if(bar<rates_total-1) prevMA=curMA;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
