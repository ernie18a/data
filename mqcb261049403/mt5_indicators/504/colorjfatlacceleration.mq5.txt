/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                       ColorJFatlAcceleration.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- three buffers is used for calculation and drawing the indicator
#property indicator_buffers 3
//---- only two plots is used
#property indicator_plots   2

//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use gray color for the indicator
#property indicator_color1  Gray
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "JFATL Acceleration"

//---- drawing the indicator as a label
#property indicator_type2   DRAW_COLOR_ARROW
//---- Gray, dark orchid and red colors are used for the indicator
#property indicator_color2  Gray,DarkOrchid,Red
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "JFATL Acceleration"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPLE_,         //PRICE_SIMPLE_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_, //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_  //PRICE_TRENDFOLLOW1_
  };
input int SmLength_=8; // JMA period of Fatl smoothing                   
input int SmPhase_=100; // JMA parameter of Fatl smoothing,
                      //that changes within the range -100 ... +100
//impacts the transitional process quality;

input int SpeedPeriod=1;//Rate period
input int AccelerationPeriod=1;//Acceleration period

input int Smooth=2; // Depth of the JMA smoothing of the indicator                  
input int SmPhase=100; // Parameter of the JMA smoothing of the indicator
                       //that changes within the range -100 ... +100
//impacts the transitional process quality;

input Applied_price_ IPC=PRICE_CLOSE_;//Price constant
/* , used for the indicator calculation (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */

input int FATLShift=0; // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration and initialization of a variable for storing the number of FATL calculated bars
int FATLPeriod=39;

//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double IndBuffer[];
double ColorBuffer[];
double LineIndBuffer[];

int start,fstart,jfstart,mstart,spstart,FATLSize;
double dPriceShift;
//+------------------------------------------------------------------+
// The iPriceSeries() function description                           |
// Description of CFATL, CJJMA and CMomentum classes                 |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables
   fstart=FATLPeriod;
   jfstart=fstart+30;
   mstart=jfstart+SpeedPeriod;
   spstart=mstart+30+1;
   start=spstart+AccelerationPeriod;

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,LineIndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by FATLShift
   PlotIndexSetInteger(1,PLOT_SHIFT,FATLShift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- selecting a symbol for drawing
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JFATL Speed(",SmLength_," ,",SmPhase_," ,",SpeedPeriod,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- declaration of a CJJMA class variable from the JJMASeries_Cls.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("Length_", SmLength_);
   JMA.JJMAPhaseCheck("Phase_", SmPhase_);
   JMA.JJMALengthCheck("SpeedMomPeriod", SpeedPeriod);
   JMA.JJMALengthCheck("Smooth", Smooth);
   JMA.JJMAPhaseCheck("SmPhase", SmPhase);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total<start)
      return(0);

//---- declarations of local variables 
   int first,bar;
   double price,jfatl,fatl,jmom1,jmom2,jfspeed;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of the CFATL, CJJMA and CMomentum classes variables from the JJMASeries_Cls.mqh file
   static CJJMA JMA1,JMA2;
   static CFATL FATL;
   static CMomentum MOM1,MOM2;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- getting the input price
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- uploading the input price into FATLSeries() and getting fatl
      fatl=FATL.FATLSeries(0,prev_calculated,rates_total,price,bar,false);

      //---- uploading fatl into JJMASeries() and getting jfatl
      jfatl=JMA1.JJMASeries(fstart,prev_calculated,rates_total,0,SmPhase_,SmLength_,fatl,bar,false);

      //---- uploading jfatl into MomentumSeries() and getting jmom
      jmom1=MOM1.MomentumSeries(jfstart,prev_calculated,rates_total,SpeedPeriod,jfatl,bar,false);

      //---- uploading jmom into JJMASeries() and getting jfspeed
      jfspeed=JMA2.JJMASeries(mstart,prev_calculated,rates_total,0,SmPhase,Smooth,jmom1,bar,false);

      jmom2=MOM2.MomentumSeries(spstart,prev_calculated,rates_total,AccelerationPeriod,jfspeed,bar,false);

      //---- changing dimension of the indicator up to integer values
      jmom2/=_Point;

      //---- uploading jfspeed into the indicator buffer
      IndBuffer[bar]=jmom2;
      LineIndBuffer[bar]=jmom2;
     }

//---- correcting the value of the starting index for calculation of all bars
   if(prev_calculated>rates_total || prev_calculated<=0) first=start;

//---- Main loop of the signal line coloring
   for(bar=first; bar<rates_total; bar++)
     {
      ColorBuffer[bar]=0;
      if(IndBuffer[bar]>IndBuffer[bar-1]) ColorBuffer[bar]=1;
      if(IndBuffer[bar]<IndBuffer[bar-1]) ColorBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
