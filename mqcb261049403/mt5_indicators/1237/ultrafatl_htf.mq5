//+------------------------------------------------------------------+ 
//|                                                UltraFatl_HTF.mq5 | 
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the directory: terminal_data_folder\MQL5\Include              |
//| the UltraFatl.mq5 file                                           |
//| to the directory: MetaTrader\\MQL5\Indicators                    |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- only one plot is used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator as a histogram 2
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//--- colors of the four-color histogram are as follows
#property indicator_color1  clrGray,clrMagenta,clrHotPink,clrRed,clrBrown,clrLimeGreen,clrTeal,clrLime,clrPaleGreen
//--- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is equal to 5
#property indicator_width1 5
//--- displaying the indicator label
#property indicator_label1 "UltraFatl HTF"
//+-----------------------------------+
//| Declaration of constants          |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//| Averaging classes description     |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//| Declaration of enumerations       |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//| enumeration declaration           |
//+-----------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+-----------------------------------+
//| enumeration declaration           |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,       // Solid line
   DASH_,        // Dashed line
   DOT_,         // Dotted line
   DASHDOT_,     // Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;          // Chart period
input ENUM_APPLIED_PRICE Applied_price=PRICE_CLOSE; // Applied price
//---
input Smooth_Method W_Method=MODE_JJMA;             // Smoothing method
input int StartLength=3;                            // Initial smoothing period                    
input int WPhase=100;                               // Smoothing parameter
//---  
input uint Step=5;                                  // Period change step
input uint StepsTotal=10;                           // Number of period changes
//---
input Smooth_Method SmoothMethod=MODE_JJMA;         // Smoothing method
input int SmoothLength=3;                           // Smoothing depth
input int SmoothPhase=100;                          // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;               // Price constant
//---                          
input uint UpLevel=80;                              // Overbought level, %
input uint DnLevel=20;                              // Oversold level, %
input color UpLevelsColor=clrBlue;                  // Overbought level color
input color DnLevelsColor=clrBlue;                  // Oversold level color
input STYLE Levelstyle=DASH_;                       // Levels style
input WIDTH  LevelsWidth=Width_1;                   // Levels width     
input bool ReDraw=true;                             // Repeat of information show on the empty bars
//+-----------------------------------+
//--- Declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the variables array for storing UltraFatl indicator signal lines periods
int period[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicator handles
int UltraFatl_Handle;
//---
double dUpLevel,dDnLevel;
//--- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpBuffer[],DnBuffer[],ColorBuffer[];
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
//| UltraFatl indicator initialization function                      | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- Initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;

//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("UltraFatl indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting the UltraFatl indicator handle
   UltraFatl_Handle=iCustom(Symbol(),TimeFrame,"UltraFatl",Applied_price,W_Method,StartLength,WPhase,
                            Step,StepsTotal,SmoothMethod,SmoothLength,SmoothPhase,IPC,UpLevel,DnLevel,clrNONE,clrNONE,0,0);
   if(UltraFatl_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the UltraFatl indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of variables
   dUpLevel=StepsTotal*UpLevel/100.0;
   dDnLevel=StepsTotal*DnLevel/100.0;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(UpBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(DnBuffer,true);
//--- setting dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorBuffer,true);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"UltraFatl HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- lines drawing parameters  
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,dUpLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,dDnLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| UltraFatl iteration function                                     | 
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
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(UltraFatl_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double UpValue[1],DnValue[1],clrValue[1];
   datetime UltraFatlTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//--- the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for the calculation
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      ColorBuffer[bar]=0;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,UltraFatlTime)<=0) return(RESET);

      if(time[bar]>=UltraFatlTime[0] && time[bar+1]<UltraFatlTime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(UltraFatl_Handle,0,time[bar],1,DnValue)<=0) return(RESET);
         if(CopyBuffer(UltraFatl_Handle,1,time[bar],1,UpValue)<=0) return(RESET);        
         if(CopyBuffer(UltraFatl_Handle,2,time[bar],1,clrValue)<=0) return(RESET);
         //--- loading the obtained values in the indicator buffers
         UpBuffer[bar]=UpValue[0];
         DnBuffer[bar]=DnValue[0];
         ColorBuffer[bar]=clrValue[0];
        }
      if(ReDraw)
        {
         if(UpBuffer[bar+1]!=EMPTY_VALUE && UpBuffer[bar]==EMPTY_VALUE)
           {
            ColorBuffer[bar]=ColorBuffer[bar+1];
            UpBuffer[bar]=UpBuffer[bar+1];
            DnBuffer[bar]=DnBuffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
