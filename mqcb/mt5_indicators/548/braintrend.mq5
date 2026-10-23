//+------------------------------------------------------------------+
//|                                                   BrainTrend.mq5 |
//|                               Copyright © 2005, BrainTrading Inc |
//|                                      http://www.braintrading.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, BrainTrading Inc."
//---- link to the website of the author
#property link      "http://www.braintrading.com/"
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- four buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- four plots are used in total
#property indicator_plots   4
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- red color is used for the indicator bearish line
#property indicator_color1  Red
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Brain1Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- BlueViolet color is used as the color of the bullish indicator line
#property indicator_color2  BlueViolet
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2 "Brain1Buy"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- red color is used for the indicator bearish line
#property indicator_color3  Red
//---- indicator 3 line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Brain2Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- BlueViolet color is used as the color of the bullish indicator line
#property indicator_color4  BlueViolet
//---- indicator 4 line width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4 "Brain2Buy"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 0.8
#property indicator_levelcolor Black
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------+
//| Window vertical borders fixing               |
//+----------------------------------------------+
#property indicator_maximum +1.2
#property indicator_minimum +0.4
//+----------------------------------------------+
//| BrainTrend1 indicator input parameters       |
//+----------------------------------------------+
input int ATR_Period=7;                     // ATR period 
input int STO_Period=9;                     // Stochastic period
input ENUM_MA_METHOD MA_Method=MODE_SMA;    // Smoothing method
input ENUM_STO_PRICE STO_Price=STO_LOWHIGH; // Prices calculation method
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double SellBuffer1[];
double BuyBuffer1[];
double SellBuffer2[];
double BuyBuffer2[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int Brain1_Handle,Brain2_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- initialization of global variables 
   min_rates_total=MathMax(ATR_Period,STO_Period)+2;
//---- getting handle of the BrainTrend1 indicator
   Brain1_Handle=iCustom(NULL,0,"BrainTrend1",ATR_Period,STO_Period,MA_Method,STO_Price);
   if(Brain1_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the BrainTrend1 indicator");
      return(1);
     }
//---- getting handle of the BrainTrend2 indicator
   Brain2_Handle=iCustom(NULL,0,"BrainTrend2",ATR_Period);
   if(Brain2_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the BrainTrend2 indicator");
      return(1);
     }

//---- set SellBuffer1[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer1,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,167);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer1,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- set BuyBuffer1[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer1,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,167);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer1,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- set SellBuffer2[] dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer2,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer2,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- set BuyBuffer2[] dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer2,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer2,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- name for the data window and the label for sub-windows 
   string short_name="BrainTrend";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- 
   return(0);
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
   if(BarsCalculated(Brain1_Handle)<rates_total
      || BarsCalculated(Brain2_Handle)<rates_total
      || rates_total<min_rates_total)
      return(0);

//---- declarations of local variables 
   int to_copy,limit,bar;
   double Brain1[],Brain2[];

//---- calculations of the necessary amount of data to be copied and
//---- the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total;               // calculated number of all bars
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated+1; // calculated number of new bars only
      limit=rates_total-prev_calculated;     // starting index for calculation of new bars
     }

//---- copy the newly appeared data into the Range[] and value2[] arrays
   if(CopyBuffer(Brain1_Handle,4,0,to_copy,Brain1)<=0) return(0);
   if(CopyBuffer(Brain2_Handle,4,0,to_copy,Brain2)<=0) return(0);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Brain1,true);
   ArraySetAsSeries(Brain2,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      BuyBuffer1[bar]=0.0;
      BuyBuffer2[bar]=0.0;
      SellBuffer1[bar]=0.0;
      SellBuffer2[bar]=0.0;
      //---
      if(Brain1[bar]==1)BuyBuffer1[bar]=1.0; else if(Brain1[bar]==2)SellBuffer1[bar]=1.0;
      if(Brain2[bar]==1)BuyBuffer2[bar]=0.6; else if(Brain2[bar]==2)SellBuffer2[bar]=0.6;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
