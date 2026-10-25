/*
 * For the indicator to work, place the file
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                                  ColorGXMACD.mq5 | 
//|                                    Copyright 2012, Guriev Invest | 
//|                                   http://www.gurievinvest.org.ua | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2012, Guriev Invest"
#property link "http://www.gurievinvest.org.ua" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 6
#property indicator_buffers 6 
//---- only four plots are used
#property indicator_plots   4
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a cloud
#property indicator_type1 DRAW_FILLING
//---- colors of the cloud are as follows
#property indicator_color1 BlueViolet,Magenta
//---- displaying the indicator label
#property indicator_label1 "GXMACD Cloud"

//---- drawing the indicator as a four-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color2 Gray,Teal,BlueViolet,IndianRed,Magenta
//---- indicator line is a solid line
#property indicator_style2 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width2 2
//---- displaying the indicator label
#property indicator_label2 "GXMACD"

//---- drawing the indicator as a line
#property indicator_type3 DRAW_LINE
//---- colors of the three-color line are as follows
#property indicator_color3 Lime
//---- indicator line is a solid line
#property indicator_style3 STYLE_SOLID
//---- indicator line width is 1
#property indicator_width3 1
//---- displaying label of the signal line
#property indicator_label3  "Line"

//---- drawing the indicator as a line
#property indicator_type4 DRAW_LINE
//---- colors of the three-color line are as follows
#property indicator_color4 Red
//---- indicator line is a solid line
#property indicator_style4 STYLE_SOLID
//---- indicator line width is 1
#property indicator_width4 1
//---- displaying label of the signal line
#property indicator_label4  "Signal Line"
//+-----------------------------------+
//|  Smoothing classes description      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
//+-----------------------------------+
//|  declaration of enumerations          |
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
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
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_T3; //histogram smoothing method
input int Fast_XMA = 12; //fast moving average period
input int Slow_XMA = 26; //slow moving average period
input int XPhase= 100;  //moving averages smoothing parameter,
                       //for JJMA, it varies within the range -100 ... +100 and influences the quality of the transient period;
// For VIDIA, it is the CMO period, for AMA, it is the period of slow moving average
input Smooth_Method Signal_Method=MODE_JJMA; //signal line smoothing method
input int Signal_XMA=9; //signal line period 
input int Signal_Phase=100; // signal line parameter,
                            //varying within the range -100 ... +100,
//it influences the quality of the transient period;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int start,macd_start;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double LineBuffer[],SignBuffer[],CLineBuffer[],CSignBuffer[];
double XMACDBuffer[],ColorXMACDBuffer[];
//+------------------------------------------------------------------+
// The iPriceSeries function description                                     |
// The Moving_Average class description                                    | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| GXMACD indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data starting point
   macd_start=MathMax(XMA1.GetStartBars(XMA_Method,Fast_XMA,XPhase),XMA1.GetStartBars(XMA_Method,Slow_XMA,XPhase));
   start=macd_start+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase);

//---- transformation of the dynamic array CLineBuffer into an indicator buffer
   SetIndexBuffer(0,CLineBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);

//---- transformation of the dynamic array CSignBuffer into an indicator buffer
   SetIndexBuffer(1,CSignBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);   

//---- transformation of the dynamic array XMACDBuffer into an indicator buffer
   SetIndexBuffer(2,XMACDBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,macd_start);
//---- setting the indicator values that will not be visible in the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- transformation of the dynamic array into a color index buffer   
   SetIndexBuffer(3,ColorXMACDBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,macd_start+1);
   
//---- transformation of the dynamic array LineBuffer into an indicator buffer
   SetIndexBuffer(4,LineBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,macd_start);

//---- transformation of the dynamic array SignBuffer into an indicator buffer
   SetIndexBuffer(5,SignBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,macd_start);   

//---- setting up alerts for invalid values of external variables
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//---- setting up alerts for invalid values of external variables
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XMA1.XMAPhaseCheck("Signal_Phase", Signal_Phase, Signal_Method);

//---- initializations of a variable for a short name of the indicator
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname, "GXMACD( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- creating a name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| GXMACD iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
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
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<start) return(0);

//---- Declaration of integer variables
   int first1,first2,bar;
//---- Declaration of variables with a floating point  
   double price_,fast_xma,slow_xma,xmacd,sign_xma;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      first1=0; // starting number for the calculation of all bars in the first loop
      first2=macd_start+1; // starting number for the calculation of all bars in the second loop
     }
   else // starting number for the calculation of new bars
     {
      first1=prev_calculated-1;
      first2=first1;
     }

//---- Main calculation loop of the indicator
   for(bar=first1; bar<rates_total; bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);;

      fast_xma = XMA1.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Fast_XMA, price_, bar, false);
      slow_xma = XMA2.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Slow_XMA, price_, bar, false);

      xmacd=fast_xma-slow_xma;
      LineBuffer[bar]=xmacd;
      CLineBuffer[bar]=xmacd;
      sign_xma=XMA3.XMASeries(macd_start,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xmacd,bar,false);

      //---- Loading the obtained values in the indicator buffers      
      XMACDBuffer[bar]= xmacd-sign_xma;
      SignBuffer[bar] = sign_xma;
      CSignBuffer[bar] = sign_xma;
     }

//---- Main coloring loop of the XMACD indicator
   for(bar=first2; bar<rates_total; bar++)
     {
      ColorXMACDBuffer[bar]=0;

      if(XMACDBuffer[bar]>0)
        {
         if(XMACDBuffer[bar]>XMACDBuffer[bar-1]) ColorXMACDBuffer[bar]=1;
         if(XMACDBuffer[bar]<XMACDBuffer[bar-1]) ColorXMACDBuffer[bar]=2;
        }

      if(XMACDBuffer[bar]<0)
        {
         if(XMACDBuffer[bar]<XMACDBuffer[bar-1]) ColorXMACDBuffer[bar]=3;
         if(XMACDBuffer[bar]>XMACDBuffer[bar-1]) ColorXMACDBuffer[bar]=4;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
