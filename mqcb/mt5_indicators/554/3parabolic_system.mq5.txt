//+------------------------------------------------------------------+
//|                                            3Parabolic System.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "3Parabolic System"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color1  Red
//---- indicator 1 width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Lower Parabolic"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type2   DRAW_ARROW
//---- blue color is used for the indicator
#property indicator_color2  Blue
//---- indicator 2 width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2 "Upper Parabolic"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color3  Magenta
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  "3Parabolic System Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color4  Lime
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label4 "3Parabolic System Buy"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint AlertCount=0;          // Number of submitted alerts
input uint SignalBar=1;           // Signal bar index, 0 is a current bar
//---- current timeframe iSAR indicator parameters
input double Junior_Step=0.02;    // Junior iSAR step
input double Junior_Maximum=0.2;  // Junior iSAR maximum
//---- middle timeframe iSAR indicator parameters
input ENUM_TIMEFRAMES Middle_TimeFrame=PERIOD_H1; // Middle iSAR chart period
input double Middle_Step=0.02;    // Middle iSAR step
input double Middle_Maximum=0.2;  // Middle iSAR maximum
//---- senior timeframe iSAR indicator parameters
input ENUM_TIMEFRAMES Senior_TimeFrame=PERIOD_H12; // Senior iSAR chart period
input double Senior_Step=0.02;    // Senior iSAR step
input double Senior_Maximum=0.2;  // Senior iSAR maximum
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double BuyBuffer[],SellBuffer[];
double UpSarBuffer[],DnSarBuffer[];
//---- declaration of a variable for storing the indicator initialization result
bool Init;
//---- declaration of integer variables for the indicators handles
int JSAR_Handle,MSAR_Handle,SSAR_Handle;
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   Init=true;
//---- checking correctness of the chart periods
   if(Middle_TimeFrame<Period())
     {
      Print("Middle iSAR chart period cannot be less than the current chart period");
      Init=false;
      return;
     }

   if(Senior_TimeFrame<Middle_TimeFrame)
     {
      Print("Senior iSAR chart period cannot be less than the middle iSAR chart period");
      Init=false;
      return;
     }

//---- initialization of variables    
   min_rates_total=3;

//---- getting handle of the iSAR Junior indicator
   JSAR_Handle=iSAR(NULL,PERIOD_CURRENT,Junior_Step,Junior_Maximum);
   if(JSAR_Handle==INVALID_HANDLE) Print(" Failed to get handle of iSAR Junior indicator");
//---- getting handle of the iSAR Middle indicator
   MSAR_Handle=iSAR(NULL,Middle_TimeFrame,Middle_Step,Middle_Maximum);
   if(MSAR_Handle==INVALID_HANDLE) Print(" Failed to get handle of iSAR Middle indicator");
//---- getting handle of the iSAR Senior indicator
   SSAR_Handle=iSAR(NULL,Senior_TimeFrame,Senior_Step,Senior_Maximum);
   if(SSAR_Handle==INVALID_HANDLE) Print(" Failed to get handle of iSAR Senior indicator");

//---- set UpSarBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,UpSarBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,158);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(UpSarBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set DnSarBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,DnSarBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(DnSarBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,108);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,108);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows
   string short_name="3Parabolic System";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- display of the indicator name at the upper left corner of the chart 
   Comment("3Parabolic System");
//----   
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
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
   if(BarsCalculated(JSAR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int limit,to_copy,bar;
   double JSAR[],MSAR[],SSAR[];
   static uint UpCount,DnCount;
//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total+1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars 
   to_copy=limit+2;
//---- copy newly appeared data in the JSAR[] array
   if(CopyBuffer(JSAR_Handle,0,0,to_copy,JSAR)<=0) return(RESET);
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(JSAR,true);
   ArraySetAsSeries(MSAR,true);
   ArraySetAsSeries(SSAR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Zero out the contents of the indicator buffers for calculation
      DnSarBuffer[bar]=0.0;
      UpSarBuffer[bar]=0.0;

      if(open[bar]<JSAR[bar]) UpSarBuffer[bar]=JSAR[bar];
      else                    DnSarBuffer[bar]=JSAR[bar];
     }
//---- recalculation of the starting index for calculation of all bars
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation     
      limit--;
//---- the second indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Zero out the contents of the indicator buffers for calculation
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---- copy the newly appeared data into the MSAR[] and SSAR[] arrays
      if(CopyBuffer(MSAR_Handle,0,time[bar],1,MSAR)<=0) return(RESET);
      if(CopyBuffer(SSAR_Handle,0,time[bar],1,SSAR)<=0) return(RESET);

      if(UpSarBuffer[bar+1]>0.0&&DnSarBuffer[bar]>0.0&&close[bar]>MSAR[0]&&close[bar]>SSAR[0]) BuyBuffer [bar]=JSAR[bar];
      if(DnSarBuffer[bar+1]>0.0&&UpSarBuffer[bar]>0.0&&close[bar]<MSAR[0]&&close[bar]<SSAR[0]) SellBuffer[bar]=JSAR[bar];
     }
//---- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }
//---- submission of an alert for buying
   if(UpCount<AlertCount && BuyBuffer[SignalBar])
     {
      UpCount++;
      Alert("3Parabolic System indicator: "+Symbol()+EnumToString(PERIOD_CURRENT)+": ""Buy signal "+Symbol());
     }
//---- submission of an alert for selling
   if(DnCount<AlertCount && SellBuffer[SignalBar])
     {
      DnCount++;
      Alert("3Parabolic System indicator: "+Symbol()+EnumToString(PERIOD_CURRENT)+": ""Sell signal "+Symbol());
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
