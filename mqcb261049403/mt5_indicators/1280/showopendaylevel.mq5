//+------------------------------------------------------------------+ 
//|                                             ShowOpenDayLevel.mq5 | 
//|                               Copyright © 2012, Nikolay Kositsin | 
//|                                Khabarovsk, farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- Magenta color is used as the color of the bullish line of the indicator
#property indicator_color1 clrMagenta
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "ShowOpenDayLevel"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum HOUR_SHIFT //Type of constant
  {
   H0 = 0,       // 0
   H1,           //+1
   H2,           //+2
   H3,           //+3
   H4,           //+3
   H5,           //+5
   H6,           //+6
   H7,           //+7
   H8,           //+8
   H9,           //+9
   H10,          //+10
   H11,          //+11
   H12,          //+12
   H13,          //+13
   H14,          //+13
   H15,          //+15
   H16,          //+16
   H17,          //+17
   H18,          //+18
   H19,          //+19
   H20,          //+20
   H21,          //+21
   H22,          //+22
   H23           //+23
  };
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum DAY_MODE //Type of constant
  {
   Friday,       //how the end of fridays
   Sunday,       //how the end of sundays
   Monday        //how the start of mondays
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input HOUR_SHIFT HourShift=H0;    // shift of determine time of the day start
input DAY_MODE SundayTab=Sunday;  // sundays tab
input int Shift=0;                // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffer
double IndBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| ShowOpenDayLevel indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=3;
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ShowOpenDayLevel( Shift = ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetLastOpen(double &Buffer[],HOUR_SHIFT hshift,bool stab,const datetime &Time[],int index)
  {
//----
   MqlDateTime tm;
   TimeToStruct(Time[index+0],tm);
   int Hour0=tm.hour;
   int DW0=tm.day_of_week;
   TimeToStruct(Time[index+1],tm);
   int Hour1=tm.hour;
//----
   if(DW0==SUNDAY)
      switch(SundayTab)
        {
         case Friday: Buffer[index]=Buffer[index+1]; return(true);
         case Monday:
            if(Hour1!=Hour0 && Hour0==HourShift)
              {
               double iOpen[1];
               if(CopyOpen(Symbol(),PERIOD_H1,Time[index],1,iOpen)<=0) return(false);
               Buffer[index]=iOpen[0];
              }
            else Buffer[index]=Buffer[index+1];
            return(true);
        }
//----
   if(DW0==MONDAY && SundayTab==Monday)
     {
      Buffer[index]=Buffer[index+1];
      return(true);
     }
//----
   if(Hour1!=Hour0 && Hour0==HourShift)
     {
      double iOpen[1];
      if(CopyOpen(Symbol(),PERIOD_H1,Time[index],1,iOpen)<=0) return(false);
      Buffer[index]=iOpen[0];
     }
   else Buffer[index]=Buffer[index+1];
//----
   return(true);
  }
//+------------------------------------------------------------------+  
//| ShowOpenDayLevel iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total || Period()>PERIOD_H1) return(RESET);

//---- Declaration of integer variables
   int limit,bar;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--) if(!GetLastOpen(IndBuffer,HourShift,SundayTab,time,bar))return(RESET);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
