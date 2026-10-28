//+----------------------------------------------------------------------------+
//|                                                            i-AnyRange.mq5  |
//|                                   Copyright © 2006, Kim Igor V. aka KimIV  |
//|                                                       http://www.kimiv.ru  |
//+----------------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2006, Kim Igor V. aka KimIV"
#property link      "http://www.kimiv.ru"
//---- indicator version number
#property version   "1.00"
//---- description of the indicator
#property description "Indicator of ranges of arbitrary time intervals."
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| Upper line drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of a bullish candlestick
#property indicator_color1  Blue
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Up i-AnyRange"
//+----------------------------------------------+
//| Lower line drawing parameters                |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used as the color of the bearish indicator line
#property indicator_color2  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- thickness of line of the indicator 2 is equal to 3
#property indicator_width2  3
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Down i-AnyRange"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input string Time1 = "02:00";    // Temporary point 1
input string Time2 = "07:00";    // Temporary point 2
input uint   nDays = 2;          // Number of days for calculation (0-all)
input int    Shift=0;            // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(24*60*60*nDays/PeriodSeconds()+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"i-AnyRange(",Time1,", ",Time2,", ",nDays,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
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
//| iBarShift() function                                             |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----+
   if(time<0) return(-1);

   datetime Arr[],time1;

   time1=(datetime) SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);
   if(time>=time1) return(0);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----+
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
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking of the chart period
   if(Period()>PERIOD_H1)
     {
      Comment("Indicator i-AnyRange is required timeframe under H4!");
      return(RESET);
     }
   else Comment("");

//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   double up,dn;
   int    bar,limit,kd=0,nb1,nb2,nd=0;
   string sdt;
   static uint RecountPoint;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(nDays==0) limit=rates_total-10;
   else limit=int(nDays*1440*60/PeriodSeconds());
   limit=MathMin(rates_total-10,limit);

   if(prev_calculated>rates_total || prev_calculated<=0) RecountPoint=0;

   limit=int(MathMin(RecountPoint+rates_total-prev_calculated,limit));

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

//---- main cycle of calculation of the indicator
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      MqlDateTime tm;
      TimeToStruct(time[bar],tm);

      if(nd!=tm.day)
        {
         nd=tm.day;
         kd++;
         if(kd>int(nDays) && nDays) return(rates_total);

         sdt=TimeToString(time[bar],TIME_DATE);

         nb1=iBarShift(NULL, 0, StringToTime(sdt+" "+Time1));
         nb2=iBarShift(NULL, 0, StringToTime(sdt+" "+Time2));

         if(nb1>nb2+1)
           {
            up=high[ArrayMaximum(high,nb2+1,nb1-nb2)];
            dn=low[ArrayMinimum(low,nb2+1,nb1-nb2)];
           }

         if(nb2>nb1+1)
           {
            up=high[ArrayMaximum(high,nb1+1,nb2-nb1)];
            dn=low[ArrayMinimum(low,nb1+1,nb2-nb1)];
           }
        }
      if(nb1>=bar && bar>nb2 || nb2>=bar && bar>nb1)
        {
         UpBuffer[bar]=up;
         DnBuffer[bar]=dn;
        }
      else
        {
         UpBuffer[bar]=EMPTY_VALUE;
         DnBuffer[bar]=EMPTY_VALUE;
        }

      if(UpBuffer[bar+1]==EMPTY_VALUE && UpBuffer[bar]!=EMPTY_VALUE) RecountPoint=bar;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
