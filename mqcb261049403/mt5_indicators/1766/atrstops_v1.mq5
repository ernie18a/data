//+------------------------------------------------------------------+
//|                                                  ATRStops_v1.mq5 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2006, Forex-TSD.com "
//--- A link to the author's site
#property link      "http://www.forex-tsd.com/"
//--- Indicator version
#property version   "1.00"
//--- The indicator is drawn in the main window
#property indicator_chart_window
//--- 4 buffers are used for the indicator
#property indicator_buffers 4
//--- 4 graphical constructions are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Parameters of the bullish indicator         |
//+----------------------------------------------+
//--- Indicator 1 is drawn as a line
#property indicator_type1   DRAW_LINE
//--- Blue is used for the indicator line color
#property indicator_color1  clrBlue
//--- Solid line is used for indicator 1
#property indicator_style1  STYLE_SOLID
//--- The width of the indicator 1 is 2
#property indicator_width1  2
//--- The label of the indicator
#property indicator_label1  "Upper ATRStops_v1"
//+----------------------------------------------+
//|  Parameters of the bearish indicator         |
//+----------------------------------------------+
//--- Indicator 2 is drawn as a line
#property indicator_type2   DRAW_LINE
//--- IndianRed is used for the indicator line color
#property indicator_color2  clrIndianRed
//--- Solid line is used for indicator 2
#property indicator_style2  STYLE_SOLID
//--- The width of the indicator 2 is 2
#property indicator_width2  2
//--- The label of the indicator
#property indicator_label2  "Lower ATRStops_v1"
//+----------------------------------------------+
//|  Parameters of the bullish indicator         |
//+----------------------------------------------+
//--- Indicator 3 is drawn as a symbol
#property indicator_type3   DRAW_ARROW
//--- RoyalBlue is used for the indicator line color
#property indicator_color3  clrRoyalBlue
//--- The width of the indicator 3 is 4
#property indicator_width3  4
//--- The label of the indicator
#property indicator_label3  "Buy ATRStops_v1"
//+----------------------------------------------+
//|  Parameters of the bearish indicator         |
//+----------------------------------------------+
//--- Indicator 4 is drawn as a symbol
#property indicator_type4   DRAW_ARROW
//--- DarkOrange is used for the indicator line color
#property indicator_color4  clrDarkOrange
//--- The width of the indicator 4 is 4
#property indicator_width4  4
//--- The label of the indicator
#property indicator_label4  "Sell ATRStops_v1"
//+----------------------------------------------+
//| Input parameters of the indicator            |
//+----------------------------------------------+
input uint   Length=10;           // Indicator period
input uint   ATRPeriod=5;         // Period of ATR
input double Kv=2.5;              // Volatility by ATR
input int    Shift=0;             // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- Declaring dynamic arrays that will
//--- further be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//--- Declaring integer variables for the indicator handles
int ATR_Handle;
//--- Declaring integer variables of data calculation start
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- Getting the handle o the ATR indicator
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }

//--- Initialization of variables of the start of data calculation
   min_rates_total=int(ATRPeriod+Length);

//--- Set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//--- Shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 1 drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---  Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferUp,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//--- Shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferDown,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Set ExtMapBufferUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//--- Shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 3 drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- Indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,163);

//--- Set ExtMapBufferDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//--- Shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 4 drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- Indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,163);

//--- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ATRStops_v1(",Length,", ",ATRPeriod,", ",DoubleToString(Kv,4),", ",Shift,")");
//--- Creating the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Setting the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(0);

//--- declaration of local variables 
   double ATR[];
   double smin0,smax0;
   int limit,to_copy,bar,trend0;
   static double smin1,smax1;
   static int trend1;

//--- indexing elements in arrays as time series  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);

//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
      trend1=0;
      smin1=-100000;
      smax1=+100000;
     }
   else
     {
      limit=rates_total-prev_calculated;                 // starting index for calculation of new bars
     }

   to_copy=int(limit+Length);
//--- Copy the new data to the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(0);

//--- The main loop of the indicator calculation
   for(bar=limit; bar>=0; bar--)
     {      
      ExtMapBufferUp[bar]=EMPTY_VALUE;
      ExtMapBufferDown[bar]=EMPTY_VALUE;
      ExtMapBufferUp1[bar]=EMPTY_VALUE;
      ExtMapBufferDown1[bar]=EMPTY_VALUE;
      
      smin0=-100000;
      smax0=+100000;
      
      for(int iii=0; iii<int(Length); iii++)
        {
         int barx=bar+iii;
         smin0=MathMax(smin0,high[barx]-Kv*ATR[barx]);
         smax0=MathMin(smax0,low[barx]+Kv*ATR[barx]);
        }
        
      trend0=trend1;
      if(close[bar]>smax1) trend0=+1;
      if(close[bar]<smin1) trend0=-1;

      if(trend0>0)
        {
         if(smin0<smin1) smin0=smin1;
         ExtMapBufferUp[bar]=smin0;
        }
        
      if(trend0<0)
        {
         if(smax0>smax1) smax0=smax1;
         ExtMapBufferDown[bar]=smax0;
        }

      if(ExtMapBufferUp[bar+1]==EMPTY_VALUE && ExtMapBufferUp[bar]!=EMPTY_VALUE) ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];
      if(ExtMapBufferDown[bar+1]==EMPTY_VALUE && ExtMapBufferDown[bar]!=EMPTY_VALUE) ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];

      if(bar>0)
        {
         smin1=smin0;
         smax1=smax0;
         trend1=trend0;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
