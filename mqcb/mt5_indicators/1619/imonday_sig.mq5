//+----------------------------------------------------------------------------+
//|                                                          i-Monday_Sig.mq5  |
//|                                  Copyright © 2005, Kim Igor V. aka KimIV   |
//|                                                       http://www.kimiv.ru  |
//+----------------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, Kim Igor V. aka KimIV"
#property link      "http://www.kimiv.ru"
//---- indicator version number
#property version   "1.00"
//---- indicator description
#property description "Entries and exits signals on the system Monday"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Upper line drawing parameters               |
//+----------------------------------------------+
//---- drawing the indicator 1 as a label
#property indicator_type1   DRAW_ARROW
//---- blue color is used as the color of a bullish candlestick
#property indicator_color1  clrBlue
//---- thickness of line of the indicator 1 is equal to 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Up i-Monday_Sig"
//+----------------------------------------------+
//|  Lower line drawing parameters               |
//+----------------------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type2   DRAW_ARROW
//---- red color is used as the color of the bearish indicator line
#property indicator_color2  clrRed
//---- thickness of the indicator 2 line is equal to 3
#property indicator_width2  3
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Down i-Monday_Sig"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum HourOpen //Type of constant
  {
   H0=0,             //0
   H1,               //1
   H2,               //2
   H3,               //3
   H4,               //4
   H5,               //5
   H6,               //6
   H7,               //7
   H8,               //8
   H9,               //9
   H10,              //10
   H11,              //11
   H12,              //12
   H13,              //13
   H14,              //14
   H15,              //15
   H16,              //16
   H17,              //17
   H18,              //18
   H19,              //19
   H20,              //20
   H21,              //21
   H22,              //22
   H23               //23
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input HourOpen HourOpenPos=H11;  // Time of opening of deal
input int        Shift=0;          // horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(24*60*60*5/PeriodSeconds()+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,233);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"i-Monday_Sig(",HourOpenPos,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
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
// The check of the chart period                                      
   if(Period()>PERIOD_H1)
     {
      Comment("The i-Monday_Sig indicator needs timeframe under H2!");
      return(RESET);
     }
   else Comment("");

//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   double iOpen[2];
   int    bar,limit;

//---- calculation of the limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- main cycle of calculation of the indicator
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      
      MqlDateTime tm;
      TimeToStruct(time[bar],tm);

      if(tm.day==MONDAY && tm.hour==HourOpenPos && tm.min==0)
        {
         double AvgRange=0.0;
         for(int count=bar; count<=bar+9; count++) AvgRange+=MathAbs(high[count]-low[count]);
         double Range=AvgRange/20;
         
         if(CopyOpen(Symbol(),PERIOD_D1,time[bar],2,iOpen)<=0) return(RESET);

         if(iOpen[0]>close[bar]) UpBuffer[bar]=low[bar]-Range;
         if(iOpen[0]<close[bar]) DnBuffer[bar]=high[bar]+Range;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
