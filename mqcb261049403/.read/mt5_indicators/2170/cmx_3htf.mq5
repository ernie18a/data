//+------------------------------------------------------------------+ 
//|                                                     CMx_3HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.50"
#property description "Three CMx oscillators with different timeframes with the same parameters on one chart."
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "CMx"   // A constant for the indicator name
#define SIZE 3                 // A constant for the number of calls of the CountIndicator function in the code
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- the color of the indicator
#property indicator_color1  clrDodgerBlue
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "CMx 1"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the color of the indicator
#property indicator_color2  clrMediumOrchid
//--- indicator 2 line width is equal to 3
#property indicator_width2  3
//--- displaying the indicator label
#property indicator_label2  "CMx 2"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters            |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//--- the color of the indicator
#property indicator_color3  clrMediumSeaGreen
//--- indicator 3 line width is equal to 5
#property indicator_width3  5
//--- displaying the indicator label
#property indicator_label3  "CMx 3"
//+-------------------------------------+
//| Indicator input parameters                   |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_M30; //Indicator 1 chart period (smallest timeframe)
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H1;  // Indicator 2 chart period (medium timeframe)
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H4;  // Indicator 3 chart period (highest timeframe)
//---
input int    F=12;
input double k=1.682;
input double L_adx=18;
input int    Shift=0;               // Horizontal shift of the indicator in bars
//---
input double    Level1=+423.6;      // Level 1
input double    Level2=+261.8;      // Level 2
input double    Level3=+161.8;      // Level 3
input double    Level4=+61.8;       // Level 4
input double    Level5=0.0;         // Level 5
input double    Level6=-61.8;       // Level 6
input double    Level7=-161.8;      // Level 7
input double    Level8=-261.8;      // Level 8
input double    Level9=-423.6;      // Level 9
//+-------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int Ind1_Handle,Ind2_Handle,Ind3_Handle;
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
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame1,TimeFrame2,TimeFrame3)) return(INIT_FAILED);
//--- initialization of variables 
   min_rates_total=2;
//--- getting the handle of CMx 1
   Ind1_Handle=iCustom(Symbol(),TimeFrame1,"CMx",F,k,L_adx,0);
   if(Ind1_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of CMx 1");
      return(INIT_FAILED);
     }
//--- getting the handle of CMx 2
   Ind2_Handle=iCustom(Symbol(),TimeFrame2,"CMx",F,k,L_adx,0);
   if(Ind2_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of CMx 2");
      return(INIT_FAILED);
     }
//--- getting the handle of CMx 3
   Ind3_Handle=iCustom(Symbol(),TimeFrame3,"CMx",F,k,L_adx,0);
   if(Ind3_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of CMx 3");
      return(INIT_FAILED);
     }
//--- Initialize indicator buffers
   IndInit(0,Ind1Buffer,0.0,min_rates_total,Shift);
   IndInit(1,Ind2Buffer,0.0,min_rates_total,Shift);
   IndInit(2,Ind3Buffer,0.0,min_rates_total,Shift);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",
                     GetStringTimeframe(TimeFrame1),", ",
                     GetStringTimeframe(TimeFrame2),", ",
                     GetStringTimeframe(TimeFrame3),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- количество горизонтальных уровней индикатора 9   
   IndicatorSetInteger(INDICATOR_LEVELS,9);
//--- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Level2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,Level3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,Level4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,Level5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,5,Level6);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,6,Level7);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,7,Level8);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,8,Level9);
//--- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,5,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,6,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,7,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,8,clrBlue);
//--- Short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,5,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,6,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,7,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,8,STYLE_DASHDOTDOT);
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
   if(BarsCalculated(Ind1_Handle)<Bars(Symbol(),TimeFrame1)) return(prev_calculated);
   if(BarsCalculated(Ind2_Handle)<Bars(Symbol(),TimeFrame2)) return(prev_calculated);
   if(BarsCalculated(Ind3_Handle)<Bars(Symbol(),TimeFrame3)) return(prev_calculated);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame1,Ind1_Handle,0,Ind1Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame2,Ind2_Handle,0,Ind2Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame3,Ind3_Handle,0,Ind3Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
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
//--- calculations of the necessary amount of data to be copied
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
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
//---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- Copy new data to the Arr array
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
                     ENUM_TIMEFRAMES TFrame1, //Indicator 1 chart period (smallest timeframe)
                     ENUM_TIMEFRAMES TFrame2, //Indicator 2 chart period (medium timeframe)
                     ENUM_TIMEFRAMES TFrame3) //Indicator 3 chart period (highest timeframe)
  {
//--- checking correctness of the chart periods
   if(TFrame1<Period() && TFrame1!=PERIOD_CURRENT)
     {
      Print("Chart 1 period for the "+IndName+" indicator cannot be less than the period of the current chart!");
      Print("You must change the indicator input parameters!");
      return(RESET);
     }
   if(TFrame2<=TFrame1)
     {
      Print("Chart 2 period for the "+IndName+" indicator should be greater than the period of chart 1");
      Print("You must change the indicator input parameters!");
      return(RESET);
     }
   if(TFrame3<=TFrame2)
     {
      Print("Chart 3 period for the "+IndName+" indicator should be greater than the period of chart 2!");
      Print("You must change the indicator input parameters!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
