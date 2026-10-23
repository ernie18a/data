/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                                       Yaanna.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- 1 plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use dark orchid color for the indicator line
#property indicator_color1 DarkOrchid
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "Yaanna"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 100
#property indicator_level2 0
#property indicator_levelcolor Red
#property indicator_levelstyle STYLE_DASHDOTDOT
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
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
input int BandsPeriod=200;                 // Smoothing period
input double BandsDeviation=2.0;           // Deviation 
input ENUM_MA_METHOD MAMethod = MODE_SMA; // Smoothing method
input Applied_price_ IPC=PRICE_CLOSE;      // Price constant
/* used for calculation of the indicator (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;                         // Horizontal shift of the indicator in bars

//---- indicator buffers
double Buffer[];
//+------------------------------------------------------------------+
//| Description of smoothing classes and indicators                  |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
#include <IndicatorsAlgorithms.mqh>
//+------------------------------------------------------------------+    
//| Yaanna indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,BandsPeriod-1);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Yaanna");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Yaanna( BandsPeriod = ",BandsPeriod,
                     ", BandsDeviation = ",BandsDeviation,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Yaanna iteration function                                        | 
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
   if(rates_total<BandsPeriod) return(0);

//---- Declaration of variables with a floating point  
   double price_,Lower,Middle,Upper;
//---- Declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated==0)        // checking for the first start of the indicator calculation
      first=0;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of a variable of the CBBands class
   static CBBands BBands;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- calling the PriceSeries function to get the 'Series' input price
      price_=PriceSeries(IPC,bar,open,low,high,close);
      BBands.BBandsSeries(0,prev_calculated,rates_total,BandsPeriod,BandsDeviation,MAMethod,price_,bar,false,Lower,Middle,Upper);
      Buffer[bar]=100*(close[bar]-Lower)/((Upper-Lower));
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+