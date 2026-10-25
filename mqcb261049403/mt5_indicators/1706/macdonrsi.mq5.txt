//+------------------------------------------------------------------+
//|                                                    MACDonRSI.mq5 |
//|                                Copyright © 2008, Alexey Sergeyev |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008, Alexey Sergeyev"
//---- author of the indicator
#property link      ""
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- four buffers are used for the indicator calculation and drawing
#property indicator_buffers 4
//---- 3 plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrMagenta,clrIndianRed,clrGray,clrBlueViolet,clrDodgerBlue
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1  "Histogram MACDonRSI"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+

//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Green color is used as the color of the indicator line
#property indicator_color2  clrGreen
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "RSI MACDonRSI"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 3 as line
#property indicator_type3   DRAW_LINE
//---- Red color is used as the color of the indicator line
#property indicator_color3  clrRed
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- displaying the indicator label
#property indicator_label3  "Signal MACDonRSI"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
//---- Moving Average parameters
input uint                 MAPeriod=13;
input  ENUM_MA_METHOD      MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
//---- RSI parameters
input uint                 RSIPeriod=14;
//---- MACD parameters
input int                  FastMACD=12;
input int                  SlowMACD=26;
input int                  SignalMACD=9;

input int                  Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double RSIBuffer[];
double SigBuffer[];
double MacdBuffer[];
double ColorMacdBuffer[];

//---- Declaration of integer variables for the indicator handles
int MA_Handle,RSI_Handle,MACD_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(MAPeriod+RSIPeriod+MathMax(FastMACD,SlowMACD)+SignalMACD+1);
   
//---- getting the iMA indicator handle
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");
   
//---- getting handle of the iRSI indicator
   RSI_Handle=iRSI(NULL,0,RSIPeriod,MA_Handle);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iRSI indicator");

//---- getting handle of the iMACD indicator
   MACD_Handle=iMACD(NULL,0,FastMACD,SlowMACD,SignalMACD,RSI_Handle);
   if(MACD_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMACD indicator");

//---- set XMACDBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,MacdBuffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MacdBuffer,true);
   
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(1,ColorMacdBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorMacdBuffer,true);
   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,RSIBuffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(RSIBuffer,true);
   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,SigBuffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SigBuffer,true);
   
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"MACDonRSI");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(MACD_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,to_copy,clr;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1; // starting number for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting number for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy the new data into the array     
   if(CopyBuffer(MACD_Handle,MAIN_LINE,0,to_copy,MacdBuffer)<=0) return(RESET);
   if(CopyBuffer(MACD_Handle,SIGNAL_LINE,0,to_copy,SigBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle,MAIN_LINE,0,to_copy,RSIBuffer)<=0) return(RESET);


//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MacdBuffer[bar]*=8;
      SigBuffer[bar]*=8;
     }    
      
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;  
//---- Main loop of the MACD indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      clr=2;
      
      if(MacdBuffer[bar]>0)
        {
         if(MacdBuffer[bar]>MacdBuffer[bar+1]) clr=4;
         if(MacdBuffer[bar]<MacdBuffer[bar+1]) clr=3;
        }

      if(MacdBuffer[bar]<0)
        {
         if(MacdBuffer[bar]<MacdBuffer[bar+1]) clr=0;
         if(MacdBuffer[bar]>MacdBuffer[bar+1]) clr=1;
        }
        
      ColorMacdBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
