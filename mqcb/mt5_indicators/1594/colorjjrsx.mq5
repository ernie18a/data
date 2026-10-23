//+---------------------------------------------------------------------+
//|                                                      ColorJJRSX.mq5 | 
//|                                Copyright © 2013,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Relative Strenght Index"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 3 
//---- only 2 plots are used
#property indicator_plots   2

//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- color is used for the color of the indicator line
#property indicator_color1 clrGray
//---- indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "JJRSX"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type2   DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the histogram
#property indicator_color2 clrRed,clrDarkOrange,clrGray,clrTeal,clrLime
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- the width of indicator line is equal to 3
#property indicator_width2  3
//---- displaying the indicator label
#property indicator_label2  "High Short;Short;Flat;Long;High Long"

//+------------------------------------------+
//| Description of smoothing classes and     |
//| indicators                               |
//+------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+-----------------------------------+
//---- //---- declaration of the CJMA and CJurX classes variables from the SmoothAlgorithms.mqh file
CJJMA JMA;
CJurX UpJurX,DnJurX;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
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
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndStyle //The indicator display style
  {
   COLOR_LINE = DRAW_COLOR_LINE,          //Colored line
   COLOR_HISTOGRAM=DRAW_COLOR_HISTOGRAM,  //Colored histogram
   COLOR_ARROW=DRAW_COLOR_ARROW           //Colored labels
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint JurXPeriod=8; //JurX period
input uint JMAPeriod=3;  //JMA period
input int JMAPhase=100;   //JMA averaging parameter,
                          // for JJMA it varies within the range -100 ... +100 and influences on the quality of the transient period;
input Applied_price_ IPC=PRICE_CLOSE; //price constant
input int Shift=0; //horizontal shift of the indicator in bars
input IndStyle Style=COLOR_HISTOGRAM; //JJRSX display style
input int HighLevel=+20; //upper level of triggering
input int MiddleLevel=0; //medium of the range
input int LowLevel=-20;  //lower level of triggering
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double JJRSX[];
double JJRSX_[];
double ColorJJRSX[];
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| JJRSX indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=2;
   min_rates_total=min_rates_+30;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,JJRSX_,INDICATOR_DATA);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,JJRSX,INDICATOR_DATA);
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(2,ColorJJRSX,INDICATOR_COLOR_INDEX);   
   
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   

//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- changing of the indicator display style   
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,Style);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Relative Strenght Index(",
                     string(JurXPeriod),",",string(JMAPeriod),",",string(JMAPhase),",",EnumToString(IPC),",",Shift,")");
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   
//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrPurple);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrPurple);
//---- horizontal level line is a short dash-and-dot line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| JJRSX iteration function                                         | 
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
   if(rates_total<min_rates_total) return(0);

//---- Declaration of variables with a floating point  
   double dPrice,AbsdPrice,jrsx,uprsx,dnrsx;
//---- Declaration of integer variables and getting the bars already calculated
   int first,clr;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) //checking for the first start of calculation of an indicator
     {
      first=1; // starting number for calculation of all bars
     }
   else
     {
      first=prev_calculated-1; //starting number for calculation of new bars
     }

//---- Main calculation loop of the indicator
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      dPrice=PriceSeries(IPC,bar,open,low,high,close)-PriceSeries(IPC,bar-1,open,low,high,close);     
      AbsdPrice=MathAbs(dPrice);
      
      //---- prohibition for zero divide!
      if(!AbsdPrice)  AbsdPrice=_Point;

      //---- preliminary initialization of the indicator buffer using an empty value
      JJRSX[bar]=EMPTY_VALUE;

      //---- Two calls of the JurXSeries function. 
      uprsx=UpJurX.JurXSeries(1,prev_calculated,rates_total,0,JurXPeriod,dPrice,bar,false);
      dnrsx=DnJurX.JurXSeries(1,prev_calculated,rates_total,0,JurXPeriod,AbsdPrice,bar,false);    
      jrsx=100*uprsx/dnrsx;
      
      //----One call of the  JMASeries function 
      JJRSX[bar]=JMA.JJMASeries(min_rates_,prev_calculated,rates_total,0,JMAPhase,JMAPeriod,jrsx,bar,false);         
      JJRSX_[bar]=JJRSX[bar];

      clr=2;
      if(JJRSX[bar]>JJRSX[bar-1]) {if(JJRSX[bar]>HighLevel) clr=4; else clr=3;}
      if(JJRSX[bar]<JJRSX[bar-1]) {if(JJRSX[bar]<LowLevel)  clr=0; else clr=1;}
      ColorJJRSX[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
