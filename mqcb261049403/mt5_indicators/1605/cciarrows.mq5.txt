//+------------------------------------------------------------------+
//|                                                    CCIArrows.mq5 |
//|                                      Copyright © 2009, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, EarnForex"
#property link      "http://www.earnforex.com"
#property description "CCI Arrows - direct trading signals based on CCI indicator."
#property description "Displays red and blue arrows for Short and Long signals."
//---- indicator version number
#property version   "1.20"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  Magenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- bullish indicator label display
#property indicator_label1  "CCIArrows Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- blue color is used for the indicator bullish line
#property indicator_color2  Blue
//---- thickness of the indicator 2 line is equal to 4
#property indicator_width2  4
//---- bearish indicator label display
#property indicator_label2 "CCIArrows Buy"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint CCI_Period=14;  //This value sets the CCI Period Used, The default is 21
input ENUM_APPLIED_PRICE   CCI_Price=PRICE_CLOSE; // price type 
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
int  CCI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables   
   min_rates_total=int(CCI_Period+1);

//---- getting handle of the iCCI indicator
   CCI_Handle=iCCI(Symbol(),PERIOD_CURRENT,CCI_Period,CCI_Price);
   if(CCI_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iCCI indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"CCIArrows Sell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//---- indexing elements in the buffer as in time series
   ArraySetAsSeries(SellBuffer,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"CCIArrows Buy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- indexing elements in the buffer as in time series
   ArraySetAsSeries(BuyBuffer,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="CCIArrows";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(CCI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar;
   double CCI[];

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(CCI,true);

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) //checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   to_copy=limit+2;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;

      if(CCI[bar+1]>=0 && CCI[bar]<0) SellBuffer[bar]=high[bar]+GetRange(high,low,bar);
      if(CCI[bar+1]<=0 && CCI[bar]>0) BuyBuffer[bar]=low[bar]-GetRange(high,low,bar);

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double GetRange(const double &High[],const double &Low[],int index)
  {
//----
   double AvgRange=0.0;
   for(int count=index; count<index+10; count++) AvgRange+=MathAbs(High[count]-Low[count]);
//----
   return(AvgRange/20);
  }
//+------------------------------------------------------------------+
