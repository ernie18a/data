//+------------------------------------------------------------------+
//|                                         X2MATransformCandles.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the directory: terminal_data_folder\MQL5\Include              |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "X2MA Transform Candles"
//---- indicator version
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- 6 buffers are used for calculation and drawing the indicator
#property indicator_buffers 6
//--- 2 plots are used
#property indicator_plots   2
//--- color candlesticks are used as an indicator
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  DodgerBlue, Red
//--- displaying the indicator label
#property indicator_label2  "X2MATransformCandles Open;X2MATransformCandles High;X2MATransformCandles Low;X2MATransformCandles Close"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA;    // First smoothing averaging method 
input int Length1=12;                       // First smoothing depth                    
input int Phase1=15;                        // First smoothing parameter
input Smooth_Method MA_Method2=MODE_JJMA;   // Second smoothing averaging method 
input int Length2= 5;                       // Second smoothing depth 
input int Phase2=15;                        // Second smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;       // Applied price
input int Shift=0;                          // Horizontal shift of the indicator in bars
input int PriceShift=0;                     // Vertical shift of the indicator in points
input color BidColor=Red;                   // Bid line color
input ENUM_LINE_STYLE BidStyle=STYLE_SOLID; // Bid line style
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//--- declaration of the integer variables for the start of data calculation
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   StartBars1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   StartBars2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=StartBars1+StartBars2;
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtCloseBuffer,INDICATOR_DATA);
   
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//--- set ExtColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(5,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);

//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA Transform Candles(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- Bid line drawing parameters   
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,BidColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,BidStyle);
//---   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//--- declaration of variables with a floating point  
   double price_,x1xma,x2xma;
//--- declaration of integer variables and getting already calculated bars
   int first,bar;

//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //--- two calls of the XMASeries function. 
      //--- the 'begin' parameter is increased by StartBars1 in the second call, as it is another XMA smoothing  
      x1xma = XMA1.XMASeries(0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(StartBars1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      //--- 
      if(bar>StartBars)
        {
         ExtOpenBuffer [bar]=open[bar]-x2xma;
         ExtCloseBuffer[bar]=close[bar]-x2xma;
         ExtHighBuffer [bar]=high[bar]-x2xma;
         ExtLowBuffer  [bar]=low[bar]-x2xma;
         ExtBuffer[bar]=ExtCloseBuffer[bar];
        }
      else
        {
         ExtOpenBuffer [bar]=EMPTY_VALUE;
         ExtCloseBuffer[bar]=EMPTY_VALUE;
         ExtHighBuffer [bar]=EMPTY_VALUE;
         ExtLowBuffer  [bar]=EMPTY_VALUE;
         ExtBuffer[bar]=EMPTY_VALUE;
         continue;
        }

      //--- candlesticks coloring
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else                                       ExtColorBuffer[bar]=1.0;
     }

//--- Bid line shift parameters     
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtCloseBuffer[rates_total-1]);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
