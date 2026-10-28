//+---------------------------------------------------------------------+ 
//|                                         Cronex_Impulse_CD_Color.mq5 | 
//|                                            Copyright © 2007, Cronex | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| For the indicator to operate locate SmoothAlgorithms.mqh |
//| in the following directory: terminal_data_directory\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, Cronex"
#property link "" 
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in a separate window
#property indicator_separate_window 
//---- Number of indicator buffers is 2
#property indicator_buffers 4 
//---- Two graphical constructions used
#property indicator_plots   4
//+------------------------------------+
//|  Parameters for drawing indicator 1|
//+------------------------------------+
//---- Indicator drawn as a histogram
#property indicator_type1 DRAW_HISTOGRAM
//---- MediumSlateBlue is used as the color of the MACD diagram
#property indicator_color1 clrMediumSlateBlue
//---- Width if the indicator line is 2
#property indicator_width1 2
//---- Indicator label
#property indicator_label1 "Impulse CD XMACD"

//+------------------------------------+
//|  Parameters for drawing indicator 2|
//+------------------------------------+
//---- Indicator drawn as a line
#property indicator_type2 DRAW_LINE
//---- Coral i used as the color of the signal line
#property indicator_color2 clrCoral
//---- The indicator line is solid
#property indicator_style2 STYLE_SOLID
//---- Width of the indicator line is 1
#property indicator_width2 2
//---- Label of the signal line
#property indicator_label2  "Impulse CD Signal Line"

//+------------------------------------+
//|  Parameters for drawing indicator 3|
//+------------------------------------+
//---- Indicator drawn as a histogram
#property indicator_type3 DRAW_HISTOGRAM
//---- Lime is used as the color of the MACD diagram
#property indicator_color3 clrLime
//---- Indicator line width is 2
#property indicator_width3 2
//---- Indicator label
#property indicator_label3 "Impulse CD Upper"

//+------------------------------------+
//|  Parameters for drawing indicator 4|
//+------------------------------------+
//---- Indicator drawn as a histogram
#property indicator_type4 DRAW_HISTOGRAM
//---- Red is used as the color of the MACD diagram
#property indicator_color4 clrRed
//---- Indicator line width is 2
#property indicator_width4 2
//---- Indicator label
#property indicator_label4 "Impulse CD Lower"


//+-----------------------------------+
//|  Description of averaging classes |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- Declaring variables of the CXMA class from file SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3,XMA4;
//+-----------------------------------+
//|  Declaring enumerations           |
//+-----------------------------------+
/*enum Smooth_Method - the enumeration is declared in file SmoothAlgorithms.mqh
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
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_T3; //Histogram averaging method
input uint Fast_XMA = 12; //Period of a fast MA
input uint Slow_XMA = 26; //Period of a slow MA
input int XPhase = 100;  //MA averaging parameter,
                       //for JJMA changing within -100 ... +100, affects the quality of the transient process;
// For VIDIA it is CMO period, for AMA it is the period of a slow MA
input Smooth_Method Signal_Method=MODE_JJMA; //Method of averaging o the signal line
input uint Signal_XMA = 9; //Period of the signal line
input int Signal_Phase = 100; // Parameter of the signal line
                     //varying within the range of -100 ... +100,
//affects the quality of the transient process;
//+-----------------------------------+
//---- Indicator buffers
double MACDBuffer[],SignBuffer[],UpCDDivrBuffer[],DnCDDivrBuffer[];

int min_rates_total,min_rates_; 
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=MathMax(XMA1.GetStartBars(XMA_Method,Fast_XMA,XPhase),XMA1.GetStartBars(XMA_Method,Slow_XMA,XPhase));
   min_rates_total=min_rates_+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase)+1;
   
//---- set the dynamic array MACDBuffer as an indicator buffer
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,UpCDDivrBuffer,INDICATOR_DATA);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(3,DnCDDivrBuffer,INDICATOR_DATA);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Fast_XMA",Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA",Slow_XMA);
   XMA1.XMALengthCheck("Signal_XMA",Signal_XMA);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
   XMA1.XMAPhaseCheck("Signal_Phase",Signal_Phase,Signal_Method);
   
//---- Initializations of variable for indicator short name
   string shortname;  
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"Cronex_Impulse_CD_Color(",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
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
   double price,fast_xma,hslow_xma,lslow_xma,xmacd,sign_xma;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting number for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      price=PriceSeries(PRICE_WEIGHTED,bar,open,low,high,close);
      fast_xma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Fast_XMA,price,bar,false);
      hslow_xma=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Slow_XMA,high[bar],bar,false);
      lslow_xma=XMA3.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Slow_XMA,low[bar],bar,false);
      
      xmacd=0.0;
      if(fast_xma>hslow_xma) xmacd=fast_xma-hslow_xma;     
      if(fast_xma<lslow_xma) xmacd=fast_xma-lslow_xma;  
      
      sign_xma=XMA4.XMASeries(min_rates_,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xmacd,bar,false);

      //---- Loading the obtained values in the indicator buffers      
      MACDBuffer[bar]=xmacd;
      SignBuffer[bar]=sign_xma;
      
      if(!bar) continue;
      double res0=xmacd-sign_xma;
      double res1=MACDBuffer[bar-1]-SignBuffer[bar-1];
      DnCDDivrBuffer[bar]=UpCDDivrBuffer[bar]=EMPTY_VALUE;
      if(res0>=res1) UpCDDivrBuffer[bar]=res0;
      else DnCDDivrBuffer[bar]=res0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
