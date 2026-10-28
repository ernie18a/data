//+------------------------------------------------------------------+ 
//|                                               iAlligator_HTF.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- only three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "iAlligator" // The constant for the indicator name
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_SECTION
//--- the following colors are used for the indicator
#property indicator_color1  clrBlue
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "Jaws"

//--- drawing the indicator 2 as a line
#property indicator_type2   DRAW_SECTION
//--- the following colors are used for the indicator
#property indicator_color2  clrRed
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  "Teeth"

//--- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_SECTION
//--- the following colors are used for the indicator
#property indicator_color3  clrLime
//--- indicator 1 line width is equal to 2
#property indicator_width3  2
//--- displaying the indicator label
#property indicator_label3  "Lips"
//+-------------------------------------+
//|  INDICATOR INPUT PARAMETERS         |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES    TimeFrame=PERIOD_H4;            // Chart period
input int                JawsPeriod=13;               // Jaws period
input int                JawsShift=8;                 // Jaws shift
input int                TeethPeriod=8;               // Teeth period
input int                TeethShift=5;                // Teeth shift
input int                LipsPeriod=5;                // Lips period
input int                LipsShift=3;                 // Lips shift
input ENUM_MA_METHOD     MA_Method=MODE_SMMA;            // smoothing method
input ENUM_APPLIED_PRICE Applied_price=PRICE_MEDIAN;     // price constant
input int                PriceShift=0;                   // vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that further 
//--- will be used as indicator buffers
double ExtJaws[];
double ExtTeeth[];
double ExtLips[];
//--- Declaration of a variable for storing the indicator initialization result
bool Init;
double dPriceShift;
//--- Declaration of strings
string Symbol_,Word;
//--- declaration of integer variables for the indicators handles
int Ind_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("iAlligator indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting handle of the iAlligator indicator
   Ind_Handle=iAlligator(NULL,TimeFrame,JawsPeriod,0,TeethPeriod,0,LipsPeriod,0,MA_Method,Applied_price);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iAlligator indicator");
      return(INIT_FAILED);
     }
//--- Initialization of variables 
   double perratio=PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT);
   min_rates_total=int(perratio*(MathMax(MathMax(JawsPeriod,TeethPeriod),LipsPeriod)+3));
   Symbol_=Symbol();
   Word=INDICATOR_NAME+"("+Symbol_+","+GetStringTimeframe(TimeFrame)+")";
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtJaws,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,JawsPeriod+1);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,int(perratio*JawsShift));
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtJaws,true);

//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtTeeth,INDICATOR_DATA);
//--- shifting the beginning of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,TeethPeriod+1);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,int(perratio*TeethShift));
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtTeeth,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtLips,INDICATOR_DATA);
//--- shifting the beginning of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,LipsPeriod+1);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,int(perratio*LipsShift));
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLips,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,Word);
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
//--- the limit starting number for loop of bars recalculation
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
      ExtJaws[bar+1]=0.0;
      ExtTeeth[bar+1]=0.0;
      ExtLips[bar+1]=0.0;
      //--- copy newly appeared data in the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);
      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         //--- copy newly appeared data in the array
         if(CopyBuffer(Ind_Handle,GATORJAW_LINE,time[bar+1],1,iMa)<=0) return(RESET);
         ExtJaws[bar+1]=iMa[0]+dPriceShift;
         //---         
         if(CopyBuffer(Ind_Handle,GATORTEETH_LINE,time[bar+1],1,iMa)<=0) return(RESET);
         ExtTeeth[bar+1]=iMa[0]+dPriceShift;
         //---    
         if(CopyBuffer(Ind_Handle,GATORLIPS_LINE,time[bar+1],1,iMa)<=0) return(RESET);
         ExtLips[bar+1]=iMa[0]+dPriceShift;
         //---
         LastCountBar=bar;
        }
     }
//--- copy newly appeared data in the array
   if(CopyBuffer(Ind_Handle,GATORJAW_LINE,time[0],1,iMa)<=0) return(RESET);
   ExtJaws[0]=iMa[0]+dPriceShift;
//---
   if(CopyBuffer(Ind_Handle,GATORTEETH_LINE,time[0],1,iMa)<=0) return(RESET);
   ExtTeeth[0]=iMa[0]+dPriceShift;
//---
   if(CopyBuffer(Ind_Handle,GATORLIPS_LINE,time[0],1,iMa)<=0) return(RESET);
   ExtLips[0]=iMa[0]+dPriceShift;
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
