//+------------------------------------------------------------------+
//|                                                MACD_On_Chart.mq5 |
//|                               Copyright © 2007, Khashayar Talebi | 
//|                                             http://www.stct.info | 
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2007, Khashayar Talebi"
//--- link to the website of the author
#property link      "http://www.stct.info"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- pink is used for the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- indicator bullish label display
#property indicator_label1  "MACD_On_Chart Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color2  clrLime
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- bearish indicator label display
#property indicator_label2 "MACD_On_Chart Buy"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0   // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint FastEMA=12;
input uint SlowEMA=26;
input uint SignalSMA=9;
input ENUM_APPLIED_PRICE  Applied_Price=PRICE_CLOSE;
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//--- declaration of integer variables for the indicators handles
int Macd_Handle,ATR_Handle;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables 
   int ATR_Period=15;
   min_rates_total=int(MathMax(FastEMA,SlowEMA)+SignalSMA+1);
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
//--- getting the handle of the iMACD indicator
   Macd_Handle=iMACD(Symbol(),PERIOD_CURRENT,FastEMA,SlowEMA,SignalSMA,Applied_Price);
   if(Macd_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iMACD");
      return(INIT_FAILED);
     }
//---- getting the handle of the ATR indicator
   ATR_Handle=iATR(Symbol(),PERIOD_CURRENT,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="MACD_On_Chart";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- initialization end
   return(INIT_SUCCEEDED);
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
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(Macd_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double MACD[],SIGN[],ATR[];
//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }
   to_copy=limit+2; // calculated number of copied bars
//--- copy newly appeared data in the arrays
   if(CopyBuffer(Macd_Handle,MAIN_LINE,0,to_copy,MACD)<=0) return(RESET);
   if(CopyBuffer(Macd_Handle,SIGNAL_LINE,0,to_copy,SIGN)<=0) return(RESET);
   to_copy--;
   if(CopyBuffer(ATR_Handle,MAIN_LINE,0,to_copy,ATR)<=0) return(RESET);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(MACD,true);
   ArraySetAsSeries(SIGN,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      if(MACD[bar]>SIGN[bar] && MACD[bar+1]<= SIGN[bar+1]) BuyBuffer [bar]=low [bar]-ATR[bar]*3/8;
      if(MACD[bar]<SIGN[bar] && MACD[bar+1]>= SIGN[bar+1]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
