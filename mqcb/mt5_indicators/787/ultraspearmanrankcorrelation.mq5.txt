//+------------------------------------------------------------------+
//|                                 UltraSpearmanRankCorrelation.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| The SmoothAlgorithms.mqh include file                            |
//| must be placed to terminal_data_folder\\MQL5\Include             |
//+------------------------------------------------------------------+
//---- copyright
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link
#property link "farria@mail.redcom.ru"
//---- version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window
//---- number of buffers used (3)
#property indicator_buffers 3
//---- number of plots used (1)
#property indicator_plots   1
//+-----------------------------------+ 
//|  constants                        |
//+-----------------------------------+ 
#define RESET 0 // Reset
//+-----------------------------------+
//| Indicator plot settings           |
//+-----------------------------------+
//---- drawing style - color histogram 2
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- histogram colors
#property indicator_color1  Gray,Magenta,HotPink,Red,Brown,RoyalBlue,MediumBlue,DeepSkyBlue,LightSkyBlue
//---- histogram width
#property indicator_width1 4
//---- histogram label
#property indicator_label1 "Ultra SpearmanRankCorrelation"
//+-----------------------------------+
//| CXMA class                        |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of CXMA class variables from SmoothAlgorithms.mqh
CXMA XMA[];
//+-----------------------------------+
//|  width enumeration                |
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
//|  style enumeration                |
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
input int  rangeN=14;
//----
input Smooth_Method W_Method=MODE_JJMA;             // Smooth method
input int StartLength=3;                            // Start length
input int WPhase=100;                               // Phase
//----  
input uint Step=5;                                  // Period step
input uint StepsTotal=10;                           // Steps total
//----
input Smooth_Method SmoothMethod=MODE_JJMA;         // Smooth method
input int SmoothLength=3;                           // Smooth length
input int SmoothPhase=100;                          // Smooth phase
//----                          
input uint UpLevel=80;                              // Overbought level (in %)
input uint DnLevel=20;                              // Oversold level (in %)
input color UpLevelsColor=Blue;                     // Overbought level color
input color DnLevelsColor=Blue;                     // Oversold level color
input STYLE Levelstyle=DASH_;                       // Level style
input WIDTH  LevelsWidth=Width_1;                   // Level width
//+----------------------------------------------+
//---- declaration of dynamic arrays, used as indicator buffers
double BullsBuffer[];
double BearsBuffer[];
double ColorBuffer[];
//---- declaration of period[] array, used for a periods of the signal lines of SpearmanRankCorrelation indicator
int period[];
//---- variables, used for averaged values of SpearmanRankCorrelation indicator
double invalue0[],invalue1[];
//----
double dUpLevel,dDnLevel;
//---- integer variable for handle
int SRC_Handle;
//---- variables, used for the calculations
int Maxrange=30;
uint StTot1,StTot2;
int min_rates_total,min_rates_src,min_rates_xma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- prepare arrays
   int size=int(StepsTotal+3);
   if(ArrayResize(XMA,size)<size) Print("Error in ArrayResize of XMA[] array");
   size-=2;
   if(ArrayResize(invalue0,size)<size) Print("Error in ArrayResize of invalue0[] array");
   if(ArrayResize(invalue1,size)<size) Print("Error in ArrayResize of invalue1[] array");
   if(ArrayResize(period,size)<size) Print("Error in ArrayResize of period[] array");

   ArrayInitialize(invalue0,0);
   ArrayInitialize(invalue1,0);
   ArrayInitialize(period,0);   
   
//---- get handle of SpearmanRankCorrelation indicator
   SRC_Handle=iCustom(NULL,0,"SpearmanRankCorrelation",rangeN,0,Maxrange,true);
   if(SRC_Handle==INVALID_HANDLE)
     {
      Print("Error in creation of SpearmanRankCorrelation indicator");
      return(1);
     }

//---- initialization of variables
   for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--) period[sm]=int(StartLength+sm*Step);
   dUpLevel=StepsTotal*UpLevel/100.0;
   dDnLevel=StepsTotal*DnLevel/100.0;

//---- set alerts for invalid parameters
   XMA[0].XMALengthCheck("StartLength", StartLength);
   XMA[0].XMAPhaseCheck("WPhase", WPhase, W_Method);
   XMA[0].XMALengthCheck("SmoothLength", SmoothLength);
   XMA[0].XMAPhaseCheck("SmoothPhase", SmoothPhase, SmoothMethod);

//---- initialization of variables for indexes
   min_rates_src=rangeN;
   min_rates_xma=min_rates_src+XMA[0].GetStartBars(W_Method,StartLength+Step*StepsTotal,WPhase)+1;
   min_rates_total=min_rates_xma+XMA[0].GetStartBars(SmoothMethod,SmoothLength,SmoothPhase);
   StTot1=StepsTotal+1;
   StTot2=StepsTotal+2;

//---- set BullsBuffer[] as indicator buffer
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- set plot draw begin for indicator 1 to min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- set indexing as time series
   ArraySetAsSeries(BullsBuffer,true);

//---- set BearsBuffer[] as indicator buffer
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- set plot draw begin for indicator 2 to min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- set indexing as time series
   ArraySetAsSeries(BearsBuffer,true);

//---- set ColorBuffer[] as indicator buffer
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- set plot draw begin
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- set indexing as time series
   ArraySetAsSeries(ColorBuffer,true);

//---- prepare indicator short name
   string shortname="Ultra Spearman RankCorrelation";
//--- set indicator short name (shown in the indicator window and tooltip)
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,2);

//---- set indicator levels
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
int OnCalculate(const int rates_total,    // bars in history at current tick
                const int prev_calculated,// bars in history at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of High prices (used in calculations)
                const double& low[],      // price array of Low prices (used in calculations)
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- check calculated bars
   if(BarsCalculated(SRC_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables
   int to_copy,limit,bar,maxbar0,maxbar1,maxbar2;
   double upsch,dnsch,SRC[];

//---- calculation of starting bar index (maxbar) for XMASeries() method
   maxbar0=rates_total-1;
   maxbar1=maxbar0-min_rates_src;
   maxbar2=maxbar0-min_rates_xma;

//---- calculation of starting bar index imit for recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking of first call
      limit=maxbar0;                       // starting index for all bars
   else limit=rates_total-prev_calculated; // starting index for new bars
   to_copy=limit+1;

//---- set indexing as time series
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(SRC,true);
   
//---- copy new data to arrays
   if(CopyBuffer(SRC_Handle,0,0,to_copy,SRC)<=0) return(RESET);

//---- calculation of indicator values
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         invalue0[sm]=XMA[sm].XMASeries(maxbar1,prev_calculated,rates_total,W_Method,WPhase,period[sm],SRC[bar],bar,true);

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

//---- modify starting index limit for recalculations
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
