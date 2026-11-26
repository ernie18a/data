//+------------------------------------------------------------------+ 
//|                                        AsimmetricStochNR_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "arria@mail.redcom.ru"
//--- indicator version
#property version   "1.60"
#property description "Ergodic Oscillator with the timeframe selection option available in input parameters."
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers is 5
#property indicator_buffers 5 
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0                             // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "AsymmetricStochNR"  // A constant for the indicator name
#define SIZE 1                              // A constant for the number of calls of the CountIndicator function in the code
//+----------------------------------------------+
//| Indicator 1 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used as the indicator colors
#property indicator_color1  clrAqua,clrDeepPink
//--- displaying the indicator label
#property indicator_label1  "Signal"
//+----------------------------------------------+
//| Indicator 2 drawing parameters               |
//+----------------------------------------------+
//---- drawing indicator as a four-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM2
//--- colors of the five-color histogram are as follows
#property indicator_color2 clrDeepPink,clrOrange,clrGray,clrDodgerBlue,clrBlue
//--- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width2 2
//--- displaying the indicator label
#property indicator_label2  INDICATOR_NAME
//+----------------------------------------------+
//| CXMA class description                       |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//| Declaration of enumerations                  |
//+----------------------------------------------+
/*enum Smooth_Method is declared in the SmoothAlgorithms.mqh file
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
  }; */
//+----------------------------------------------+
//| Declaration of enumeration                   |
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
//| Declaration of enumeration                   |
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
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Indicator chart period (timeframe)
input uint KperiodShort=5;                   // %K period
input uint KperiodLong=12;                   // %K period
input Smooth_Method DMethod=MODE_SMA;        // Signal line smoothing method 
input uint Dperiod=7;                        // %D signal line period
input int DPhase=15;                         // Signal line smoothing parameter
input uint Slowing=3;                        // Slowing
input ENUM_STO_PRICE PriceField=STO_LOWHIGH; // Prices selection parameter for calculation
input uint Sens=7;                           // Sensitivity in points
input uint OverBought=80;                    // Overbought level, %
input uint OverSold=20;                      //  Oversold level, %
input color LevelsColor=clrBlue;             // Color of levels
input STYLE Levelstyle=DASH_;                // Style of the levels
input WIDTH  LevelsWidth=Width_1;            // Depth of the levels
input int Shift=0;                           // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer1[];
double IndBuffer2[];
double ColorIndBuffer[];
double UpIndBuffer[];
double DnIndBuffer[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
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
//--- getting the handle of the AsymmetricStochNR indicator
   Ind_Handle=iCustom(Symbol(),TimeFrame,"AsymmetricStochNR",KperiodShort,KperiodLong,DMethod,Dperiod,DPhase,
                      Slowing,PriceField,Sens,OverBought,OverSold,clrNONE,0,0,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of AsymmetricStochNR");
      return(INIT_FAILED);
     }
//--- Initialize indicator buffers
   IndInit(0,UpIndBuffer,INDICATOR_DATA);
   IndInit(1,DnIndBuffer,INDICATOR_DATA);
   IndInit(2,IndBuffer1,INDICATOR_DATA);
   IndInit(3,IndBuffer2,INDICATOR_DATA);
   IndInit(4,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- initialization of indicators
   PlotInit(0,0,Shift);
   PlotInit(1,0,Shift);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- line drawing parameters  
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,OverSold);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,LevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);
//---
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrDarkOrchid);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
//---
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,OverBought);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,LevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,LevelsWidth);
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
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,
      IndBuffer1,IndBuffer2,ColorIndBuffer,UpIndBuffer,DnIndBuffer,time,rates_total,prev_calculated,min_rates_total))
      return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,Type);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| indicator initialization                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,int Draw_Begin,int nShift)
  {
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // The number of the CountLine function in the list in the indicator code (starting number - 0)
                    string   Symb,            // Chart symbol
                    ENUM_TIMEFRAMES TFrame,   // Chart period
                    int      IndHandle,       // The handle of the processed indicator
                    double&  IndBuf1[],        // Receiving buffer of the indicator 1
                    double&  IndBuf2[],        // Receiving buffer of the indicator 2
                    double&  ColorIndBuf[],   // Receiving color buffer of the indicator
                    double&  UpIndBuf[],      // Receiving buffer of the indicator for the cloud
                    double&  DnIndBuf[],      // Receiving buffer of the indicator for the cloud
                    const datetime& iTime[],  // Timeseries of time
                    const int Rates_Total,    // amount of history in bars on the current tick
                    const int Prev_Calculated,// amount of history in bars at the previous tick
                    const int Min_Rates_Total)// minimum amount of history in bars for calculation
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=Rates_Total-Min_Rates_Total-1; // starting index for calculation of all bars
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // Starting index for calculation of new bars 
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- Copy new data to the IndTime array
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double IndArr[2],SignArr[1];

         //--- copy newly appeared data in the arrays
         if(CopyBuffer(IndHandle,0,iTime[bar],2,IndArr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,1,iTime[bar],1,SignArr)<=0) return(RESET);

         IndBuf1[bar]=IndArr[1];
         IndBuf2[bar]=50;
         if(!IndBuf1[bar]) IndBuf1[bar]=0.000000001;
         UpIndBuf[bar]=IndBuf1[bar];
         DnIndBuf[bar]=SignArr[0];
         if(!DnIndBuf[bar]) DnIndBuf[bar]=0.000000001;
         int clr=2;
         //---
         if(IndArr[1]>50)
           {
            if(IndArr[1]>IndArr[0]) clr=4;
            if(IndArr[1]<IndArr[0]) clr=3;
           }
         //---
         if(IndArr[1]<50)
           {
            if(IndArr[1]<IndArr[0]) clr=0;
            if(IndArr[1]>IndArr[0]) clr=1;
           }

         ColorIndBuf[bar]=clr;
        }
      else
        {
         IndBuf1[bar]=IndBuf1[bar+1];
         IndBuf2[bar]=IndBuf2[bar+1];
         ColorIndBuf[bar]=ColorIndBuf[bar+1];
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
                     ENUM_TIMEFRAMES TFrame) //Indicator chart period (timeframe)
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
