//+------------------------------------------------------------------+
//|                                                 Hull_Candles.mq5 |
//|                                           Copyright © 2007, None |
//|                                      Planet.Earth.Redistribution |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, None"
#property link      "Planet.Earth.Redistribution"
#property description "Hull_Candles"

//---- Indicator version number
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----five buffers are used for calculation of drawing of the indicator
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrDarkTurquoise,clrDeepPink
//---- displaying the indicator label
#property indicator_label1  "Hull Open;Hull High;Hull Low;Hull Close"

//+-----------------------------------+
//|  Description of smoothing classes |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMAO1,XMAL1,XMAH1,XMAC1;
CXMA XMAO2,XMAL2,XMAH2,XMAC2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
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
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method HMA_Method=MODE_JJMA; //Method of averaging
input uint HLength=30; //Depth of averaging                    
input int  HPhase=100; //Parameter of averaging,
                       //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//----
int min_rates_total,HLength2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=XMAO1.GetStartBars(HMA_Method,HLength,HPhase)+2;
   HLength2=int(MathFloor(HLength/2));

//---- setting alerts for invalid values of external parameters
   XMAO1.XMALengthCheck("HLength", HLength);
   XMAO1.XMAPhaseCheck("HPhase", HPhase, HMA_Method);

//---- Setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);

// ---- Setting the recording fidelity of the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Hull_Candles";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int first,bar;
   double haOpen,haHigh,haLow,haClose;
   double XmaOpen,XmaHigh,XmaLow,XmaClose;
   double XmaOpen1,XmaHigh1,XmaLow1,XmaClose1;
   double XmaOpen2,XmaHigh2,XmaLow2,XmaClose2;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=1; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars

//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      XmaOpen1  = XMAO1.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength, open [bar], bar, false);
      XmaClose1 = XMAC1.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength, close[bar], bar, false);
      XmaHigh1  = XMAH1.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength, high [bar], bar, false);
      XmaLow1   = XMAL1.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength, low  [bar], bar, false);
      //----
      XmaOpen2  = XMAO2.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength2, open [bar], bar, false);
      XmaClose2 = XMAC2.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength2, close[bar], bar, false);
      XmaHigh2  = XMAH2.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength2, high [bar], bar, false);
      XmaLow2   = XMAL2.XMASeries(1, prev_calculated, rates_total, HMA_Method, HPhase, HLength2, low  [bar], bar, false);
      //----
      XmaOpen=(2*XmaOpen2-XmaOpen1);
      XmaClose=(2*XmaClose2-XmaClose1);
      XmaHigh=(2*XmaHigh2-XmaHigh1);
      XmaLow=(2*XmaLow2-XmaLow1);

      haHigh=MathMax(XmaHigh,MathMax(ExtOpenBuffer[bar-1],ExtCloseBuffer[bar-1]));
      haLow=MathMin(XmaLow,MathMin(ExtOpenBuffer[bar-1],ExtCloseBuffer[bar-1]))/2;
      haClose=(XmaOpen+XmaHigh+XmaLow+XmaClose)/4;

      if(bar<=min_rates_total)
        {
         ExtOpenBuffer [bar]=XmaOpen;
         ExtCloseBuffer[bar]=XmaClose;
         ExtHighBuffer [bar]=XmaHigh;
         ExtLowBuffer  [bar]=XmaLow;

         continue;
        }

      ExtOpenBuffer [bar]=haOpen;
      ExtCloseBuffer[bar]=haClose;
      ExtHighBuffer [bar]=haHigh;
      ExtLowBuffer  [bar]=haLow;


      //--- Coloring candlesticks
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else                                       ExtColorBuffer[bar]=1.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
