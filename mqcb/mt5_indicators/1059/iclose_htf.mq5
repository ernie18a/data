//+------------------------------------------------------------------+ 
//|                                                   iClose_HTF.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers is 1
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "iClose" // The constant for the name of the indicator
//+----------------------------------------------+
//|  Indicator drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_SECTION
//---- the following colors are used as the indicator colors
#property indicator_color1  clrMagenta
//---- indicator 1 line width is 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+-------------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Chart period
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in points
//+-------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//---- Declaration of a variable for storing the indicator initialization result
bool Init;
double dPriceShift;
//---- Declaration of strings
string Symbol_,Word;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
   Init=true;
//---- checking the chart periods for correctness
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("The iClose indicator chart period cannot be less than the current chart period");
      Init=false;
      return;
     }

//---- Initialization of variables 
   min_rates_total=int(PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT))*3;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 1 drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total || !Init) return(RESET);

//---- declaring local variables 
   double iClose[1];
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-2; // starting index for the calculation of all bars
      LastCountBar=limit;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing array elements as time series  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for the calculation
      IndBuffer[bar+1]=0.0;

      //---- copy new data to the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);

      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         LastCountBar=bar;
         IndBuffer[bar+1]=close[bar+1]+dPriceShift;
        }
     }
     
   IndBuffer[0]=close[0]+dPriceShift;
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
