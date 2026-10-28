//+------------------------------------------------------------------+ 
//|                                                   JFATL_3HTF.mq5 | 
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- Indicator version number
#property version   "1.00"
#property description "Three JFatl indicators with different timeframes with the same parameters on one chart."
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "JFatl" // The constant for the indicator name
#define SIZE 3                 // A constant for the number of calls of the CountIndicator function in the code
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- the color of the indicator
#property indicator_color1  clrLimeGreen
//--- the width of the indicator 1 line
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME+"1"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the color of the indicator
#property indicator_color2  clrBlue
//--- line width of indicator 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  INDICATOR_NAME+"2"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//--- Drawing indicator 3 as line
#property indicator_type3   DRAW_LINE
//--- the color of the indicator
#property indicator_color3  clrMagenta
//--- line width of indicator 3
#property indicator_width3  3
//--- displaying the indicator label
#property indicator_label3  INDICATOR_NAME+"3"
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
//|  declaration of enumerations                 |
//+----------------------------------------------+
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
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_M30; // Indicator 1 chart period (smallest timeframe)
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H1; // Indicator 2 chart period (medium timeframe)
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H4; // Indicator 3 chart period (highest timeframe)
input int Length=5;                          // Depth of smoothing                    
input int Phase=-100;                        // Smoothing parameter
//--- Phase: for JJMA it varies within the range -100 ... +100, influences the quality of the transient period;
//--- Phase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;        // Price constant
input int Shift=0;                           // Horizontal shift of the indicator in bars
input int PriceShift=0;                      // Vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
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
//--- Checking correctness of the chart periods
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame1,TimeFrame2,TimeFrame3)) return(INIT_FAILED);
//--- initialization of variables 
   min_rates_total=2;
//--- getting handle of the JFatl 1 indicator
   Ind1_Handle=iCustom(Symbol(),TimeFrame1,INDICATOR_NAME,Length,Phase,IPC,0,PriceShift);
   if(Ind1_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the JFatl 1 indicator");
      return(INIT_FAILED);
     }
//--- getting handle of the JFatl 2 indicator
   Ind2_Handle=iCustom(Symbol(),TimeFrame2,INDICATOR_NAME,Length,Phase,IPC,0,PriceShift);
   if(Ind2_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the JFatl 2 indicator");
      return(INIT_FAILED);
     }
//--- getting handle of the JFatl 3 indicator
   Ind3_Handle=iCustom(Symbol(),TimeFrame3,INDICATOR_NAME,Length,Phase,IPC,0,PriceShift);
   if(Ind3_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the JFatI3 indicator");
      return(INIT_FAILED);
     }
//--- initialize indicator buffers
   IndInit(0,Ind1Buffer,0.0,min_rates_total,Shift);
   IndInit(1,Ind2Buffer,0.0,min_rates_total,Shift);
   IndInit(2,Ind3Buffer,0.0,min_rates_total,Shift);
//--- Creating a name for displaying in a separate sub-window and in tooltip
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",
                     GetStringTimeframe(TimeFrame1),", ",
                     GetStringTimeframe(TimeFrame2),", ",
                     GetStringTimeframe(TimeFrame3),", ",
                     Length,", ",Phase,")");
//---                     
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Set accuracy of displaying for the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
                    const int rates_total,     // amount of history in bars at the current tick
                    const int prev_calculated, // number of bars calculated at previous call
                    const int Min_Rates_Total) // minimum amount of history in bars for calculation
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+rates_total-prev_calculated; // Starting index for calculation of new bars 

//--- The main loop of the indicator calculation
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
//--- Checking correctness of the chart periods
   if(TFrame1<Period() && TFrame1!=PERIOD_CURRENT)
     {
      Print("Chart 1 period for the "+IndName+" indicator cannot be less than the period of the current chart!");
      Print ("You must change the indicator input parameters!");
      return(RESET);
     }

   if(TFrame2<=TFrame1)
     {
      Print ("Chart 2 period for the "+IndName+" indicator should be greater than the period of chart 1");
      Print ("You must change the indicator input parameters!");
      return(RESET);
     }

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
