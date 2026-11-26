//+------------------------------------------------------------------------+ 
//|                                              JFatlAcceleration_HTF.mq5 | 
//|                                   Copyright © 2010,   Nikolay Kositsin | 
//|                                    Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                    |
//| in the directory: terminal_data_folder\MQL5\Include                    |
//| and also place ColorJFatlAcceleration.mq5 file in the directory:       |
//| terminal_data_folder\MQL5\Indicators                                   |
//+------------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 4
#property indicator_buffers 4 
//--- four plots are used in total
#property indicator_plots   4
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0                             // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "JFatl Acceleration" // The constant for the indicator name
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//--- red color is used for the indicator
#property indicator_color1  Red
//--- indicator 1 line width is equal to 4
#property indicator_width1  4
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME" Sell Max"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//--- lime color is used for the indicator
#property indicator_color2  Lime
//--- indicator 2 line width is equal to 4
#property indicator_width2  4
//--- displaying the indicator label
#property indicator_label2 INDICATOR_NAME" Buy Max"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//--- magenta color is used for the indicator
#property indicator_color3  Magenta
//--- the indicator 3 line width is equal to 4
#property indicator_width3  4
//--- displaying the indicator label
#property indicator_label3  INDICATOR_NAME" Sell Min"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//--- yellow color is used as the color of the bullish indicator line
#property indicator_color4  Yellow
//--- the indicator 4 line width is equal to 4
#property indicator_width4  4
//--- displaying the indicator label
#property indicator_label4 INDICATOR_NAME" Buy Min"
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
enum Smooth_Method
  {
   MODE_SMA_,   // SMA
   MODE_EMA_,   // EMA
   MODE_SMMA_,  // SMMA
   MODE_LWMA_,  // LWMA
   MODE_JJMA,   // JJMA
   MODE_JurX,   // JurX
   MODE_ParMA,  // ParMA
   MODE_T3,     // T3
   MODE_VIDYA,  // VIDYA
   MODE_AMA,    // AMA
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
input uint LableShift=100;                 // Labels vertical shift
input uint AlertCount=0;                   // Number of submitted alerts
input uint SignalBar=1;                    // Signal bar index, 0 is a current bar
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input int Length_=8;                       // JMA period of Fatl smoothing
input int Phase_=100;                      // JMA parameter of Fatl smoothing [-100...+100]
input int SpeedPeriod=1;                   // Speed period
input int AccelerationPeriod=1;            // Acceleration period
input int Smooth=2;                        // Indicator JMA smoothing depth                  
input int SmPhase=100;                     // Indicator JMA smoothing parameter [-100...+100]
input Applied_price_ IPC=PRICE_CLOSE_;     // Applied price
input int FATLShift=0;                     // Horizontal shift of the indicator in bars
//--- declaration of dynamic arrays that 
//--- will be used as indicator buffers
double BuyMaxBuffer[],SellMaxBuffer[];
double BuyMinBuffer[],SellMinBuffer[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of a string variables
string Symbol_,Word;
//--- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//--- declaration of integer variables for the indicators handles
int JFAccel_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("ColorJFatlAcceleration indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of variables 
   min_rates_total=(39+30+SpeedPeriod+30+1+AccelerationPeriod)*PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT);
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- getting handle of the ColorJFatlAcceleration indicator
   JFAccel_Handle=iCustom(Symbol_,TimeFrame,"ColorJFatlAcceleration",Length_,Phase_,SpeedPeriod,AccelerationPeriod,Smooth,SmPhase,IPC,0);
   if(JFAccel_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ColorJFatlAcceleration indicator");
      return(INIT_FAILED);
     }
//--- set SellMaxBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SellMaxBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellMaxBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//--- set BuyMaxBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyMaxBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyMaxBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//--- set SellMinBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,SellMinBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,234);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellMinBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//--- set BuyMinBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyMinBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,233);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyMinBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

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
   if(BarsCalculated(JFAccel_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
   
//--- declarations of local variables 
   double JFAccel[2];
   int limit,bar;
   datetime JFAccelTime[1];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      BuyMaxBuffer[bar]=0.0;
      SellMaxBuffer[bar]=0.0;
      BuyMinBuffer[bar]=0.0;
      SellMinBuffer[bar]=0.0;

      //--- copy newly appeared data in the JFAccelTime[] array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,JFAccelTime)<=0) return(RESET);

      if(time[bar]>=JFAccelTime[0] && time[bar+1]<JFAccelTime[0])
        {
         LastCountBar=bar;

         //--- copy newly appeared data in the JFAccel array
         if(CopyBuffer(JFAccel_Handle,0,time[bar],2,JFAccel)<=0) return(RESET);

         if(JFAccel[1]<0)
           {
            if(JFAccel[0]>JFAccel[1]) SellMaxBuffer[bar]=high[bar]+LableShift*_Point;
            else                      SellMinBuffer[bar]=high[bar]+LableShift*_Point;
           }
         else
           {
            if(JFAccel[0]>JFAccel[1]) BuyMinBuffer[bar]=low[bar]-LableShift*_Point;
            else                      BuyMaxBuffer[bar]=low[bar]-LableShift*_Point;
           }
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
   if(UpCount<AlertCount && BuyMaxBuffer[SignalBar])
     {
      UpCount++;
      Alert(Word+": Strong signal for buying by "+Symbol_);
     }

//--- submission of an alert for selling
   if(DnCount<AlertCount && SellMaxBuffer[SignalBar])
     {
      DnCount++;
      Alert(Word+": Strong signal for buying by "+Symbol_);
     }

//--- submission of an alert for buying
   if(UpCount_<AlertCount && BuyMinBuffer[SignalBar])
     {
      UpCount_++;
      Alert(Word+": Weak signal for buying by "+Symbol_);
     }

//--- submission of an alert for selling
   if(DnCount_<AlertCount && SellMinBuffer[SignalBar])
     {
      DnCount_++;
      Alert(Word+": Weak signal for buying by "+Symbol_);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
