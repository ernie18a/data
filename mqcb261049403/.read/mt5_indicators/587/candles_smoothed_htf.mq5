//+---------------------------------------------------------------------+ 
//|                                            Candles_Smoothed_HTF.mq5 | 
//|                                Copyright © 2010,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 5
#property indicator_buffers 5 
//--- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0                           // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "Smoothed Candles" // The constant for the indicator name
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_COLOR_CANDLES
//--- the following colors are used for the indicator
#property indicator_color1  Gray, Magenta,Lime
//--- indicator 1 line width is equal to 4
#property indicator_width1  4
//--- bullish indicator label display
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

enum Applied_price_     // Type of constant
  {
   PRICE_CLOSE_ = 1,    // PRICE_CLOSE
   PRICE_OPEN_,         // PRICE_OPEN
   PRICE_HIGH_,         // PRICE_HIGH
   PRICE_LOW_,          // PRICE_LOW
   PRICE_MEDIAN_,       // PRICE_MEDIAN
   PRICE_TYPICAL_,      // PRICE_TYPICAL
   PRICE_WEIGHTED_,     // PRICE_WEIGHTED
   PRICE_SIMPLE,        // PRICE_SIMPLE
   PRICE_QUARTER_,      // PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_, // PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_  // PRICE_TRENDFOLLOW1_
  };
//+-------------------------------------+
//|  Indicator input parameters         |
//+-------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input uint AlertCount=0;                   // Number of submitted alerts
input uint SignalBar=1;                    // Signal bar index, 0 is a current bar
input Smooth_Method MA_Method=MODE_SMA;    // First smoothing averaging method 
input int Length=12;                       // First smoothing depth                    
input int Phase=15;                        // First smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;      // Price constant
input int Shift=0;                         // Horizontal shift of the indicator in bars
input int PriceShift=0;                    // Vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of a string variables
string Symbol_,Word;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int CANDL_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("CANDL indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of variables 
   min_rates_total=1;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- getting handle of the Candles_Smoothed indicator
   CANDL_Handle=iCustom(Symbol_,TimeFrame,"Candles_Smoothed",MA_Method,Length,Phase,IPC,0,PriceShift);
   if(CANDL_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Candles_Smoothed indicator");
      return(INIT_FAILED);
     }
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//--- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- indexing the elements in buffers as timeseries
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
//--- set ExtColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
//--- moving the indicator 1 horizontally
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ExtColorBuffer,true);
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
   if(BarsCalculated(CANDL_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declarations of local variables 
   double CndlHigh[1],CndlLow[1],CndlOpen[1],CndlClose[1];
   int limit,bar;
   datetime CndlTime[1];
   static uint UpCount,DnCount;
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
      //--- copy newly appeared data in the CndlTime[] array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,CndlTime)<=0) return(RESET);

      if(time[bar]>=CndlTime[0] && time[bar+1]<CndlTime[0])
        {
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(CANDL_Handle,0,time[bar],1,CndlOpen) <=0) return(RESET);
         if(CopyBuffer(CANDL_Handle,1,time[bar],1,CndlHigh) <=0) return(RESET);
         if(CopyBuffer(CANDL_Handle,2,time[bar],1,CndlLow)  <=0) return(RESET);
         if(CopyBuffer(CANDL_Handle,3,time[bar],1,CndlClose)<=0) return(RESET);

         ExtOpenBuffer [bar]=CndlOpen[0];
         ExtHighBuffer [bar]=CndlHigh[0];
         ExtLowBuffer  [bar]=CndlLow[0];
         ExtCloseBuffer[bar]=CndlClose[0];
        }
      else
        {
         ExtOpenBuffer [bar]=0.0;
         ExtHighBuffer [bar]=0.0;
         ExtLowBuffer  [bar]=0.0;
         ExtCloseBuffer[bar]=0.0;
        }
      ExtColorBuffer[bar]=0;
      if(ExtOpenBuffer[bar] && ExtCloseBuffer[bar])
        {
         if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=1;
         else                                       ExtColorBuffer[bar]=2;
        }
     }
//--- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }
//--- submission of an alert for buying
   if(UpCount<AlertCount && ExtColorBuffer[SignalBar]==2)
     {
      UpCount++;
      Alert(Word+": Signal for buying by "+Symbol_);
     }
//--- submission of an alert for selling
   if(DnCount<AlertCount && ExtColorBuffer[SignalBar]==1)
     {
      DnCount++;
      Alert(Word+": Signal for selling by "+Symbol_);
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
