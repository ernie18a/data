//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                      MARSICD.mq5 | 
//|                              Copyright © 2011,   John Q. Aimsson | 
//|                                                aimsson@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, John Q. Aimsson"
#property link "aimsson@gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 6 
//---- totally 6 graphical plots are used
#property indicator_plots   6

//+----------------------------------------------+
//| Indicator window size limitation             |
//+----------------------------------------------+
#property indicator_minimum -100
#property indicator_maximum 100
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 70
#property indicator_level2 30
#property indicator_level3 -30
#property indicator_level4 -70
#property indicator_level5 50
#property indicator_level6 -50
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1 DRAW_HISTOGRAM
//---- use gray color for the histogram
#property indicator_color1 Gray
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "RSI"

//---- drawing the indicator as a histogram
#property indicator_type2 DRAW_LINE
//---- use MediumOrchid color for the histogram
#property indicator_color2 MediumOrchid
//---- the indicator line is a dot-dash one
#property indicator_style2 STYLE_DASHDOTDOT
//---- Indicator line width is equal to 1
#property indicator_width2 1
//---- displaying the indicator label
#property indicator_label2 "Signal RSI"

//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- DodgerBlue color is used for indicator line
#property indicator_color3 DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Up RSI"

//---- drawing the indicator as a line
#property indicator_type4   DRAW_LINE
//---- DodgerBlue color is used for indicator line
#property indicator_color4 DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4  "Dn RSI"

//---- drawing the indicator as a line
#property indicator_type5   DRAW_LINE
//---- red color is used for indicator line
#property indicator_color5 Red
//---- the indicator line is a continuous curve
#property indicator_style5  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width5  1
//---- displaying the indicator label
#property indicator_label5  "Up Signal RSI"

//---- drawing the indicator as a line
#property indicator_type6   DRAW_LINE
//---- lime color is used for indicator line
#property indicator_color6 Lime
//---- the indicator line is a continuous curve
#property indicator_style6  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width6  1
//---- displaying the indicator label
#property indicator_label6  "Dn Signal RSI"

//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA,AXMA,RXMA;
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
/*enum Smooth_Method - the enumeration is declared in the SmoothAlgorithms.mqh file
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
  }; */
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input Smooth_Method MAMethod=MODE_LWMA; //smoothing method
input uint ARSI_PERIOD=14;              // RSI A period
input uint RRSI_PERIOD=14;              //RSI R period
input uint AMA_PERIOD=5;                //signal A period
input uint RMA_PERIOD=5;                //signal R period
input uint sMAD_PERIOD=21;              //signal period for the histogram
input uint MPhase=15; //smoothing parameter,
                      // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double ARSI_BUF[];
double RRSI_BUF[];
double AMA_BUF[];
double RMA_BUF[];
double Delta[];
double sMAD[];
//---- declaration of integer variables for the indicators handles
int ARSI_Handle,RRSI_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_total1,min_rates_total2;
//+------------------------------------------------------------------+   
//| MARSICD indicator initialization function                        | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation   
   min_rates_total1=int(MathMax(ARSI_PERIOD,RRSI_PERIOD));
   min_rates_total2=min_rates_total1+MathMax(XMA.GetStartBars(MAMethod,AMA_PERIOD,MPhase),XMA.GetStartBars(MAMethod,RMA_PERIOD,MPhase));
   min_rates_total=min_rates_total2+XMA.GetStartBars(MAMethod,sMAD_PERIOD,MPhase);

//---- getting handle of the RSI indicator
   ARSI_Handle=iRSI(NULL,0,ARSI_PERIOD,PRICE_WEIGHTED);
   if(ARSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the RSI indicator");

//---- getting handle of the RSI indicator
   RRSI_Handle=iRSI(NULL,0,RRSI_PERIOD,PRICE_WEIGHTED);
   if(RRSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the RSI indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Delta,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(Delta,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,sMAD,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(sMAD,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,RRSI_BUF,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(RRSI_BUF,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,ARSI_BUF,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ARSI_BUF,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,RMA_BUF,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(RMA_BUF,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(5,AMA_BUF,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(AMA_BUF,true);

//---- initializations of variable for indicator short name
   string shortname="MARSICD";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| MARSICD iteration function                                       | 
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(ARSI_Handle)<rates_total
      || BarsCalculated(RRSI_Handle)<rates_total
      || rates_total<min_rates_total) return(0);

//---- Declaration of integer variables
   int limit,to_copy,bar,maxbar1,maxbar2;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      limit=rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+1;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(ARSI_Handle,0,0,to_copy,ARSI_BUF)<=0) return(0);
   if(CopyBuffer(RRSI_Handle,0,0,to_copy,RRSI_BUF)<=0) return(0);

   maxbar1=rates_total-1-min_rates_total1;
   maxbar2=maxbar1-min_rates_total2;

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      RRSI_BUF[bar]*=(-1);
      RRSI_BUF[bar]+=100;
      AMA_BUF[bar]=AXMA.XMASeries(maxbar1,prev_calculated,rates_total,MAMethod,MPhase,AMA_PERIOD,ARSI_BUF[bar],bar,true);
      RMA_BUF[bar]=RXMA.XMASeries(maxbar1,prev_calculated,rates_total,MAMethod,MPhase,RMA_PERIOD,RRSI_BUF[bar],bar,true);
      Delta[bar]=AMA_BUF[bar]-RMA_BUF[bar];
      sMAD[bar]=XMA.XMASeries(maxbar2,prev_calculated,rates_total,MAMethod,MPhase,sMAD_PERIOD,Delta[bar],bar,true);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
