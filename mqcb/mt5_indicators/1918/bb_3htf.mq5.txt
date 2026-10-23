//+------------------------------------------------------------------+ 
//|                                                      BB_3HTF.mq5 | 
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- Indicator version number
#property version   "1.00"
#property description "Three Bollinger Bands with different timeframes with the same parameters on one chart."
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 6
#property indicator_buffers 6 
//--- 6 plots are used
#property indicator_plots   6
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                         // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "BollingerBands" // A constant for the indicator name
#define SIZE 6                          // A constant for the number of calls of the CountIndicator function
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- the color of the indicator
#property indicator_color1  clrBlueViolet
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME+"Up 1"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the color of the indicator
#property indicator_color2  clrBlueViolet
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  INDICATOR_NAME+"Down 1"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//--- Drawing indicator 3 as line
#property indicator_type3   DRAW_LINE
//--- the color of the indicator
#property indicator_color3  clrRoyalBlue
//--- the width of the indicator 3 line is 4
#property indicator_width3  4
//--- displaying the indicator label
#property indicator_label3  INDICATOR_NAME+"Up 2"
//+----------------------------------------------+
//|  Indicator 4 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 4 as a line
#property indicator_type4   DRAW_LINE
//--- the color of the indicator
#property indicator_color4  clrRoyalBlue
//--- the width of the indicator 4 line is equal to 4
#property indicator_width4  4
//--- displaying the indicator label
#property indicator_label4  INDICATOR_NAME+"Down 2"
//+----------------------------------------------+
//|  Indicator 5 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 5 as a line
#property indicator_type5   DRAW_LINE
//--- the color of the indicator
#property indicator_color5  clrDeepPink
//--- thickness of the indicator 5 line is equal to 5
#property indicator_width5  5
//--- displaying the indicator label
#property indicator_label5  INDICATOR_NAME+"Up 3"
//+----------------------------------------------+
//|  Indicator 6 drawing parameters              |
//+----------------------------------------------+
//--- Drawing indicator 6 as line
#property indicator_type6   DRAW_LINE
//--- the color of the indicator
#property indicator_color6  clrDeepPink
//--- thickness of the indicator 6 line is equal to 5
#property indicator_width6  5
//--- displaying the indicator label
#property indicator_label6  INDICATOR_NAME+"Down 3"
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_M30;         // Indicator 1 chart period (smallest timeframe)
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H1;          // Indicator 2 chart period (medium timeframe)
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H4;          // Indicator 3 chart period (highest timeframe)
//---
input uint                BBPeriod=20;               // Average line calculation period
input double              StdDeviation=2;            // Number of deviations
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE; // Price type
input int                 Shift=0;                   // Horizontal shift of the indicator in bars
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
double Ind4Buffer[];
double Ind5Buffer[];
double Ind6Buffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- Declaration of integer variables for indicators handles
int Ind1_Handle,Ind2_Handle,Ind3_Handle;
//+------------------------------------------------------------------+
//|  Get timeframe as string                                         |
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
//--- getting handle of the iBands 1 indicator
   Ind1_Handle=iBands(Symbol(),TimeFrame1,BBPeriod,0,StdDeviation,applied_price);
   if(Ind1_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iBands 1");
      return(INIT_FAILED);
     }
//--- getting handle of the iBands 2 indicator
   Ind2_Handle=iBands(Symbol(),TimeFrame2,BBPeriod,0,StdDeviation,applied_price);
   if(Ind2_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iBands 2");
      return(INIT_FAILED);
     }
//--- getting handle of the iBands 3 indicator
   Ind3_Handle=iBands(Symbol(),TimeFrame3,BBPeriod,0,StdDeviation,applied_price);
   if(Ind3_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iBands 3");
      return(INIT_FAILED);
     }
//--- initialize indicator buffers
   IndInit(0,Ind1Buffer,0.0,min_rates_total,Shift);
   IndInit(1,Ind2Buffer,0.0,min_rates_total,Shift);
   IndInit(2,Ind3Buffer,0.0,min_rates_total,Shift);
   IndInit(3,Ind4Buffer,0.0,min_rates_total,Shift);
   IndInit(4,Ind5Buffer,0.0,min_rates_total,Shift);
   IndInit(5,Ind6Buffer,0.0,min_rates_total,Shift);
//--- creating a name for displaying in a separate sub-window and in tooltip
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",
                     GetStringTimeframe(TimeFrame1),", ",
                     GetStringTimeframe(TimeFrame2),", ",
                     GetStringTimeframe(TimeFrame3),", ",
                     DoubleToString(StdDeviation,1)," ,",EnumToString(applied_price),")");

   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set accuracy of displaying for the indicator values
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
   if(BarsCalculated(Ind1_Handle)<Bars(Symbol(),TimeFrame1)) return(prev_calculated);
   if(BarsCalculated(Ind2_Handle)<Bars(Symbol(),TimeFrame2)) return(prev_calculated);
   if(BarsCalculated(Ind3_Handle)<Bars(Symbol(),TimeFrame3)) return(prev_calculated);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame1,Ind1_Handle,UPPER_BAND,Ind1Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame1,Ind1_Handle,LOWER_BAND,Ind2Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame2,Ind2_Handle,UPPER_BAND,Ind3Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(3,NULL,TimeFrame2,Ind2_Handle,LOWER_BAND,Ind4Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(4,NULL,TimeFrame3,Ind3_Handle,UPPER_BAND,Ind5Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(5,NULL,TimeFrame3,Ind3_Handle,LOWER_BAND,Ind6Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
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
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // The number of the CountLine function in the list in the indicator code (starting number - 0)
                    string   Symb,            // Chart symbol
                    ENUM_TIMEFRAMES TFrame,   // Chart period
                    int      IndHandle,       // The handle of the processed indicator
                    uint     BuffNumb,        // The number of the buffer of the processed indicator
                    double&  IndBuf[],        // receiving buffer of the indicator
                    const datetime& iTime[],  // Timeseries of time
                    const int Rates_Total,    // Amount of history in bars on the current tick
                    const int Prev_Calculated,// amount of history in bars at the previous tick
                    const int Min_Rates_Total)// minimum amount of history in bars for calculation
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- calculations of the necessary amount of data to be copied and
//--- the limit starting index for loop of bars recalculation
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
      //--- Copy new data to the IndTime array
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
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
//--- сhecking correctness of the chart periods
   if(TFrame1<Period() && TFrame1!=PERIOD_CURRENT)
     {
      Print("Chart 1 period for the "+IndName+" indicator cannot be less than the period of the current chart!");
      Print ("You must change the indicator input parameters!");
      return(RESET);
     }
//---
   if(TFrame2<=TFrame1)
     {
      Print ("Chart 2 period for the "+IndName+" indicator should be greater than the period of chart 1");
      Print ("You must change the indicator input parameters!");
      return(RESET);
     }
//---
   if(TFrame3<=TFrame2)
     {
      Print ("Chart 3 period for the "+IndName+" indicator should be greater than the period of chart 2!");
      Print ("You must change the indicator input parameters!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
