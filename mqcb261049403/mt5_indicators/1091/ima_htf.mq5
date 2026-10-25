//+------------------------------------------------------------------+ 
//|                                                      iMa_HTF.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 1
#property indicator_buffers 1 
//--- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0              // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "iMA" // The constant for the indicator name
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_SECTION
//--- the following colors are used for the indicator
#property indicator_color1  clrBlueViolet
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;          // Chart period
input uint MA_Period=15;                            // Period of averaging
input ENUM_MA_METHOD MA_Method=MODE_EMA;            // Method of averaging
input ENUM_APPLIED_PRICE Applied_price=PRICE_CLOSE; // Price constant
input int Shift=0;                                  // Horizontal shift of the indicator in bars
input int PriceShift=0;                             // Vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that further will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//--- Declaration of a variable for storing the indicator initialization result
bool Init;
double dPriceShift;
//--- declaration of strings
string Symbol_,Word;
//--- declaration of integer variables for the indicators handles
int Ind_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("iMA indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting handle of the iMA indicator
   Ind_Handle=iMA(NULL,TimeFrame,MA_Period,0,MA_Method,Applied_price);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMA indicator");
      return(INIT_FAILED);
     }
//--- initialization of variables 
   min_rates_total=int(PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT))*3;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for calculation
   if(BarsCalculated(Ind_Handle)<2 || rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of local variables 
   double iMa[1];
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//---the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-2; // starting index for calculation of all bars
      LastCountBar=limit;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      IndBuffer[bar+1]=0.0;
      //--- copy newly appeared data in the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);
      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         //--- copy newly appeared data in the array
         if(CopyBuffer(Ind_Handle,0,time[bar+1],1,iMa)<=0) return(RESET);
         LastCountBar=bar;
         IndBuffer[bar+1]=iMa[0]+dPriceShift;
        }
     }
//--- copy newly appeared data in the array
   if(CopyBuffer(Ind_Handle,0,time[0],1,iMa)<=0) return(RESET);
   IndBuffer[0]=iMa[0]+dPriceShift;
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
