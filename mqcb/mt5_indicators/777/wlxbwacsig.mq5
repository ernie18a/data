//+------------------------------------------------------------------+
//|                                                   wlxBWACsig.mq5 |
//|                                          Copyright © 2005, wellx |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, wellx"
//---- link to the website of the author
#property link      ""
//---- indicator version
#property version   "1.01"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- DeepPink color is used for the indicator
#property indicator_color1  DeepPink
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- bullish indicator label display
#property indicator_label1  "wlxBWACsig Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type2   DRAW_ARROW
//---- Aqua color is used for the indicator
#property indicator_color2  Aqua
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- displaying the indicator label
#property indicator_label2 "wlxBWACsig Buy"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---
bool uptrend_,old;
int AC_Handle,ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=40;

//---- getting handle of the AC indicator
   AC_Handle=iAC(NULL,0);
   if(AC_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iAC indicator");

//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,15);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");

//---- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"wlxBWACsig Sell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- indexing the elements in the buffer as time series
   ArraySetAsSeries(SellBuffer,true);

//---- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"wlxBWACsig Buy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- indexing the elements in the buffer as time series
   ArraySetAsSeries(BuyBuffer,true);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="wlxBWACsigSig";
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(AC_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declarations of local variables 
   int to_copy,limit,bar,bar1,bar2,bar3,bar4;
   double AC[],ATR[];

//--- calculations of the necessary amount of data to be copied and
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total;   // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//--- copy newly appeared data in the arrays
   to_copy=limit+1;
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy+=4;
   if(CopyBuffer(AC_Handle,0,0,to_copy,AC)<=0) return(RESET);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(AC,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      bar1=bar+1;
      bar2=bar+2;
      bar3=bar+3;
      bar4=bar+4;

      if(((AC[bar3]>0 && AC[bar2]>0 && AC[bar1]>0 && AC[bar]>0) && (AC[bar3]>AC[bar2] && AC[bar1]>AC[bar2] && AC[bar]>AC[bar1]))
         || ((AC[bar3]<0 && AC[bar2]<0 && AC[bar1]<0 && AC[bar]>0) && (AC[bar3]>AC[bar2] && AC[bar1]>AC[bar2] && AC[bar]>AC[bar1]))
         || ((AC[bar4]<0 && AC[bar3]<0 && AC[bar2]<0 && AC[bar1]<0 && AC[bar]<0)
         && (AC[bar4]>AC[bar3] && AC[bar3]<AC[bar2] && AC[bar2]<AC[bar1] && AC[bar1]<AC[bar])))
         SellBuffer[bar]=high[bar]+ATR[bar]*3/8;

      if(((AC[bar3]<0 && AC[bar2]<0 && AC[bar1]<0 && AC[bar]<0) && (AC[bar3]<AC[bar2] && AC[bar1]<AC[bar2] && AC[bar]<AC[bar1]))
         || ((AC[bar3]>0 && AC[bar2]>0 && AC[bar1]>0 && AC[bar]<0) && (AC[bar3]<AC[bar2] && AC[bar1]<AC[bar2] && AC[bar]<AC[bar1]))
         || ((AC[bar4]>0 && AC[bar3]>0 && AC[bar2]>0 && AC[bar1]>0 && AC[bar]>0)
         && (AC[bar4]<AC[bar3] && AC[bar3]>AC[bar2] && AC[bar2]>AC[bar1] && AC[bar1]>AC[bar])))
         BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
