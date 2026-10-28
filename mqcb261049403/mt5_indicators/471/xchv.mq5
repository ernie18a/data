/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh file
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                         XCHV.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Chaikin Volatility"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use slate blue color for the indicator line
#property indicator_color1 SlateBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "XCHV"

//+----------------------------------------+
//| CXMA and CMomentum classes description |
//+----------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA and CMomentum classes from the SmoothAlgorithms.mqh file
CXMA XMA;
CMomentum MOM;
//+-----------------------------------+
//|  enumerations declaration         |
//+-----------------------------------+
/*enum Smooth_Method //enumeration is declared in the SmoothAlgorithms.mqh file
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
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int SmoothPeriod=10;  //Smoothing period
input int Phase_=15;   //Smoothing period,
                       //for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input int CHVPeriod=10;     // CHV period
input Smooth_Method SmoothMethod=MODE_T3; //Smoothing method
input int Shift=0; //Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double XCHV[];

//---- Declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+   
//| XCHV indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   StartBars=CHVPeriod+XMA.GetStartBars(SmoothMethod,SmoothPeriod,Phase_);
//---- setting up alerts for unacceptable values of external variables
   XMA.XMALengthCheck("SmoothPeriod", SmoothPeriod);
   XMA.XMALengthCheck("CHVPeriod", CHVPeriod);
//---- setting up alerts for unacceptable values of external variables
   XMA.XMAPhaseCheck("Phase_",Phase_,SmoothMethod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XCHV,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XCHV");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname,Smooth=XMA.GetString_MA_Method(SmoothMethod);
   StringConcatenate(shortname,"Chaikin Volatility(",string(SmoothPeriod),",",string(CHVPeriod),",",Smooth,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XCHV iteration function                                          | 
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
   if(rates_total<StartBars) return(0);

//---- Declaration of variables with a floating point  
   double velue,xvelue,mom,dmom;
//---- Declaration of integer variables
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      velue=high[bar]-low[bar];

      //---- One call of the XMASeries function and one call of the MomentumSeries function 
      xvelue=XMA.XMASeries(0,prev_calculated,rates_total,SmoothMethod,Phase_,SmoothPeriod,velue,bar,false);
      mom = MOM.MomentumSeries(SmoothPeriod, prev_calculated, rates_total, CHVPeriod, xvelue, bar, false);
      dmom=xvelue-mom;

      //---- indicator buffer initialization
      if(bar<StartBars)
        {
         XCHV[bar]=EMPTY_VALUE;
         continue;
        }
      else if(dmom!=0.0) XCHV[bar]=100.0*mom/(dmom);
      else XCHV[bar]=EMPTY_VALUE;;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
