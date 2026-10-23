//+------------------------------------------------------------------+
//|                                                       RPoint.mq5 |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, Poul_Trade_Forum"
#property link      "http://forex.kbpauk.ru/"
#property description "The chart layout in X-points reversal"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a sigsag
#property indicator_type1   DRAW_SECTION
//---- DodgerBlue color is used for the indicator line
#property indicator_color1 clrDodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "RPoint"
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input uint ReversPoint=50;
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double RPointBuffer[];

datetime ttime;
int Trend,InTrend;
double Last_High,Last_Low,RPoint;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| RPoint indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;
   RPoint=ReversPoint*_Point;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,RPointBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"RPoint(",ReversPoint,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| RPoint iteration function                                        | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1; // starting number for calculation of all bars
      ttime=0;
      InTrend=0;
      Last_Low=99999999.9;
      Last_High=0.0;
      Trend=0;
      
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(Time[bar]!=ttime) InTrend++;

      ttime=Time[bar];
      RPointBuffer[bar]=0;

      if(High[bar-1]>Last_High && Trend==1)  InTrend=1;
      if(Low[bar-1]<Last_Low   && Trend==0)   InTrend=1;

      if(High[bar-1]>Last_High) Last_High=High[bar-1];
      if(Low[bar-1]<Last_Low) Last_Low=Low[bar-1];

      if(Trend!=-1 && Low[bar-1]<Last_High-RPoint && InTrend>1)
        {
         Trend=-1;
         RPointBuffer[bar-InTrend]=High[bar-InTrend];
         Last_High=Low[bar-1];
         Last_Low=Low[bar-1];
         InTrend=1;
        }

      if(Trend!=+1 && High[bar-1]>Last_Low+RPoint && InTrend>1)
        {
         Trend=+1;
         RPointBuffer[bar-InTrend]=Low[bar-InTrend];
         Last_Low=High[bar-1];
         Last_High=High[bar-1];
         InTrend=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
