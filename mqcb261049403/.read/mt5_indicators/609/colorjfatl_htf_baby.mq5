//+------------------------------------------------------------------+
//|                                          ColorJFatl_HTF_Baby.mq5 |
//|                             Copyright © 2010,   Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru |
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers 2
#property indicator_buffers 2 
//--- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0                         // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "JFatl HTF Baby" // The constant for the indicator name
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator as a segment
#property indicator_type1   DRAW_COLOR_SECTION
//--- gray, magenta and yellow colors are used for the indicator
#property indicator_color1  Gray,Magenta,Yellow
//--- indicator 1 line width is equal to 15
#property indicator_width1  15
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//|  Indicator window borders parameters         |
//+----------------------------------------------+
#property indicator_minimum -0.3
#property indicator_maximum +1.8
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
input int Length=5;                        // Smoothing depth                    
input int Phase=-100;                      // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;      // Applied price
input int Shift=0;                         // Horizontal shift of the indicator in bars
input int PriceShift=0;                    // Vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//--- declaration of string variables
string Symbol_,Word;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int JFatl_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("JFatl indicator chart period cannot be less than the current chart period");
      return(INIT_FAILED);
     }
//--- initialization of variables 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- getting handle of the JFatl indicator
   JFatl_Handle=iCustom(Symbol_,TimeFrame,"JFatl",Length,Phase,IPC,0,PriceShift);
   if(JFatl_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the JFatl indicator");
      return(INIT_FAILED);
     }
//--- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,117);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
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
//--- creating name for displaying if separate sub-window and in tooltip
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",EnumToString(TimeFrame)," ,",Length," ,",Phase,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(JFatl_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declarations of local variables 
   double JFatl[1];
   int limit,bar;
   datetime JFatlTime[1];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
   static double LastJFatl=0.0;
   static uint LastCountBar,LastColor;

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

      //--- copy newly appeared data in JFatlTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,JFatlTime)<=0) return(RESET);

      if(time[bar]>=JFatlTime[0] && time[bar+1]<JFatlTime[0])
        {
         //--- copy newly appeared data in JFatl array
         if(CopyBuffer(JFatl_Handle,0,time[bar],1,JFatl)<=0) return(RESET);

         IndBuffer[bar]=JFatl[0];
        }
     }

//--- starting index correction
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit--;                                          // starting index for calculation of all bars

//--- main loop of the signal line coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorIndBuffer[bar]=0;

      if(IndBuffer[bar])
        {
         if(LastJFatl)
           {
            if(LastJFatl<IndBuffer[bar]) ColorIndBuffer[bar]=2;
            if(LastJFatl>IndBuffer[bar]) ColorIndBuffer[bar]=1;
           }

         if(bar>0) LastJFatl=IndBuffer[bar];
         LastColor=int(ColorIndBuffer[bar]);
         IndBuffer[bar]=1;
        }
     }

   IndBuffer[0]=1;
   if(LastColor==2) ColorIndBuffer[0]=2;
   else             ColorIndBuffer[0]=1;

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
      Alert(Word+": Signal for selling by "+Symbol_);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
