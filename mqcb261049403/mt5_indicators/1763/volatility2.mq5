//+------------------------------------------------------------------+ 
//|                                                  Volatility2.mq5 | 
//|                                       Copyright © 2007, Eva Ruft | 
//|                                               briz18@rambler.ru/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, Eva Ruft"
#property link      "briz18@rambler.ru"
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- MediumVioletRed color is used as the color of a bullish candlestick
#property indicator_color1 clrMediumVioletRed
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Volatility2"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input  ENUM_MA_METHOD   MAType=MODE_EMA;     // Smoothing type
input uint              VolatilityPeriod=5;  // Indicator period
input int               Shift=0;             // Horizontal shift of the indicator in bars

input uint              LevelsTotal=20;      // Number of levels
input uint              StartLevel=100;      // Initial level
input uint              LevelsStep=100;      // Distance between levels
input color             LevelsColor=clrBlue; // Color of the levels
//+-----------------------------------+
//---- indicator buffer
double IndBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int HMA_Handle,LMA_Handle;
//+------------------------------------------------------------------+    
//| Volatility indicator initialization function                     | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(VolatilityPeriod);

//---- Getting the handle of the iMA indicator
   HMA_Handle=iMA(NULL,0,VolatilityPeriod,0,MAType,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iMA indicator");

//---- Getting the handle of the iMA indicator
   LMA_Handle=iMA(NULL,0,VolatilityPeriod,0,MAType,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iMA indicator");

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- Initializations of variable for indicator short name
   string shortname="Volatility("+string(VolatilityPeriod)+")";
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- The number of horizontal levels of the LevelsTotal indicator   
   IndicatorSetInteger(INDICATOR_LEVELS,LevelsTotal);
   for(int numb=0; numb<int(LevelsTotal); numb++)
     {
      int level=int(StartLevel+LevelsStep*numb);
      //---- Values of the indicator horizontal levels   
      IndicatorSetDouble(INDICATOR_LEVELVALUE,numb,level);
      //---- gray and magenta colors are used for horizontal levels lines  
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,numb,LevelsColor);
      //---- Short dot-dash is used for the horizontal level line  
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,numb,STYLE_DASHDOTDOT);
     }
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Volatility iteration function                                    | 
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
   if(BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double HMA[],LMA[];

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only

   to_copy=limit+1;

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);

//---- copy newly appeared data into the arrays
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=(HMA[bar]-LMA[bar])/_Point;
//----        
   return(rates_total);
  }
//+------------------------------------------------------------------+
