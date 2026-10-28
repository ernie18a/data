//+---------------------------------------------------------------------+
//|                                            ColorBlauErgodicMACD.mq5 |
//|                                  Copyright © 2013, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file    |
//| in the directory: terminal_data_folder\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- Indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- the following colors are used in the color histogram
#property indicator_color1 clrMediumVioletRed,clrDarkOrange,clrGray,clrCornflowerBlue,clrMediumBlue
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1 2
//--- displaying the indicator label
#property indicator_label1 "Blau Ergodic MACD"

//---- drawing the indicator as a three-colored line
#property indicator_type2 DRAW_COLOR_LINE
//---- the following colors are used in a three-color line
#property indicator_color2 clrMagenta,clrGray,clrLimeGreen
//---- indicator line is a solid curve
#property indicator_style2 STYLE_SOLID
//--- indicator line width is 4
#property indicator_width2 4
//---- displaying the signal line label
#property indicator_label2  "Signal Line"
//+-----------------------------------+
//|  Description of smoothing classes |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
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
//| Input parameters                  |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_EMA;        // Histogram averaging method
input int Fast_XMA=5;                           // Period of the fast MA
input int Slow_XMA = 20;                        // Period of the slow MA
input int XPhase = 100;                         // MA averaging parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input int MACD_XMA=3;                           // Smoothing period of the MACD histogram
input Smooth_Method Signal_Method=MODE_EMA;     // Signal line averaging method
input int Signal_XMA=3;                         // Period of the signal line 
input int Signal_Phase=100;                     // Parameter of the signal line
input Applied_price_ AppliedPrice=PRICE_CLOSE_; // Price constant
//--- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_1,min_rates_2;
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double XMACDBuffer[],SignBuffer[],ColorXMACDBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_1=MathMax(XMA1.GetStartBars(XMA_Method,Fast_XMA,XPhase),XMA1.GetStartBars(XMA_Method,Slow_XMA,XPhase));
   min_rates_2=min_rates_1+XMA1.GetStartBars(XMA_Method,MACD_XMA,XPhase);
   min_rates_total=min_rates_2+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase)+2;

//--- set XMACDBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,XMACDBuffer,INDICATOR_DATA);

//--- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorXMACDBuffer,INDICATOR_COLOR_INDEX);
//--- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);

//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
   XMA1.XMALengthCheck("MACD_XMA", MACD_XMA);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XMA1.XMAPhaseCheck("Signal_Phase", Signal_Phase, Signal_Method);

//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,
                     "ColorBlauErgodicMACD( ",Fast_XMA,", ",Slow_XMA,", ",MACD_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
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

//--- declaration of integer variables
   int first,clr,bar;
//--- declaration of variables with a floating point  
   double price_,fast_xma,slow_xma,xmacd,xxmacd,sign;

//--- initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all first loop bars
     }
   else        // starting index for calculation of new bars
     {
      first=prev_calculated-1;
     }

//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);

      fast_xma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Fast_XMA,price_,bar,false);
      slow_xma=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Slow_XMA,price_,bar,false);

      xmacd=fast_xma-slow_xma;
      xxmacd=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,MACD_XMA,xmacd,bar,false);
      sign=XMA4.XMASeries(min_rates_2,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xxmacd,bar,false);

      //--- Loading the obtained values in the indicator buffers      
      XMACDBuffer[bar]=xxmacd;
      SignBuffer[bar]=sign;
     }

   if(prev_calculated>rates_total || prev_calculated<=0) first=min_rates_total;
//--- Main cycle of the histogram coloring
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=2;

      if(XMACDBuffer[bar]>0)
        {
         if(XMACDBuffer[bar]>XMACDBuffer[bar-1]) clr=4;
         if(XMACDBuffer[bar]<XMACDBuffer[bar-1]) clr=3;
        }

      if(XMACDBuffer[bar]<0)
        {
         if(XMACDBuffer[bar]<XMACDBuffer[bar-1]) clr=0;
         if(XMACDBuffer[bar]>XMACDBuffer[bar-1]) clr=1;
        }

      ColorXMACDBuffer[bar]=clr;
     }

//--- main loop of the signal line coloring
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=1;
      if(XMACDBuffer[bar]>SignBuffer[bar-1]) clr=2;
      if(XMACDBuffer[bar]<SignBuffer[bar-1]) clr=0;
      ColorSignBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
