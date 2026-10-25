//+---------------------------------------------------------------------+
//|                                                 ColorJFatlSpeed.mq5 |
//|                                  Copyright © 2010, Nikolay Kositsin |
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- three buffers are used for calculation and drawing the indicator
#property indicator_buffers 3
//---- only two plots are used
#property indicator_plots   2
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use gray color for the indicator
#property indicator_color1  Gray
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator line label
#property indicator_label1  "JFATL SPEED"
//---- drawing the indicator as a label
#property indicator_type2   DRAW_COLOR_ARROW
//---- Gray, Blue and Magenta colors are used for the indicator
#property indicator_color2  Gray,Blue,Magenta
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "JFATL SPEED"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // PRICE_CLOSE
   PRICE_OPEN_,          // PRICE_OPEN
   PRICE_HIGH_,          // PRICE_HIGH
   PRICE_LOW_,           // PRICE_LOW
   PRICE_MEDIAN_,        // PRICE_MEDIAN
   PRICE_TYPICAL_,       // PRICE_TYPICAL
   PRICE_WEIGHTED_,      // PRICE_WEIGHTED
   PRICE_SIMPLE,         // PRICE_SIMPLE
   PRICE_QUARTER_,       // PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  // PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   // PRICE_TRENDFOLLOW1_
  };
input int LengthFatl=8;                 // JMA period of Fatl smoothing                   
input int PhaseFatl=100;                // JMA smoothing Fatl parameter [-100...+100],
input int MomPeriod=1;                  // Momentum indicator period for rate measuring
input int Smooth=2;                     // Indicator JMA smoothing depth                  
input int SmPhase=100;                  // Indicator JMA smoothing parameter [-100...+100]
input Applied_price_ IPC=PRICE_CLOSE_;  // Applied price
input int FATLShift=0;                  // Horizontal shift of the indicator in bars
//---- declaration and initialization of a variable for storing the number of FATL calculated bars
int FATLPeriod=39;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer[];
double ColorBuffer[];
double LineIndBuffer[];
int start,fstart,jfstart,mstart,FATLSize;
double dPriceShift;
//+------------------------------------------------------------------+
//| iPriceSeries() function description                              |
//| CFATL, CJJMA and CMomentum classes description                   |
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
   mstart=jfstart+MomPeriod;
   start=mstart+30+1;

//---- set LineIndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,LineIndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by FATLShift
   PlotIndexSetInteger(1,PLOT_SHIFT,FATLShift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- selecting a symbol for drawing
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//---- set ColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JFATL Speed(",LengthFatl," ,",PhaseFatl," ,",MomPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- declaration of a variable of the CJJMA class
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("Length_", LengthFatl);
   JMA.JJMAPhaseCheck("Phase_", PhaseFatl);
   JMA.JJMALengthCheck("MomPeriod", MomPeriod);
   JMA.JJMALengthCheck("Smooth", Smooth);
   JMA.JJMAPhaseCheck("SmPhase", SmPhase);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
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
   double price,jfatl,fatl,jmom,jfspeed;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0;                   // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of the CFATL, CJJMA and CMomentum classes variables
   static CJJMA JMA1,JMA2;
   static CFATL FATL;
   static CMomentum MOM;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- getting the input price
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- uploading the input price into FATLSeries() and getting fatl
      fatl=FATL.FATLSeries(0,prev_calculated,rates_total,price,bar,false);

      //---- uploading fatl into JJMASeries() and getting jfatl
      jfatl=JMA1.JJMASeries(fstart,prev_calculated,rates_total,0,PhaseFatl,LengthFatl,fatl,bar,false);

      //---- uploading jfatl into MomentumSeries() and getting jmom
      jmom=MOM.MomentumSeries(jfstart,prev_calculated,rates_total,MomPeriod,jfatl,bar,false);

      //---- uploading jmom into JJMASeries() and getting jfspeed
      jfspeed=JMA2.JJMASeries(mstart,prev_calculated,rates_total,0,SmPhase,Smooth,jmom,bar,false);

      //---- changing dimension of the indicator up to integer values
      jfspeed/=_Point;

      //---- uploading jfspeed into the indicator buffer
      IndBuffer[bar]=jfspeed;
      LineIndBuffer[bar]=jfspeed;
     }

//---- correcting the value of the starting index for calculation of all bars
   if(prev_calculated>rates_total || prev_calculated<=0) first=start;

//---- main loop of the signal line coloring
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
