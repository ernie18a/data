//+------------------------------------------------------------------+
//|                                                   i-BB-Width.mq5 | 
//|                         Copyright © 2007, Kim Igor V. aka KimIV. | 
//|                                             http://www.kimiv.ru/ | 
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, Kim Igor V. aka KimIV."
#property link "http://www.kimiv.ru/"
#property description "The width of the Bollinger Bands"
//---- indicator version number
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
//---- blue color is used for the indicator line
#property indicator_color1 Blue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "i-BB-Width"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input uint bands_period=20; //smoothing depth                    
input double deviation=2.0; //deviation
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE; //type of price or handle
input int Shift=0; //horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double IndBuffer[];

//---- declaration of integer variables for the indicators handles
int BB_Handle;
//---- declaration of the integer variables for the start of data calculation
uint min_rates_total;
//+------------------------------------------------------------------+   
//| i-BB-Width indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=bands_period;

//---- getting handle of the iBearsPower indicator
   BB_Handle=iBands(NULL,0,int(bands_period),0,deviation,applied_price);
   if(BB_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iBands indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"i-BB-Width(",
                     bands_period,", ",deviation,", ",EnumToString(applied_price),", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| i-BB-Width iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
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
   if(BarsCalculated(BB_Handle)<rates_total || rates_total<int(min_rates_total)) return(RESET);

//---- declaration of variables with a floating point  
   double UpBB[],DnBB[];
//---- Declaration of integer variables and getting already calculated bars
   int limit,bar,to_copy;

//--- calculations of the necessary amount of data to be copied and
//the "limit" starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=int(rates_total-min_rates_total-1); // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
   to_copy=limit+1;

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(DnBB,true);

//---- copy newly appeared data into the arrays  
   if(CopyBuffer(BB_Handle,UPPER_BAND,0,to_copy,UpBB)<=0) return(RESET);
   if(CopyBuffer(BB_Handle,LOWER_BAND,0,to_copy,DnBB)<=0) return(RESET);

//---- Main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=(UpBB[bar]-DnBB[bar])/_Point;
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
