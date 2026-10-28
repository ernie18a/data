//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
 * The operation of the indicator requires
 * SmoothAlgorithms.mqh file 
 * in the directory: MetaTrader\\MQL5\Include
 * 
 * ColorJFatlSpeed.mq5
 * should be placed in the directory: MetaTrader\\MQL5\Indicators
 */
//+------------------------------------------------------------------+ 
//|                                               JFatlSpeed_HTF.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- only four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "JFatl Speed" // The constant for the indicator name
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- red color is used as the color of the bearish indicator line
#property indicator_color1  Red
//---- width of the indicator 1 line is equal to 4
#property indicator_width1  4
//---- displaying the bullish label of the indicator
#property indicator_label1  INDICATOR_NAME" Sell Max"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color2  Lime
//---- width of the indicator 2 line is equal to 4
#property indicator_width2  4
//---- displaying the bearish label of the indicator
#property indicator_label2 INDICATOR_NAME" Buy Max"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color3  Magenta
//---- the width of the indicator 3 line is 4
#property indicator_width3  4
//---- displaying the bullish label of the indicator
#property indicator_label3  INDICATOR_NAME" Sell Min"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- yellow color is used as the color of the bullish line of the indicator
#property indicator_color4  Yellow
//---- width of the indicator 4 line is equal to 4
#property indicator_width4  4
//---- displaying the bearish label of the indicator
#property indicator_label4 INDICATOR_NAME" Buy Min"
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
enum Smooth_Method
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
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_, //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_  //PRICE_TRENDFOLLOW1_
  };
//+-------------------------------------+
//|  INDICATOR INPUT PARAMETERS         |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Chart period
input uint LableShift=100;//Labels vertical shift
input uint AlertCount=0;//Number of alerts
input uint SignalBar=1;//Signal bar index, 0 is a current bar
//+-------------------------------------+
//|  INDICATOR INPUT PARAMETERS         |
//+-------------------------------------+
input int Length_=8; // JMA period of Fatl smoothing                   
input int Phase_=100; // JMA parameter of Fatl smoothing,
                      //varying within the range -100 ... +100,
//impacts the transitional process quality;

input int MomPeriod=1;//Momentum indicator period for rate measuring

input int Smooth=2; // Depth of the JMA smoothing of the indicator                  
input int SmPhase=100; // Parameter of the JMA smoothing of the indicator
                       //varying within the range -100 ... +100,
//impacts the transitional process quality;

input Applied_price_ IPC=PRICE_CLOSE_;//price constant
/* , used for the indicator calculation ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */

//input int FATLShift=0; // Horizontal shift of the indicator in bars
//+-------------------------------------+
//---- declaration of dynamic arrays that will further 
// be used as indicator buffers
double BuyMaxBuffer[],SellMaxBuffer[];
double BuyMinBuffer[],SellMinBuffer[];
//---- Declaration of a variable for storing the indicator initialization result
bool Init;
//---- Declaration of strings
string Symbol_,Word;
//---- Declaration of integer variables of data starting point
int  min_rates_total;
//---- Declaration of integer variables for the indicator handles
int JFAccel_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//---- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("ColorJFatlSpeed indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }

//---- Initialization of variables 
   min_rates_total=(39+30+MomPeriod+30+1)*PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT);
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- getting handle of the JFAccel indicator
   JFAccel_Handle=iCustom(Symbol_,TimeFrame,"ColorJFatlSpeed",Length_,Phase_,MomPeriod,Smooth,SmPhase,IPC,0);
   if(JFAccel_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ColorJFatlSpeed indicator");
      return(INIT_FAILED);
     }
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellMaxBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,174);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellMaxBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyMaxBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,174);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyMaxBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,SellMinBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,174);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellMinBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyMinBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 3 drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,174);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyMinBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(JFAccel_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- declaration of local variables 
   double JFAccel[2];
   int limit,bar;
   datetime JFAccelTime[1];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
   static uint LastCountBar;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for the calculation
      BuyMaxBuffer[bar]=0.0;
      SellMaxBuffer[bar]=0.0;
      BuyMinBuffer[bar]=0.0;
      SellMinBuffer[bar]=0.0;

      //---- copy newly appeared data to the JFAccelTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,JFAccelTime)<=0) return(RESET);

      if(time[bar]>=JFAccelTime[0] && time[bar+1]<JFAccelTime[0])
        {
         LastCountBar=bar;

         //---- copy newly appeared data to the JFAccel array
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

//---- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
      UpCount_=0;
      DnCount_=0;
     }

//---- submission of an alert for buying
   if(UpCount<AlertCount && BuyMaxBuffer[SignalBar])
     {
      UpCount++;
      Alert(Word+": Strong signal for buying by "+Symbol_);
     }

//---- submission of an alert for selling
   if(DnCount<AlertCount && SellMaxBuffer[SignalBar])
     {
      DnCount++;
      Alert(Word+": Strong signal for buying by "+Symbol_);
     }

//---- submission of an alert for buying
   if(UpCount_<AlertCount && BuyMinBuffer[SignalBar])
     {
      UpCount_++;
      Alert(Word+": Weak signal for buying by "+Symbol_);
     }

//---- submission of an alert for selling
   if(DnCount_<AlertCount && SellMinBuffer[SignalBar])
     {
      DnCount_++;
      Alert(Word+": Weak signal for selling by "+Symbol_);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
