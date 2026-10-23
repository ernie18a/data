//+---------------------------------------------------------------------+
//|                                                    JMASlope_HTF.mq5 |
//|                       Copyright © 2005, Weld & TrendLaboratory Ltd. |
//|               http://finance.groups.yahoo.com/group/TrendLaboratory |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Weld & TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//--- indicator version number
#property version   "1.00"
#property description "JMASlope"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers 2
#property indicator_buffers 2 
//--- only one plot is used
#property indicator_plots   1
//+-------------------------------------+
//|  Declaration of constants           |
//+-------------------------------------+
#define RESET 0                               // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "JMASlope"             // A constant for the indicator name
#define SIZE 1                                // A constant for the number of calls of the CountIndicator function in the code
//+-------------------------------------+
//|  Indicator drawing parameters       |
//+-------------------------------------+
//--- drawing indicator as a multi-color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//--- colors of the five-color histogram are as follows
#property indicator_color1 clrMagenta,clrPurple,clrGray,clrBlue,clrDodgerBlue
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- the width of indicator line is equal to 3
#property indicator_width1  3
#property indicator_label1  INDICATOR_NAME+" HTF"
//+-------------------------------------+
//|  Declaration of enumerations        |
//+-------------------------------------+
enum Applied_price_      // type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPL_,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Indicator chart period (timeframe)
input int jLength=14;                       // Depth of smoothing                   
input int jPhase=0;                         // Smoothing parameter (-100...+100)
input Applied_price_ IPC=PRICE_CLOSE_;      // Price constant
input int Shift=0;                          // Horizontal shift of the indicator in bars
//+-------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for indicators handles
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- checking correctness of the chart periods
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- initialization of variables 
   min_rates_total=2;
//--- получение хендла индикатора JMASlope
   Ind_Handle=iCustom(Symbol(),TimeFrame,"JMASlope",jLength,jPhase,IPC,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the JMASlope indicator");
      return(INIT_FAILED);
     }
//--- initialize indicator buffers
   IndInit(0,IndBuffer,0.0,min_rates_total,Shift);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_DATA);
   ArraySetAsSeries(ColorIndBuffer,true);
//--- Creating a name for displaying in a separate sub-window and in tooltip
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Set accuracy of displaying for the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
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
//--- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,1,ColorIndBuffer,time,rates_total,prev_calculated,min_rates_total))
      return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Draw_Begin);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // The number of the CountLine function in the list in the indicator code (starting number - 0)
                    string   Symb,            // Chart symbol
                    ENUM_TIMEFRAMES TFrame,   // Chart period
                    int      IndHandle,       // The handle of the processed indicator
                    uint     BuffNumb,        // The number of the buffer of the processed indicator
                    double&  IndBuf[],        // receiving buffer of the indicator
                    uint     ColorBuffNumb,   // The number of the buffer of the processed indicator
                    double&  ColorIndBuf[],   // Receiving color buffer of the indicator
                    const datetime& iTime[],  // Timeseries of time
                    const int Rates_Total,    // Amount of history in bars on the current tick
                    const int Prev_Calculated,// amount of history in bars at the previous tick
                    const int Min_Rates_Total)// minimum amount of history in bars for calculation
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=Rates_Total-Min_Rates_Total-1; // Starting index for calculation of all bars
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // Starting index for calculation of new bars 
//--- the main loop of the indicator calculation
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- reset the contents of the indicator buffers for calculation
      IndBuf[bar]=0.0;
      //--- copy new data to the IndTime array
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1],CArr[1];
         //--- copy new data to the Arr array
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,ColorBuffNumb,iTime[bar],1,CArr)<=0) return(RESET);
         //---
         IndBuf[bar]=Arr[0];
         ColorIndBuf[bar]=CArr[0];
        }
      else
        {
         IndBuf[bar]=IndBuf[bar+1];
         ColorIndBuf[bar]=ColorIndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Indicator chart period (timeframe)
  {
//--- Checking correctness of the chart periods
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for the "+IndName+" indicator cannot be less than the period of the current chart!");
      Print("You must change the indicator input parameters!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
