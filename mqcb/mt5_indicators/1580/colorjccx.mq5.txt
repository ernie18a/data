//+---------------------------------------------------------------------+
//|                                                       ColorJCCX.mq5 | 
//|                                Copyright © 2013,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Commodity Chanel Index"
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
//---- use the following color for the indicator line
#property indicator_color1 clrGray
//---- indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "JCCX"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type2   DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the histogram
#property indicator_color2 clrRed,clrDarkOrange,clrGray,clrDeepSkyBlue,clrBlue
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width2  3
//---- displaying the indicator label
#property indicator_label2  "High Short;Short;Flat;Long;High Long"

//+------------------------------------------------+
// Description of smoothing classes and indicators |
//+------------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+-----------------------------------+
//---- declaration of the CJMA and CJurX classes variables from the SmoothAlgorithms.mqh file
CJJMA JMA;
CJurX UpJurX,DnJurX;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
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
input uint JMAPeriod=8;  //JMA period
input int JMAPhase=100;   //JMA smoothing parameter, for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
input uint JurXPeriod=8; //JurX period
input Applied_price_ IPC=PRICE_CLOSE; //price constant
input int Shift=0; //horizontal shift of the indicator in bars
input IndStyle Style=COLOR_HISTOGRAM; //JCCX display style
input int HighLevel=+20; //trigger top level
input int MiddleLevel=0; //middle of the range
input int LowLevel=-20;  //trigger bottom level
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double JCCX[];
double JCCX_[];
double ColorJCCX[];
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| JCCX indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=30+1;
   min_rates_total=min_rates_+3;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,JCCX_,INDICATOR_DATA);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,JCCX,INDICATOR_DATA);
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorJCCX,INDICATOR_COLOR_INDEX);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- changing of the indicator display style   
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,Style);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Commodity Chanel Index(",
                     string(JMAPeriod),",",string(JMAPhase),",",string(JurXPeriod),",",EnumToString(IPC),",",Shift,")");
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
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
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| JCCX iteration function                                          | 
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
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double price,jprice,upccx,dnccx,jupccx,jdnccx;
//---- Declaration of integer variables and getting the bars already calculated
   int first,clr;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1; // starting number for calculation of all bars
     }
   else
     {
      first=prev_calculated-1; // starting number for calculation of new bars
     }

//---- Main calculation loop of the indicator
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- preliminary initialization of the indicator buffer using an empty value
      JCCX[bar]=EMPTY_VALUE;

      //---- one call of the JMASeries function 
      jprice=JMA.JJMASeries(1,prev_calculated,rates_total,0,JMAPhase,JMAPeriod,price,bar,false);

      upccx=price-jprice;
      dnccx=MathAbs(upccx);

      //---- two calls of the JurXSeries function 
      jupccx=UpJurX.JurXSeries(min_rates_,prev_calculated,rates_total,0,JurXPeriod,upccx,bar,false);
      jdnccx=DnJurX.JurXSeries(min_rates_,prev_calculated,rates_total,0,JurXPeriod,dnccx,bar,false);

      //---- indicator buffer initialization
      if(jupccx) // prohibition for zero divide!
         JCCX[bar]=100*jupccx/jdnccx;

      JCCX_[bar]=JCCX[bar];

      clr=2;
      if(JCCX[bar]>JCCX[bar-1]) {if(JCCX[bar]>HighLevel) clr=4; else clr=3;}
      if(JCCX[bar]<JCCX[bar-1]) {if(JCCX[bar]<LowLevel)  clr=0; else clr=1;}
      ColorJCCX[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
