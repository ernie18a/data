//+----------------------------------------------------------------------------+
//|                                                           i-AnyRange2.mq5  |
//|                                   Copyright © 2006, Kim Igor V. aka KimIV  |
//|                                                       http://www.kimiv.ru  |
//+----------------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2006, Kim Igor V. aka KimIV"
#property link      "http://www.kimiv.ru"
//---- indicator version number
#property version   "1.10"
//---- description of the indicator
#property description "Indicator of two ranges of arbitrary time intervals."
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----four buffers are used for calculation of drawing of the indicator
#property indicator_buffers 4
//---- four plots are used
#property indicator_plots   4
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
#property indicator_label1  "Upper Zone 1"
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
#property indicator_label2  "Lower Zone 1"
//+----------------------------------------------+
//| Upper line drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 3 as line
#property indicator_type3   DRAW_LINE
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color3  Lime
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator 3 line width is equal to 3
#property indicator_width3  3
//---- displaying of the bullish label of the indicator
#property indicator_label3  "Upper Zone 2"
//+----------------------------------------------+
//| Lower line drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 4 as line
#property indicator_type4   DRAW_LINE
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color4  Magenta
//---- line of the indicator 4 is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- thickness of line of the indicator 4 is equal to 3
#property indicator_width4  3
//---- displaying of the bearish label of the indicator
#property indicator_label4  "Lower Zone 2"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input string Start1   = "03:00";   // origin of 1
input string End1     = "08:00";   // end of 1
input string Start2   = "12:00";   // origin of 2
input string End2     = "17:00";   // end of 2
input uint   nDays=2;          // number of counting days (0-all)
input int    Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double Up1Buffer[];
double Dn1Buffer[];
double Up2Buffer[];
double Dn2Buffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,Max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(24*60*60*nDays/PeriodSeconds()+1);
   Max=int(nDays*1440*60/PeriodSeconds());

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Up1Buffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Up1Buffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Dn1Buffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Dn1Buffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,Up2Buffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Up2Buffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,Dn2Buffer,INDICATOR_DATA);
//---- shifting the indicator 4 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Dn2Buffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"i-AnyRange2(",Start1,", ",End1,", ",Start2,", ",End2,", ",nDays,", ",Shift,")");
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
      Comment("Indicator i-AnyRange is required timeframe under H2!");
      return(RESET);
     }
   else Comment("");

//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   double up,dn;
   int    bar,limit,kd=0,nb1,nb2,nd=0,rates_10;
   string sdt;

   rates_10=rates_total-10;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(nDays==0) limit=rates_10;
   else limit=Max;
   limit=MathMin(rates_10,limit);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   
   kd=0;
//---- main cycle of calculation of the first indicator
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      MqlDateTime tm;
      TimeToStruct(time[bar],tm);

      if(nd!=tm.day)
        {
         nd=tm.day;
         kd++;
         if(kd>int(nDays) && nDays) break;

         sdt=TimeToString(time[bar],TIME_DATE);

         nb1=iBarShift(NULL, 0, StringToTime(sdt+" "+Start1));
         nb2=iBarShift(NULL, 0, StringToTime(sdt+" "+End1));

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
         Up1Buffer[bar]=up;
         Dn1Buffer[bar]=dn;
        }
      else
        {
         Up1Buffer[bar]=EMPTY_VALUE;
         Dn1Buffer[bar]=EMPTY_VALUE;
        }
     }
     
   kd=0;
//---- main cycle of calculation of the second indicator
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

         nb1=iBarShift(NULL, 0, StringToTime(sdt+" "+Start2));
         nb2=iBarShift(NULL, 0, StringToTime(sdt+" "+End2));

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
         Up2Buffer[bar]=up;
         Dn2Buffer[bar]=dn;
        }
      else
        {
         Up2Buffer[bar]=EMPTY_VALUE;
         Dn2Buffer[bar]=EMPTY_VALUE;
        }
     }
//----         
   return(rates_total);
  }
//+------------------------------------------------------------------+
