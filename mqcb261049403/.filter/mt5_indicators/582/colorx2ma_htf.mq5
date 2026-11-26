//+------------------------------------------------------------------+ 
//|                                                ColorX2MA_HTF.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru |
//+------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                              |
//| to the directory: terminal_data_folder\MQL5\Include              |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 2
#property indicator_buffers 2 
//--- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0               // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "X2MA" // The constant for the indicator name
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_COLOR_ARROW
//--- gray, magenta and blue violet colors are used for the indicator
#property indicator_color1  Gray,Magenta,BlueViolet
//--- indicator 1 line width is equal to 4
#property indicator_width1  4
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//|  Declaration of enumerations                 |
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
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // PRICE_CLOSE
   PRICE_OPEN_,          // PRICE_OPEN
   PRICE_HIGH_,          // PRICE_HIGH
   PRICE_LOW_,           // PRICE_LOW
   PRICE_MEDIAN_,        // PRICE_MEDIAN
   PRICE_TYPICAL_,       // PRICE_TYPICAL
   PRICE_WEIGHTED_,      // PRICE_WEIGHTED
   PRICE_SIMPLE,         // PRICE_SIMPLE
   PRICE_QUARTER_,       // PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  // PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   // PRICE_TRENDFOLLOW1_
  };
//+-------------------------------------+
//|  Indicator input parameters         |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input uint AlertCount=0;                   // Number of submitted alerts
input uint SignalBar=1;                    // Signal bar index, 0 is a current bar
input Smooth_Method MA_Method1=MODE_SMA;   // First smoothing averaging method 
input int Length1=12;                      // First smoothing depth                    
input int Phase1=15;                       // First smoothing parameter
input Smooth_Method MA_Method2=MODE_JJMA;  // Second smoothing averaging method 
input int Length2=5;                       // Second smoothing depth 
input int Phase2=15;                       // Second smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;      // Price constant
input int Shift=0;                         // Horizontal shift of the indicator in bars
input int PriceShift=0;                    // Vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of a string variables
string Symbol_,Word;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int X2MA_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("X2MA indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of variables 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- getting handle of the X2MA indicator
   X2MA_Handle=iCustom(Symbol_,TimeFrame,"X2MA",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,IPC,0,PriceShift);
   if(X2MA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the X2MA indicator");
      return(INIT_FAILED);
     }
//--- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(IndBuffer,true);

//--- set ColorIndBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(X2MA_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declarations of local variables 
   double X2MA[1];
   int limit,bar;
   datetime X2MATime[1];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
   static double LastX2MA=0.0;
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1;                   // starting index for calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      LastCountBar=bar;
      //--- zero out the contents of the indicator buffers for calculation
      IndBuffer[bar]=0.0;
      //--- copy newly appeared data in the X2MATime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,X2MATime)<=0) return(RESET);
      if(time[bar]>=X2MATime[0] && time[bar+1]<X2MATime[0])
        {
         //--- copy newly appeared data in the X2MA array
         if(CopyBuffer(X2MA_Handle,0,time[bar],1,X2MA)<=0) return(RESET);
         IndBuffer[bar]=X2MA[0];
        }
     }
//--- starting index correction
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit--; // starting index for calculation of all bars
//--- main coloring cycle 
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorIndBuffer[bar]=0;
      if(IndBuffer[bar])
        {
         if(LastX2MA)
           {
            if(LastX2MA<IndBuffer[bar]) ColorIndBuffer[bar]=2;
            if(LastX2MA>IndBuffer[bar]) ColorIndBuffer[bar]=1;
           }
         if(bar>0) LastX2MA=IndBuffer[bar];
        }
     }
//--- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
      UpCount_=0;
      DnCount_=0;
     }
//--- submission of an alert for buying
   if(UpCount<AlertCount && ColorIndBuffer[SignalBar]==2)
     {
      UpCount++;
      Alert(Word+": Signal for buying by "+Symbol_);
     }
//--- submission of an alert for selling
   if(DnCount<AlertCount && ColorIndBuffer[SignalBar]==1)
     {
      DnCount++;
      Alert(Word+": Сигнал на продажу по "+Symbol_);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
