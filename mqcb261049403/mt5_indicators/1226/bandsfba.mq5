//+------------------------------------------------------------------+
//|                                                     BandsFBA.mq5 |
//|                                      Copyright © 2010, Svinozavr |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2010, Svinozavr"
//---- author of the indicator
#property link      ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- six buffers are used for calculation of drawing of the indicator
#property indicator_buffers 6
//---- six graphical plots are used
#property indicator_plots   6
//+--------------------------------------------+
//|  BB levels indicator drawing parameters    |
//+--------------------------------------------+
//---- drawing Bollinger Bands as lines
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
//---- selection of Bollinger Bands colors
#property indicator_color1  clrPurple
#property indicator_color2  clrPurple
#property indicator_color3  clrPurple
#property indicator_color4  clrRed
#property indicator_color5  clrRed
#property indicator_color6  clrRed
//---- Bollinger Bands are dott-dash curves
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- Bollinger Bands are continuous curves
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
//---- Bollinger Bands width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
//+----------------------------------------------+
//|  Averaging classes description               |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA XMA;
CStdDeviation STD;
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
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
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method bMA_Method=MODE_SMA; //first smoothing method
input int bLength=20; //period of averaging of BB                  
input int bPhase=15; //first smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input double BandsDeviation=2.0; //Bollinger deviation
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */

input uint FrontPeriod=1; // front smoothing period; <1
input uint BackPeriod=55; // damping smoothing period; <1
input int BShift=0; // horizontal shift of the indicator in bars
input int SShift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double  XMAB[]; // XMA
double  TopB[]; // top line
double  BotB[]; // bottom line
double  XMAS[]; // top signal line
double  TopS[]; // top signal line
double  BotS[]; // bottom signal line
//---- declaration of variables for the EMA coefficients
double per0,per1;
int FBA; // 1 - front smoothing, -1 - damping smoothing, 0 - normal MA - smooth all!
//---- Declaration of integer variables of data starting point
int min_rates_,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   string _fr=string(FrontPeriod);
   string _bk=string(BackPeriod);
   string _dv=string(BandsDeviation);
   string ShortName="BandsFBA";
   string _sg=_fr;
   FBA=0;

//---- front and damping
   if(FrontPeriod==BackPeriod)
     {
      FBA=0;
      per0=2.0/(1+FrontPeriod);
      per1=+1;
     }

   if(FrontPeriod<BackPeriod)
     {
      FBA=-1;
      per0=2.0/(1+FrontPeriod);
      per1=2.0/(1+BackPeriod);
     }
   else
     {
      FBA=+1;
      per0=2.0/(1+BackPeriod);
      per1=2.0/(1+FrontPeriod);
      _sg=_bk;
     }

//---- Initialization of variables of the start of data calculation
   min_rates_=XMA.GetStartBars(bMA_Method,bLength,bPhase);
   min_rates_total=2*min_rates_+1;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XMAB,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,BShift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XMA("+string(bLength)+")");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,TopB,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,BShift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"TopB(+"+_dv+")");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,BotB,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,BShift);
//---- shifting the starting point for drawing indicator 3 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"BotB(-"+_dv+")");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,XMAS,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,SShift);
//---- shifting the starting point for drawing indicator 4 by min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create a label to display in DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"XMAS("+_sg+")");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,TopS,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(4,PLOT_SHIFT,SShift);
//---- shifting the starting point for drawing indicator 4 by min_rates_total
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create a label to display in DataWindow
   PlotIndexSetString(4,PLOT_LABEL,"TopS("+_fr+","+_bk+")");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(5,BotS,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(5,PLOT_SHIFT,SShift);
//---- shifting the starting point for drawing indicator 4 by min_rates_total
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create a label to display in DataWindow
   PlotIndexSetString(5,PLOT_LABEL,"BotS("+_fr+","+_bk+")");

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int first,bar,minbar;
   double price_,xmaa,stdeva,xmab,stdevb,stdevc;
   static double prev_stdevb,prev_stdevc,prev_xmab;

   minbar=min_rates_total-1;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0; // starting number for calculation of all bars
      prev_stdevb=1.0;
      prev_stdevc=1.0;
      prev_xmab=PriceSeries(IPC,first,open,low,high,close);
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calculate initial moving average 
      price_=PriceSeries(IPC,bar,open,low,high,close);
      xmaa=XMA.XMASeries(0,prev_calculated,rates_total,bMA_Method,bPhase,bLength,price_,bar,false);
      XMAB[bar]=xmaa;

      //---- Bollinger Bands calculation   
      stdeva=STD.StdDevSeries(min_rates_,prev_calculated,rates_total,bLength,BandsDeviation,price_,xmaa,bar,false);
      TopB[bar]=xmaa+stdeva;
      BotB[bar]=xmaa-stdeva;

      if(bar<minbar) continue;
      else if(bar==minbar)
        {
         prev_stdevb=stdeva;
         prev_stdevc=stdeva;
         prev_xmab=price_;
        }

      xmab=EMA_FBA(xmaa,prev_xmab,per0,0);
      XMAS[bar]=xmab;

      stdevb=EMA_FBA(stdeva,prev_stdevb,per0,0);
      stdevc=EMA_FBA(stdevb,prev_stdevc,per1,FBA);

      TopS[bar]=xmab+stdevc;
      BotS[bar]=xmab-stdevc;

      if(bar<rates_total-1)
        {
         prev_stdevb=stdevb;
         prev_stdevc=stdevc;
         prev_xmab=xmab;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| calculation of EMA FBA                                           |
//+------------------------------------------------------------------+
/* 
 * The EMA with different smoothing pframeters for the front and dumping
 * double Series     input signal
 * double EMA1       EMA values on the previous bar
 * double period     smoothing period; if >1, then recalculated into EMA coefficient 
 * int FBA          +1 - front smoothing, 
 *                  -1 - dumping smoothing,
 *                   0 - normal EMA - smooth all!
 */
//+------------------------------------------------------------------+
double EMA_FBA(double Series,double EMA1,double period,int fba)
  {
//----
   if(period==1) return(Series);

//---- coeff. EMA 
   if(period>1) period=2.0/(1+period);

//---- EMA
   double EMA=period*Series+(1-period)*EMA1;

//---- separation of front and dumping
   switch(fba)
     {
      case  0: /* normal MA */ return(EMA);
      case  1: /* front smoothing */ if(Series>EMA1) return(EMA); else return(Series);
      case -1: /* dumping smoothing */ if(Series<EMA1) return(EMA); else return(Series);
     }
//----
   return(EMA);
  }
//+------------------------------------------------------------------+
