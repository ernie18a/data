//+------------------------------------------------------------------+ 
//|                                               Aggressiveness.mq5 | 
//|                   Copyright © 2009, Trofimov Evgeniy Vitalyevich | 
//|                                     http://TrofimovVBA.narod.ru/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, Trofimov Evgeniy Vitalyevich"
#property link      "http://TrofimovVBA.narod.ru/"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- BlueViolet color is used as the color of the bullish line of the indicator
#property indicator_color1 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Aggressiveness"
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint MyPeriod=22;
input double Lot=0; // Lot (0 - in points, >0 - in the deposit currency)
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffer
double IndBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| Aggressiveness indicator initialization function                 | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MyPeriod+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   if(!Lot) shortname="Aggressiveness("+string(MyPeriod)+"), (pips) = ";
   else shortname="Aggressiveness("+string(MyPeriod)+"), ("+ AccountInfoString(ACCOUNT_CURRENCY)+"·"+DoubleToString(Lot,2)+") = ";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Aggressiveness iteration function                                | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total)return(0);

//---- Declaration of integer variables
   int first,bar;
//---- declaration of variables with a floating point  
   double Sum;

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=min_rates_total; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      Sum=0;
      for(int x=0; x<int(MyPeriod); x++)
        {
         int barx=bar-x;
         if(close[barx]>open[barx]) Sum+=close[barx]-close[barx-1]; //white candle
         else Sum+=close[barx-1]-close[barx]; //black candle
        }

      IndBuffer[bar]=Sum/(_Point*MyPeriod);
      
      if(Lot)
        {
         double TICKVALUE=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
         if(!TICKVALUE) return(prev_calculated);
         IndBuffer[bar]*=TICKVALUE*Lot;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
