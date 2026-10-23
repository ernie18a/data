//+------------------------------------------------------------------+
//|                                                       WiOver.mq5 |
//|                                Copyright © 2010, Murad Ismayilov | 
//|                                                wmlab@hotmail.com | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2010, Murad Ismayilov"
//---- link to the website of the author
#property link "http://www.wmlab.org/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used for the indicator bullish line
#property indicator_color1  Blue
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used for the indicator bearish line
#property indicator_color2  Red
//---- line of the indicator 2 is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int WiOverPeriod=9; // Indicator period 
input int Shift=0;        // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double BullsBuffer[];
double BearsBuffer[];
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables    
   min_rates_total=WiOverPeriod;

//---- set BullsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"WiOver("+string(WiOverPeriod)+") "+"SellLimit");

//---- set BearsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"WiOver("+string(WiOverPeriod)+") "+"BuyLimit");

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"WiOver(",WiOverPeriod,", ",Shift,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int first,bar,k,k1;
   double sum,abs;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
        first=min_rates_total;   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      sum=0.0;
      k=bar-WiOverPeriod+1;
      while(k<=bar)
        {
         k1=k-1;
         if(high[k1]>low[k] && low[k]>low[k1]) sum+=high[k1]-low[k1]-low[k]/high[k1];
         if(low[k1]<high[k] && high[k]<high[k1]) sum+=high[k1]-low[k1]-high[k]/low[k1];
         k++;
        }

      abs=sum *(high[bar]-low[bar])/WiOverPeriod;
      BullsBuffer[bar] = low[bar] - abs;
      BearsBuffer[bar] = high[bar] + abs;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
