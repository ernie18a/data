//+------------------------------------------------------------------+
//|                                                     SuperSR6.mq5 |
//|                                       Copyright © 2006, Scorpion |
//|            Scorpion@fxfisherman.com, http://www.fxfisherman.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Scorpion"
#property link      "http://www.fxfisherman.com/"
#property description "Indicator to build the possible lines of support and resistance"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- pink color is used for support lines
#property indicator_color1  clrMagenta
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying the support line label
#property indicator_label1  "Support"
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- green color is used for resistance lines
#property indicator_color2  clrLime
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the resistance line
#property indicator_label2 "Resistance"

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint Contract_Step=150;
input uint Precision=10;
input uint Shift_Bars=1;
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---
int min_rates_total;
double contract,dPrecision;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=int(6+Shift_Bars);
   contract=(Contract_Step+Precision)*_Point;
   dPrecision=Precision*_Point;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Support");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SellBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Resistance");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BuyBuffer,true);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="SuperSR6";
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
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int shift,limit,bar;
   bool fractal;
   double price,gap;
   
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      BuyBuffer[bar]=high[limit+1];
      SellBuffer[bar]=low[limit+1];
     }
   else
     {
      limit=rates_total-prev_calculated+2; // starting index for the calculation of new bars
     }

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      shift=int(bar+Shift_Bars);

      //---- Resistance
      price=high[shift+2];
      fractal=price>=high[shift+4] && price>=high[shift+3] && price>high[shift+1] && price>high[shift];
      gap=BuyBuffer[bar+1]-price;

      if(fractal && (gap>=contract || gap<0)) BuyBuffer[bar]=price+dPrecision;
      else BuyBuffer[bar]=BuyBuffer[bar+1];

      //---- Support
      price=low[shift+2];
      fractal=price<=low[shift+4] && price<=low[shift+3] && price<low[shift+1] && price<low[shift];
      gap=price-SellBuffer[bar+1];

      if(fractal && (gap>=contract || gap<0)) SellBuffer[bar]=price-dPrecision;
      else SellBuffer[bar]=SellBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
