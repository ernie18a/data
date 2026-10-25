//+---------------------------------------------------------------------+
//|                                                    CandleVisual.mq5 |
//|                                        Copyright © 2010,   InVest0r | 
//|                                                                     | 
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010,   InVest0r"
#property link ""
#property description "Copyright © 2010,   InVest0r"
//---- indicator version number
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- five buffers are used for calculation and drawing the indicator
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used for display
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMagenta, clrSlateBlue, clrTeal
//---- displaying the indicator label
#property indicator_label1  "Candles Open; Candles High; Candles Low; Candles Close"
//---- declaration of dynamic arrays that will further be 
//---- used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=1;

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);

//---- setting the indicator display accuracy format
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- data window name and subwindow label 
   string short_name="CandleVisual";
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
//---- checking for the sufficiency of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaring local variables 
   int first,bar;
   double HO,OL,OC,CO;

//---- calculation of the 'first' starting number for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for the calculation of all bars
     }
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      HO=high[bar]-open[bar];
      OL=low[bar]-open[bar];
      OC=open[bar]-close[bar];
      CO=close[bar]-open[bar];

      //---- four calls of the XMASeries function.
      ExtOpenBuffer [bar]=0;
      ExtCloseBuffer[bar]=CO;
      ExtHighBuffer [bar]=HO;
      ExtLowBuffer  [bar]=OL;

      //--- coloring candlesticks
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
