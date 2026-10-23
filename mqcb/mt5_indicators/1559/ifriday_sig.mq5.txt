//+------------------------------------------------------------------+
//|                                                 i-Friday_Sig.mq5 |
//|                          Copyright © 2005, Igor V. Kim aka KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, Igor V. Kim aka KimIV"
//---- link to the website of the author
#property link      "http://www.kimiv.ru"
//---- indicator version number
#property version   "1.00"
#property description "Input and output signals by the Friday effect system"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a label
#property indicator_type1   DRAW_ARROW
//---- Lime color is used for the indicator
#property indicator_color1  clrLime
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator line label
#property indicator_label1  "i-Friday_Sig Buy"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type2   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color2  clrRed
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator line label
#property indicator_label2  "i-Friday_Sig Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color3  clrLime
//---- indicator 3 width is equal to 5
#property indicator_width3  5
//---- displaying the indicator label
#property indicator_label3  "i-Friday_Sig Buy Stop"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color4  clrRed
//---- indicator 4 width is equal to 5
#property indicator_width4  5
//---- displaying the indicator label
#property indicator_label4  "i-Friday_Sig Sell Stop"
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Hour //Type of constant
  {
   H0_ = 0,     //0
   H1_,         //1
   H2_,         //2
   H3_,         //3
   H4_,         //4
   H5_,         //5
   H7_,         //7
   H8_,         //8
   H9_,         //9
   H10_,         //10
   H11_,         //11
   H12_,         //12
   H13_,         //13
   H14_,         //14
   H15_,         //15
   H16_,         //16
   H17_,         //17
   H18_,         //18
   H19_,         //19
   H20_,         //20
   H21_,         //21
   H22_,         //22
   H23_          //23
  };
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Hour HourOpenPos =H7_;  // Time of position opening
input Hour HourClosePos=H19_; // Time of position closing
input int    Shift=0;        // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double BuyBuffer[];
double SellBuffer[];
double BuyStopBuffer[];
double SellStopBuffer[];
//---- declaration of integer variables for the indicators handles
int ATR_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- getting the ATR indicator handle
   int ATRPeriod=10;
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(1);
     }

   if(PeriodSeconds(PERIOD_CURRENT)>PeriodSeconds(PERIOD_H1))
     {
      Print("The i-Friday_Sig indicator does not works at Time Frames more than a hour");
      return(1);
     }

//---- initialization of variables of the start of data calculation
   min_rates_total=MathMax(2*PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT),ATRPeriod);

//---- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,BuyBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,233);

//---- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,SellBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,234);

//---- set BuyStopBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,BuyStopBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(BuyStopBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,163);

//---- set SellStopBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,SellStopBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(SellStopBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,163);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"i-Friday_Sig(",HourOpenPos,", ",HourClosePos,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
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
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
   if(PeriodSeconds(PERIOD_CURRENT)>PeriodSeconds(PERIOD_H1)) return(RESET);

//---- declaration of local variables 
   double ATR[],iOpen[2],iClose[2];
   int limit,to_copy,bar;

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;                 // starting index for calculation of new bars
     }

   to_copy=limit+1;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;
      BuyStopBuffer[bar]=EMPTY_VALUE;
      SellStopBuffer[bar]=EMPTY_VALUE;

      if(CopyOpen(Symbol(),PERIOD_D1,time[bar],2,iOpen)<=0) return(RESET);
      if(CopyClose(Symbol(),PERIOD_D1,time[bar],2,iClose)<=0) return(RESET);

      MqlDateTime tm;
      TimeToStruct(time[bar],tm);

      //----
      if(tm.day_of_week==5 && tm.min==0)
        {
         if(tm.hour==HourOpenPos)
           {
            if(iOpen[0]>iClose[0]) BuyBuffer[bar]=low[bar]-ATR[bar]/3;
            if(iOpen[0]<iClose[0]) SellBuffer[bar]=high[bar]+ATR[bar]/3;
           }

         if(tm.hour==HourClosePos)
           {
            if(iOpen[0]>iClose[0]) BuyStopBuffer[bar]=close[bar];
            if(iOpen[0]<iClose[0]) SellStopBuffer[bar]=close[bar];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
