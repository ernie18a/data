//+------------------------------------------------------------------+ 
//|                                                 UltraWPR_HTF.mq5 | 
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- Indicator version
#property version   "1.00"
#property description "Indicator UltraWPR with the timeframe selection option available in input parameters"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers is 2
#property indicator_buffers 2 
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                    // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "UltraWPR"  // A constant for the indicator name
#define SIZE  1                    // A constant for the number of calls of the CountIndicator function in the code
#define EMPTYVALUE EMPTY_VALUE     // A constant for undisplayed indicator values
//+----------------------------------------------+
//|  Filling drawing parameters                  |
//+----------------------------------------------+
//--- drawing indicator as a filling between two lines
#property indicator_type1   DRAW_FILLING
//--- green and pink colors are used as the indicator filling colors
#property indicator_color1  Lime, Magenta
//--- displaying the indicator label
#property indicator_label1 INDICATOR_NAME " HTF"
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
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
   MODE_AMA,   // AMA
  };
//+----------------------------------------------+
//|  declaration of enumeration                  |
//+----------------------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+----------------------------------------------+
//|  declaration of enumeration                  |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,       // Solid line
   DASH_,        // Dashed line
   DOT_,         // Dotted line
   DASHDOT_,     // Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Indicator chart period
input int WPR_Period=13;                     // WPR indicator period
input Smooth_Method W_Method=MODE_JJMA;      // Method of averaging
input int StartLength=3;                     // Initial averaging period                    
input int WPhase=100;                        // Averaging parameter
//--- WPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- WPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input uint Step=5;                           // Period change step
input uint StepsTotal=10;                    // Number of period changes
input Smooth_Method SmoothMethod=MODE_JJMA;  // Smoothing method
input int SmoothLength=3;                    // Smoothing depth                    
input int SmoothPhase=100;                   // Smoothing parameter (-100..+100)
//---
input uint UpLevel=80;                       // Overbought level (%)
input uint DnLevel=20;                       // Oversold level (%)
input color UpLevelsColor=Blue;              // Overbought level color
input color DnLevelsColor=Blue;              // Oversold level color
input STYLE Levelstyle=DASH_;                // Style of the levels
input WIDTH  LevelsWidth=Width_1;            // Depth of the levels
input int    Shift=0;                        // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- Declaration of integer variables for the indicator handles
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- Checking correctness of the chart periods
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- initialization of variables 
   min_rates_total=2;
//--- getting the handle of the UltraWPR indicator
   Ind_Handle=iCustom(Symbol(),TimeFrame,"UltraWPR",WPR_Period,W_Method,StartLength,WPhase,
                           Step,StepsTotal,SmoothMethod,SmoothLength,SmoothPhase,0,0,clrRed,clrRed,0,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the UltraWPR indicator");
      return(INIT_FAILED);
     }
//--- Initialize indicator buffers
   IndInit(0,Ind1Buffer);
   IndInit(1,Ind2Buffer);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTYVALUE);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",EnumToString(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);  
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- line drawing parameters  
   IndicatorSetInteger(INDICATOR_LEVELS,2);  
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,StepsTotal*UpLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);
//---  
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,StepsTotal*DnLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
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
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,Symbol(),TimeFrame,Ind_Handle,0,Ind1Buffer,1,Ind2Buffer,
                           time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[])
  {
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
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
                    uint     UpBuffNumb,      // The number of the buffer of the processed indicator for an uptrend
                    double&  UpIndBuf[],      // Receiving buffer of the indicator for an uptrend
                    uint     DnBuffNumb,      // The number of the buffer of the processed indicator for a downtrend
                    double&  DnIndBuf[],      // Receiving buffer of the indicator for a downtrend
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
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- reset the contents of the indicator buffers for calculation
      UpIndBuf[bar]=EMPTYVALUE;
      DnIndBuf[bar]=EMPTYVALUE;

      //---- Copy new data to the IndTime array
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];

         //--- Copy new data to the Arr array
         if(CopyBuffer(IndHandle,UpBuffNumb,iTime[bar],1,Arr)<=0) return(RESET); UpIndBuf[bar]=Arr[0];
         if(CopyBuffer(IndHandle,DnBuffNumb,iTime[bar],1,Arr)<=0) return(RESET); DnIndBuf[bar]=Arr[0];
        }
      else
        {
         UpIndBuf[bar]=UpIndBuf[bar+1];
         DnIndBuf[bar]=DnIndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Indicator 1 chart period (smallest timeframe)
  {
//--- Checking correctness of the chart periods
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
