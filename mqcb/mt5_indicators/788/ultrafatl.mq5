//+------------------------------------------------------------------+
//|                                                    UltraFatl.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| The SmoothAlgorithms.mqh library                                 |
//| must be placed to terminal_data_folder\\MQL5\Include             |
//+------------------------------------------------------------------+
//---- copyright
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window
//---- buffers
#property indicator_buffers 3
//---- graphic plots
#property indicator_plots   1
//+-----------------------------------+ 
//|  constants                        |
//+-----------------------------------+ 
#define RESET 0 // reset
//+-----------------------------------+
//|  Indicator plot settings          |
//+-----------------------------------+
//---- plot as color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- colors, used by histogram
#property indicator_color1  Gray,Magenta,HotPink,Red,Brown,LimeGreen,Teal,Lime,PaleGreen
//---- histogram width
#property indicator_width1 4
//---- histogram label
#property indicator_label1 "Ultra Fatl"
//+-----------------------------------+
//| CXMA class                        |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of CXMA and CFATL class variables from SmoothAlgorithms.mqh library
CXMA XMA[];
CFATL Fatl;
//+-----------------------------------+
//|  enumerations                     |
//+-----------------------------------+
enum Applied_price_      // type
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  widths enumeration               |
//+-----------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+-----------------------------------+
//|  styles enumeration               |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,       // solid
   DASH_,        // dash
   DOT_,         // dot
   DASHDOT_,     // dash-dot
   DASHDOTDOT_   // dash-dot-dot
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input ENUM_APPLIED_PRICE Applied_price=PRICE_CLOSE; // Applied price
//----
input Smooth_Method W_Method=MODE_JJMA;             // Smoothing method
input int StartLength=3;                            // Initial smoothing period
input int WPhase=100;                               // Phase
//----  
input uint Step=5;                                  // Step
input uint StepsTotal=10;                           // Total steps
//----
input Smooth_Method SmoothMethod=MODE_JJMA;         // Smoothing method
input int SmoothLength=3;                           // Smoothing length
input int SmoothPhase=100;                          // Phase
input Applied_price_ IPC=PRICE_CLOSE_;              // Applied price
//----                          
input uint UpLevel=80;                              // Overbought level (in %)
input uint DnLevel=20;                              // Oversold level (in %)
input color UpLevelsColor=Blue;                     // Color of overbought level
input color DnLevelsColor=Blue;                     // Color of oversold level
input STYLE Levelstyle=DASH_;                       // Level style
input WIDTH  LevelsWidth=Width_1;                   // Level width
//+----------------------------------------------+
//---- declaration of dynamic arrays, used as indicator buffer
double BullsBuffer[];
double BearsBuffer[];
double ColorBuffer[];
//---- declaration of array, used for periods of the WPR signal lines
int period[];
//---- declaration of arrays, used for the averaged values of RSI indicator
double invalue0[],invalue1[];
//----
double dUpLevel,dDnLevel;
//---- declaration of integer variables
uint StTot1,StTot2;
int min_rates_total,min_rates_fatl,min_rates_xma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- resize arrays
   int size=int(StepsTotal+3);
   if(ArrayResize(XMA,size)<size) Print("Error in resize of XMA[] array");
   size-=2;
   if(ArrayResize(invalue0,size)<size) Print("Error in resize of invalue0[] array");
   if(ArrayResize(invalue1,size)<size) Print("Error in resize of invalue1[] array");
   if(ArrayResize(period,size)<size) Print("Error in resize of period[] array");

   ArrayInitialize(invalue0,0);
   ArrayInitialize(invalue1,0);
   ArrayInitialize(period,0);

//---- initialize variables переменных
   for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--) period[sm]=int(StartLength+sm*Step);
   dUpLevel=StepsTotal*UpLevel/100.0;
   dDnLevel=StepsTotal*DnLevel/100.0;

