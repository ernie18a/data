/*
* Place the SmoothAlgorithms.mqh file
* to the terminal_data_folder\MQL5\Include
*/
//+------------------------------------------------------------------+
//|                                               ColorJMomentum.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- only four plots are used
#property indicator_plots   4
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use gray color for the indicator line
#property indicator_color1 Gray
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "JMomentum"

//+----------------------------------------------+
//| Bullish indicator drawing parameters         |
//+----------------------------------------------+
//---- drawing indicator as a symbol
#property indicator_type2   DRAW_ARROW
//---- color of the bullish indicator is spring green
#property indicator_color2 SpringGreen
//---- the width of the indicator line is 3
#property indicator_width2 3
//---- displaying the indicator bullish symbol label
#property indicator_label2 "Up_Signal"
//+----------------------------------------------+
//| Bearish indicator drawing parameters         |
//+----------------------------------------------+
//---- drawing indicator as a symbol
#property indicator_type3   DRAW_ARROW
//---- use deep pink color for the bearish indicator
#property indicator_color3  DeepPink
//---- the width of the indicator line is 3
#property indicator_width3 3
//---- displaying the indicator bearish symbol label
#property indicator_label3 "Dn_Signal"
//+----------------------------------------------+
//| The non-trend indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing indicator as a symbol
#property indicator_type4   DRAW_ARROW
//---- gray color is used for the non-trend indicator
#property indicator_color4  Gray
//---- the width of the indicator line is 3
#property indicator_width4 3
//---- displaying the indicator non-trend symbol label
#property indicator_label4 "No_Signal"
//+-----------------------------------+
//|  Indicator input parameters       |
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
   PRICE_SIMPLE,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
input int SLength=8;                  // Momentum indicator period 
input int JLength=8;                  // Momentum indicator JMA smoothing depth                  
input int JPhase=100;                 // JMA smoothing parameter,
                                      //that changes within the range -100 ... +100
//impacts the transitional process quality;
input Applied_price_ IPC=PRICE_CLOSE; // Price constant
/* used for calculation of the indicator (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;                    // Horizontal shift of the indicator in bars

//---- indicator buffers
double JMomentum[];
double UpBuffer[];
double DnBuffer[];
double FlBuffer[];

int start;
//+X================================================================X+
// iPriceSeries function description                                 |
// iPriceSeriesAlert function description                            |
// CMomentum class description                                       |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+   
//| JMomentum indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- 
   start=SLength+31;
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,JMomentum,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,SLength);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JMomentum");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//---- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Up Signal");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- selecting a symbol for drawing
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,DnBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
//---- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Dn Signal");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- selecting a symbol for drawing
   PlotIndexSetInteger(2,PLOT_ARROW,159);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,FlBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start);
//---- create a label to display in DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"No Signal");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- selecting a symbol for drawing
   PlotIndexSetInteger(3,PLOT_ARROW,159);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JMomentum( Length = ",SLength,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- declaration of the CMomentum class variable from the SmoothAlgorithms.mqh file
   CMomentum Mom;
//---- declaration of the CJJMA class variable from the SmoothAlgorithms.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   Mom.MALengthCheck("Length",SLength);
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("JLength",JLength);
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMAPhaseCheck("JPhase",JPhase);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| JMomentum iteration function                                     | 
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
   if(rates_total<start) return(0);

//---- Declaration of variables with a floating point  
   double price,momentum,jmomentum,dmomentum;
//---- Declaration of integer variables and getting calculated bars
   int first,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated==0)        // checking for the first start of the indicator calculation
      first=0;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of the CMomentum and CJJMA classes variables from the SmoothAlgorithms.mqh file
   static CMomentum Mom;
   static CJJMA JMA;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get incrementation of the input price dprice_
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- two calls of the MomentumSeries function.  
      momentum=Mom.MomentumSeries(0,prev_calculated,rates_total,SLength,price,bar,false);

      //---- one call of the JJMASeries function. 
      //---- Phase and Length parameters are not changed at every bar (Din = 0) 
      jmomentum=JMA.JJMASeries(SLength+1,prev_calculated,rates_total,0,JPhase,JLength,momentum,bar,false);

      //---- loading the obtained value in the indicator buffer
      JMomentum[bar]=jmomentum/_Point;

      //---- initialization of cells of the indicator buffers with zeros
      UpBuffer[bar] = EMPTY_VALUE;
      DnBuffer[bar] = EMPTY_VALUE;
      FlBuffer[bar] = EMPTY_VALUE;

      if(bar<start) continue;
      //---- initialization of cells of the indicator buffers with obtained values 
      dmomentum=NormalizeDouble(JMomentum[bar]-JMomentum[bar-1],0);
      if(dmomentum>0) UpBuffer[bar] = JMomentum[bar]; //there is an ascending trend
      if(dmomentum<0) DnBuffer[bar] = JMomentum[bar]; //there is a descending trend
      if(dmomentum==0) FlBuffer[bar]= JMomentum[bar]; //no trend
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
