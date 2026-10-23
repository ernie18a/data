//+------------------------------------------------------------------+
//|                                                 INERCIA_bars.mq5 |
//|                                      Copyright © 2008, NICTRADER | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, NICTRADER"
#property link "http://nyctrader.ru/"
#property description ""
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
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrRed,clrGray,clrDodgerBlue
//---- displaying the indicator label
#property indicator_label1  "INERCIA_bars Open;INERCIA_bars High;INERCIA_bars Low;INERCIA_bars Close"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint body=7; // Value of price change in points                   
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//----
double dBody;
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=1;
   dBody=body*_Point;
//---- Setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- Setting the indicator display accuracy format
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="INERCIA_bars";
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
//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0;                   // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars
//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ExtOpenBuffer[bar]=open[bar];
      ExtCloseBuffer[bar]=close[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];     
      int clr=1;
      if(close[bar]>open[bar] && close[bar]-open[bar]>dBody) clr=2;
      if(close[bar]<open[bar] && open[bar]-close[bar]>dBody) clr=0;
      ExtColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+