//---- set alerts for invalid parameters
   XMA[0].XMALengthCheck("StartLength", StartLength);
   XMA[0].XMAPhaseCheck("WPhase", WPhase, W_Method);
   XMA[0].XMALengthCheck("SmoothLength", SmoothLength);
   XMA[0].XMAPhaseCheck("SmoothPhase", SmoothPhase, SmoothMethod);

//---- set initial indexes
   min_rates_fatl=40;
   min_rates_xma=min_rates_fatl+XMA[0].GetStartBars(W_Method,StartLength+Step*StepsTotal,WPhase)+1;
   min_rates_total=min_rates_xma+XMA[0].GetStartBars(SmoothMethod,SmoothLength,SmoothPhase);
   StTot1=StepsTotal+1;
   StTot2=StepsTotal+2;

//---- set BullsBuffer[] as indicator buffer
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- set plot graw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- set indexing as time series
   ArraySetAsSeries(BullsBuffer,true);

//---- set BearsBuffer[] as indicator buffer
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- set indexing as time series
   ArraySetAsSeries(BearsBuffer,true);

//---- пset ColorBuffer[] as indicator buffer
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- set plot draw begin
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- set indexing as time series
   ArraySetAsSeries(ColorBuffer,true);

//---- prepare indicator name
   string shortname="Ultra Fatl";
//---- set indiсator short name
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,2);

//---- line settings
   IndicatorSetInteger(INDICATOR_LEVELS,2);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,dUpLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,dDnLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at current tick
                const int prev_calculated,// number of bars, calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // high prices
                const double& low[],      // low prices
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking of bars
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables
   int limit,bar,maxbar0,maxbar1,maxbar2;
   double upsch,dnsch,fatl,price;

//---- calculation of maxbar starting bar index for XMASeries()
   maxbar0=rates_total-1;
   maxbar1=maxbar0-min_rates_fatl;
   maxbar2=maxbar0-min_rates_xma;

//---- set limit for bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking of first call
      limit=maxbar0;                       // starting index for all bars
   else limit=rates_total-prev_calculated; // starting index for new bars

//---- set indexing as time series
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- calculation of indicator values
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      fatl=Fatl.FATLSeries(maxbar0,prev_calculated,rates_total,price,bar,true);

      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         invalue0[sm]=XMA[sm].XMASeries(maxbar1,prev_calculated,rates_total,W_Method,WPhase,period[sm],fatl,bar,true);

      if(bar>maxbar2)
        {
         if(bar) ArrayCopy(invalue1,invalue0,0,0,WHOLE_ARRAY);
         continue;
        }

      upsch=0;
      dnsch=0;
      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         if(invalue0[sm]>invalue1[sm]) upsch++;
      else                          dnsch++;

      BullsBuffer[bar]=XMA[StTot1].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,upsch,bar,true);
      BearsBuffer[bar]=XMA[StTot2].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,dnsch,bar,true);

      if(bar) ArrayCopy(invalue1,invalue0,0,0,WHOLE_ARRAY);
     }

//---- set starting index for bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking of first call
      limit--;

//---- calculation of indicator values
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorBuffer[bar]=0;

      if(BullsBuffer[bar]>BearsBuffer[bar])
        {
         if(BullsBuffer[bar]>dUpLevel || BearsBuffer[bar]<dDnLevel)
           {
            if(BullsBuffer[bar+1]<=BullsBuffer[bar]) ColorBuffer[bar]=7;
            else ColorBuffer[bar]=8;
           }
         else
           {
            if(BullsBuffer[bar+1]<=BullsBuffer[bar]) ColorBuffer[bar]=5;
            else ColorBuffer[bar]=6;
           }
        }

      if(BullsBuffer[bar]<BearsBuffer[bar])
        {
         if(BullsBuffer[bar]<dDnLevel || BearsBuffer[bar]>dUpLevel)
           {
            if(BearsBuffer[bar+1]<=BearsBuffer[bar]) ColorBuffer[bar]=1;
            else ColorBuffer[bar]=2;
           }
         else
           {
            if(BearsBuffer[bar+1]<=BearsBuffer[bar]) ColorBuffer[bar]=3;
            else ColorBuffer[bar]=4;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
