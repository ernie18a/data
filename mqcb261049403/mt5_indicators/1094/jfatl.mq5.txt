//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2011, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
 * For the indicator to work, place the files
 * MovSeriesTools_Cls.mqh
 * JJMASeries.mqh 
 * PriceSeries.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                        JFatl.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

//---- drawing the indicator in the main window
#property indicator_chart_window
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- only one plot is used
#property indicator_plots   1
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color1  Blue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "JFATL"
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
enum Applied_price_ //Type od constant
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
input int Length_=5; // depth of the JMA smoothing                   
input int Phase_=100; // parameter of the JMA smoothing,
                     //that changes within the range -100 ... +100,
//impacts the transitional process quality;
input Applied_price_ IPC=PRICE_CLOSE_;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int FATLShift=0; // horizontal shift of FATL in bars
input int PriceShift=0; // vertical shift of FATL in points
//---+
//---- declaration and initialization of a variable for storing the number of calculated bars
int FATLPeriod=39;

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double ExtLineBuffer[];

int start,fstart,FATLSize;
double dPriceShift;
//+X----------------------------------------------X+ 
//| Initialization of the coefficients of the      |
//| digital filter                                 |
//+X----------------------------------------------X+ 
double FATLTable[]=
  {
   +0.4360409450, +0.3658689069, +0.2460452079, +0.1104506886,
   -0.0054034585, -0.0760367731, -0.0933058722, -0.0670110374,
   -0.0190795053, +0.0259609206, +0.0502044896, +0.0477818607,
   +0.0249252327, -0.0047706151, -0.0272432537, -0.0338917071,
   -0.0244141482, -0.0055774838, +0.0128149838, +0.0226522218,
   +0.0208778257, +0.0100299086, -0.0036771622, -0.0136744850,
   -0.0160483392, -0.0108597376, -0.0016060704, +0.0069480557,
   +0.0110573605, +0.0095711419, +0.0040444064, -0.0023824623,
   -0.0067093714, -0.0072003400, -0.0047717710, +0.0005541115,
   +0.0007860160, +0.0130129076, +0.0040364019
  };
//+------------------------------------------------------------------+
// The iPriceSeries() function description                           |
// iPriceSeriesAlert() function description                          |
// CJJMA class description                                           |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- set ExtLineBuffer as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- initialization of variables 
   FATLSize=ArraySize(FATLTable);
   start=FATLSize+30;
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"JFATL(",Length_," ,",Phase_,")");
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//---- declaration of variable of the class CJJMA from the file JJMASeries_Cls.mqh
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external parameters
   JMA.JJMALengthCheck("Length_", Length_);
   JMA.JJMAPhaseCheck("Phase_", Phase_);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<start)
      return(0);

//---- declaration of local variables 
   int first,bar;
   double jfatl,FATL;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=FATLPeriod-1; // start number for calculation of all bars
      fstart=first;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- declaration of variable of the class CJJMA from the file JJMASeries_Cls.mqh
   static CJJMA JMA;

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      //---- formula for the FATL filter
      FATL=0.0;
      for(int iii=0; iii<FATLSize; iii++)
         FATL+=FATLTable[iii] *PriceSeries(IPC,bar-iii,open,low,high,close);

      //---- one call of the JJMASeries function. 
      //The parameters Phase and Length don't change at every bar (Din = 0) 
      jfatl=JMA.JJMASeries(fstart,prev_calculated,rates_total,0,Phase_,Length_,FATL,bar,false);

      //---- Initialization of the cell of indicator buffer by the obtained value of FATL
      ExtLineBuffer[bar]=jfatl+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
