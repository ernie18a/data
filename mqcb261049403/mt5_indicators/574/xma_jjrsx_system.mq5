//+---------------------------------------------------------------------+ 
//|                                                XMA JJRSX System.mq5 | 
//|                                Copyright © 2010,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- four plots are used in total
#property indicator_plots   4
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0                           // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "XMA JJRSX System" // The constant for the indicator name
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color1  Magenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- displaying the indicator label
#property indicator_label1  INDICATOR_NAME" Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type2   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color2  Lime
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- displaying the indicator label
#property indicator_label2 INDICATOR_NAME" Buy"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color3  Red
//---- the indicator 3 line width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  INDICATOR_NAME" Buy Stop"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- green color is used for the indicator
#property indicator_color4  Green
//---- the indicator 4 line width is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label4 INDICATOR_NAME" Sell Stop"
//+-------------------------------------+
//|  Declaration of enumerations        |
//+-------------------------------------+
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
input uint SignalLableShift=100;              // Entries vertical shift
input uint StopLableShift=300;                // Stops vertical shift
input uint AlertCount=0;                      // Number of submitted alerts
input uint SignalBar=1;                       // Signal bar index, 0 is a current bar
//+-------------------------------------+
//|  XMA indicator input parameters     |
//+-------------------------------------+
input ENUM_TIMEFRAMES TimeFrame_XMA=PERIOD_H4; // XMA chart period
input Smooth_Method MA_Method_XMA=MODE_T3;     // XMA averaging method
input int Length_XMA=12;                       // XMA smoothing depth                 
input int Phase_XMA=15;                        // XMA smoothing parameter [-100...+100]
input Applied_price_ IPC_XMA=PRICE_CLOSE;      // XMA applied price
//+-------------------------------------+
//|  JJRSX indicator input parameters   |
//+-------------------------------------+
input int Length_JJRSX=8;                      // JJRSX smoothing depth
input int Smooth_JJRSX = 8;                    // JJRSX averaging JJMA depth
input int Phase_JJRSX = 100;                   // JJRSX averaging JJMA parameter [-100..+100]
input Applied_price_ IPC_JJRSX=PRICE_CLOSE_;   // JJRSX applied price
//+-------------------------------------+
//---- declaration of dynamic arrays that 
//---- will be used as indicator buffers
double BuyBuffer[],SellBuffer[];
double BuyStopBuffer[],SellStopBuffer[];
//---- declaration of a variable for storing the indicator initialization result
bool Init;
//---- declaration of a string variables
string Symbol_,Word;
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//---- declaration of integer variables for the indicators handles
int XMA_Handle,JJRSX_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//---- checking correctness of the chart periods
   if(TimeFrame_XMA<Period() && TimeFrame_XMA!=PERIOD_CURRENT)
     {
      Print("XMA indicator chart period cannot be less than the current chart period");
      Init=false;
      return(1);
     }

//---- initialization of variables    
   min_rates_total=36;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- getting handle of the XMA indicator
   XMA_Handle=iCustom(NULL,TimeFrame_XMA,"XMA",MA_Method_XMA,Length_XMA,Phase_XMA,IPC_XMA,0,0);
   if(XMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the XMA indicator");
      return(2);
     }

//---- getting handle of the JJRSX indicator
   JJRSX_Handle=iCustom(NULL,PERIOD_CURRENT,"JJRSX",Length_JJRSX,Smooth_JJRSX,Phase_JJRSX,IPC_JJRSX);
   if(JJRSX_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the JJRSX indicator");
      return(1);
     }

//---- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set BuyStopBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,BuyStopBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,108);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyStopBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set SellStopBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,SellStopBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,108);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellStopBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- displaying the indicator name at the upper left corner of the chart 
   Comment(INDICATOR_NAME);
//---- initialization end
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(JJRSX_Handle)<rates_total || rates_total<min_rates_total || !Init) return(RESET);

//---- declarations of local variables 
   int limit,to_copy,bar;
   double JJRSX[],XMA[4];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
   static int StopSignal=0;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total+1;              // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;              // starting index for calculation of new bars 
   to_copy=limit+4;

//---- copy newly appeared data in the JJRSX array
   if(CopyBuffer(JJRSX_Handle,0,0,to_copy,JJRSX)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(XMA,true);
   ArraySetAsSeries(JJRSX,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for calculation
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      BuyStopBuffer[bar]=0.0;
      SellStopBuffer[bar]=0.0;

      //---- copy newly appeared data in the XMA array
      if(CopyBuffer(XMA_Handle,0,time[bar],4,XMA)<=0) return(RESET);

      if(XMA[1]<XMA[2]&&XMA[2]>XMA[3]&&StopSignal>=0) {StopSignal=-1; BuyStopBuffer [bar]=high[bar]+StopLableShift*_Point;}
      if(XMA[1]>XMA[2]&&XMA[2]<XMA[3]&&StopSignal<=0) {StopSignal=+1; SellStopBuffer[bar]=low [bar]-StopLableShift*_Point;}

      if(JJRSX[bar+2]<JJRSX[bar+1] && JJRSX[bar+1]>JJRSX[bar] && XMA[3]<XMA[2]) SellBuffer[bar]=high[bar]+SignalLableShift*_Point;
      if(JJRSX[bar+2]>JJRSX[bar+1] && JJRSX[bar+1]<JJRSX[bar] && XMA[3]>XMA[2]) BuyBuffer [bar]=low [bar]-SignalLableShift*_Point;
     }

//---- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
      UpCount_=0;
      DnCount_=0;
     }

//---- submission of an alert for buying
   if(UpCount<AlertCount && BuyBuffer[SignalBar])
     {
      UpCount++;
      Alert(Word+": Signal for buying by "+Symbol_);
     }

//---- submission of an alert for selling
   if(DnCount<AlertCount && SellBuffer[SignalBar])
     {
      DnCount++;
      Alert(Word+": Signal for selling by "+Symbol_);
     }

//---- submission of an alert for closing short positions
   if(UpCount_<AlertCount && BuyStopBuffer[SignalBar])
     {
      UpCount_++;
      Alert(Word+": Signal for exiting short positions by "+Symbol_);
     }

//---- submission of an alert for closing long positions
   if(DnCount_<AlertCount && SellStopBuffer[SignalBar])
     {
      DnCount_++;
      Alert(Word+": Signal for exiting long positions by "+Symbol_);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
