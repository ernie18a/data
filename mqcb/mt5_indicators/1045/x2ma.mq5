//+------------------------------------------------------------------+
//|                                                         X2MA.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| The indicator requires SmoothAlgorithms.mqh, it must             |
//|  be placed to the directory: MetaTrader\\MQL5\Include            |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers
#property indicator_buffers 1 
//--- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- blue-violet color is used as the indicator line color
#property indicator_color1 BlueViolet
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "X2MA"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//| declaration of enumerations       |
//+-----------------------------------+
enum Applied_price_      //Type of constant
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
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA;   // First smoothing averaging method 
input int Length1=12;                      // First smoothing depth                    
input int Phase1=15;                       // First smoothing parameter
//--- Phase1: for JJMA, it varies within the range -100 ... +100 and influences the quality of the transient process;
//--- Phase1: for VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method MA_Method2=MODE_JJMA;  // Second smoothing averaging method 
input int Length2 = 5;                     // Second smoothing depth 
input int Phase2=15;                       // Second smoothing parameter
//--- Phase2: for JJMA, it varies within the range -100 ... +100 and influences the quality of the transient process;
//--- Phase2: for VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;      // Price constant
input int Shift=0;                         // Horizontal shift of the indicator in bars
input int PriceShift=0;                    // Vertical shift of the indicator in points
//+-----------------------------------+
//--- declaration of a dynamic array that further will be used as an indicator buffer
double X2MA[];
//--- declaration of the variable value of the vertical shift of the moving average
double dPriceShift;
//--- declaration of integer variables of data starting point
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+   
//| X2MA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of data starting point
   StartBars1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   StartBars2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=StartBars1+StartBars2;
//--- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//--- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- setting dynamic array as indicator buffer
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- creating a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"X2MA");
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- initialization of a variable for a short name of the indicator
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- end of initialization
  }
//+------------------------------------------------------------------+ 
//| X2MA iteration function                                          | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<StartBars) return(0);
//--- declaration of variables with a floating point  
   double price_,x1xma,x2xma;
//--- declaration of integer variables and getting the bars already calculated
   int first,bar;
//--- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars
//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //--- two calls of the XMASeries function. 
      //--- in the second call, the begin parameter is increased by StartBars1 as this is a repeated XMA smoothing  
      x1xma = XMA1.XMASeries( 0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(StartBars1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      //---       
      X2MA[bar]=x2xma+dPriceShift;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
