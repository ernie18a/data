//+------------------------------------------------------------------+
//|                                                    AMA_SLOPE.mq5 |
//|                                        Copyright © 2007, Kalenzo |
//|                                      bartlomiej.gorski@gmail.com | 
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2007, Kalenzo"
//---- A link to the author's website
#property link      "bartlomiej.gorski@gmail.combartlomiej.gorski@gmail.com"
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in a separate window
#property indicator_separate_window
//---- One buffer is used for the indicator calculation and drawing
#property indicator_buffers 1
//---- One graphical construction is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- Indicator 1 is drawn as a line
#property indicator_type1   DRAW_LINE
//---- Blue-Violet is used as the color of the indicator's bullish line
#property indicator_color1  clrBlueViolet
//---- the line of the indicator 1 is solid
#property indicator_style1  STYLE_SOLID
//---- The width of the indicator 1 line is 3
#property indicator_width1  3
//---- Bullish label of the indicator
#property indicator_label1  "AMA_SLOPE"

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint ama_period=9; // AMA period
input uint fast_ma_period=2; // Fast MA period
input uint slow_ma_period=30; // Slow MA period
input double G=2.0; // The power to raise the smoothing constant to
input int AMAShift = 0; // Horizontal shift of the indicator in bars
input double dK = 1.0;  // A  ratio for the filter
//+----------------------------------------------+
//---- Declaring dynamic arrays that will further 
// be used as indicator buffers
double AMABuffer[];
//---- Declaring floating point variables for the constants
double dSC,slowSC,fastSC;
int AMA_Handle,dAMA_Handle;
//---- Declaring integer variables of data calculation start
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of global variables
   min_rates_total=int(ama_period+1);
   
//---- Set the AMABuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,AMABuffer,INDICATOR_DATA);
//---- Shift the indicator 1 horizontally by ama_shift
   PlotIndexSetInteger(0,PLOT_SHIFT,AMAShift);
//---- Shift the beginning of indicator 1 drawing by 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Drawing of empty values is forbidden
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"AMA_SLOPE( ",ama_period,", ",fast_ma_period,", ",slow_ma_period," )");
//---- Create the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- Set the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- initialization of constants 
   slowSC = (2.0 / (slow_ma_period + 1));
   fastSC = (2.0 / (fast_ma_period + 1));
   dSC=fastSC-slowSC;
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- Checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total+begin) return(0);

//---- declaration of local variables 
   int first,bar;
   double noise,AMA,signal,ER,ERSC,SSC,price0,price1;
   static double AMA_;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=min_rates_total+begin+1; // Starting index for the calculation of all bars
      AMA_=price[first-1];
      AMA=AMA_;
      //---- Increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0)
        {
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
        }
     }
   else
     {
      first=prev_calculated-1; //Starting number for calculation of new bars
      AMA=AMA_;
     }

//---- The main cycle of calculation of the AMA indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- 
      noise=_Point/10000;
      for(int iii=0; iii<int(ama_period); iii++)
        {
         price0=price[bar-iii-0];
         price1=price[bar-iii-1];
         noise+=MathAbs(price0-price1);
        }

      price0=price[bar];
      price1=price[bar-ama_period];
      signal=MathAbs(price0-price1);
      ER=signal/noise;
      ERSC=ER*dSC;
      SSC=ERSC+slowSC;
      AMA=AMA+(MathPow(SSC,G)*(price0-AMA));
      
      //---- Initialization of a cell of the indicator buffer with the received value of AMA
      AMABuffer[bar]=(AMA-AMA_)/_Point;
      
      if(bar<rates_total-1) AMA_=AMA;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
