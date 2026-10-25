//+------------------------------------------------------------------+ 
//|                                                      CHO_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
#property description "CHO with the timeframe selection option available in input parameters"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-------------------------------------+
//| declaration of constants            |
//+-------------------------------------+
#define RESET 0                // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "CHO"   // A constant for the indicator name
#define SIZE 1                 // A constant for the number of calls of the CountIndicator function
//+-------------------------------------+
//| Indicator 1 drawing parameters      |
//+-------------------------------------+
//--- a line is used for the indicator
#property indicator_type1   DRAW_LINE
//--- DarkTurquoise is used as the color of the indicator line
#property indicator_color1 clrDarkTurquoise
//--- Indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 4
#property indicator_width1  4
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+-----------------------------------+
//| declaration of enumerations       |
//+-----------------------------------+
enum Smooth_Method
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA    //AMA
  };
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+  
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;         // Indicator chart period
input Smooth_Method XMA_Method=MODE_SMA;           // Method of averaging
input uint FastPeriod=3;                           // Period of fast averaging
input uint SlowPeriod=10;                          // Slow averaging period
input int XPhase=15;                               // Smoothing parameter
//--- for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume                 
input int Shift=0;                                 // Horizontal shift of the indicator in bars        
//+-------------------------------------+
//--- declaration of dynamic arrays that 
//--- will be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//--- Declaration of strings
string Symbol_,Word;
//--- Declaration of integer variables of data starting point
int min_rates_total;
//--- Declaration of integer variables for the indicator handles
int Ind_Handle;
//+------------------------------------------------------------------+
//| Getting a timeframe as a string                                  |
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
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- getting the handle of the CHO indicator
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,XMA_Method,FastPeriod,SlowPeriod,XPhase,VolumeType);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the CHO indicator");
      return(INIT_FAILED);
     }
//--- Initialization of indicator buffers
   IndInit(0,IndBuffer,EMPTY_VALUE,min_rates_total,Shift);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- Indexing buffer elements as timeseries
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
                    double&  IndBuf[],        // Receiving buffer of the indicator
                    const datetime& iTime[],  // Timeseries of time
                    const int Rates_Total,    // amount of history in bars on the current tick
                    const int Prev_Calculated,// amount of history in bars at the previous tick
                    const int Min_Rates_Total)// minimum amount of history in bars for calculation
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- Calculating the required amount of data to copy
//--- and the 'limit' starting index for the bars recalculation loop
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=Rates_Total-Min_Rates_Total-1; // starting index for the calculation of all bars
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // starting index for calculation of new bars 
//--- main calculation loop of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- Zero out the contents of the indicator buffers for the calculation
      IndBuf[bar]=0.0;
      //--- Copy new data to the IndTime array
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Indicator chart period
  {
//--- checking correctness of the chart periods
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for the "+IndName+" indicator cannot be less than the period of the current chart!");
      Print ("You must change the indicator input parameters!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
