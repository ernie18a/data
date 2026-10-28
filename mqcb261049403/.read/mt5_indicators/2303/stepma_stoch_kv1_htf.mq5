//+------------------------------------------------------------------+ 
//|                                         StepMA_Stoch_KV1_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- Indicator version number
#property version   "1.60"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a seven-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the seven-color histogram are as follows
#property indicator_color1 clrMagenta,clrMediumVioletRed,clrPlum,clrGray,clrLightSkyBlue,clrTeal,clrDodgerBlue
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "StepMA_Stoch_KV1 HTF"

//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Chart period
input bool ReDraw=true; //repeat information display on empty bars
input uint PeriodWATR=10;
input double Kwatr=1.0000;
input bool HighLow=false;
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int Ind_Handle;
//---- declaration of dynamic arrays that 
// will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//|  Getting string timeframe                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=3;

//---- Checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for the indicator StepMA_Stoch_KV1 cannot be less than the current chart period");
      return(INIT_FAILED);
     }

//---- Getting the handle of StepMA_Stoch_KV1
   Ind_Handle=iCustom(Symbol(),TimeFrame,"StepMA_Stoch_KV1",PeriodWATR,Kwatr,HighLow);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of StepMA_Stoch_KV1");
      return(INIT_FAILED);
     }

//---- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"StepMA_Stoch_KV1 HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- Declaration of variables
   int limit,bar;
   datetime IndTime[1];
   static uint LastCountBar;

//---- calculations of the necessary amount of data to be copied and
//the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Zero out the contents of the indicator buffers for the calculation
      IndBuffer[bar]=EMPTY_VALUE;
      ColorIndBuffer[bar]=0;

      //---- Copy the new data into the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,IndTime)<=0) return(RESET);

      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         //---- Declaring floating point variables  
         double Ind[2],Clr[1];

         //---- copy newly appeared data into the arrays
         if(CopyBuffer(Ind_Handle,0,time[bar],2,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,Clr)<=0) return(RESET);

         //---- Loading the obtained values in the indicator buffers
         IndBuffer[bar]=Ind[1];
         ColorIndBuffer[bar]=Clr[0];
        }

      if(ReDraw)
        {
         if(IndBuffer[bar+1]!=EMPTY_VALUE && IndBuffer[bar]==EMPTY_VALUE)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
