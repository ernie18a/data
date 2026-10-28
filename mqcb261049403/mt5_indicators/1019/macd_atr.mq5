//+------------------------------------------------------------------+ 
//|                                                     MACD_ATR.mq5 | 
//|                                      Copyright © 2011, Svinozavr | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Svinozavr"
#property link "" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four color histogram
#property indicator_color1 Gray,Red,Lime
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "MACD"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- use blue color for the line
#property indicator_color2 Blue
//---- indicator line is a solid curve
#property indicator_style2 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2 2
//---- displaying label of the signal line
#property indicator_label2  "ATR Line"
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input uint FastEMA=12; // Fast EMA period;
input uint SlowEMA=26; // Slow EMA period;
input int ATR_=0; // ATR period, if =0, then ATR=SlowEMA
input ENUM_APPLIED_PRICE AppliedPrice=PRICE_CLOSE;//price constant
double ATRmin=0; // noise threshold ??of ATR value in pp.
double kATR=1; // Scaling factor
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//----Declaration of variables for storing the indicators handles
int ATR_Handle,MACD_Handle;
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double MACDBuffer[],ATRBuffer[],ColorMACDBuffer[];
//+------------------------------------------------------------------+    
//| MACD indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   if(ATR_) min_rates_total=int(MathMax(FastEMA,SlowEMA)+ATR_);
   else min_rates_total=2*int(MathMax(FastEMA,SlowEMA));

//---- Initializing constants
   int ATR;
   if(!ATR_) ATR=int(SlowEMA); 
   else ATR=ATR_;
   ATRmin*=_Point; // noise threshold ??of ATR value in prices

//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");

//---- getting handle of the MACD indicator
   MACD_Handle=iMACD(NULL,0,FastEMA,SlowEMA,3,AppliedPrice);
   if(MACD_Handle==INVALID_HANDLE)Print(" Failed to get handle of the MACD indicator");

//---- transformation of the dynamic array MACDBuffer into an indicator buffer
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(MACDBuffer,true);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorMACDBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ColorMACDBuffer,true);

//---- set ATRBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,ATRBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ATRBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"MACD(",FastEMA,", ",SlowEMA,", ",ATR,", ",EnumToString(AppliedPrice),")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| MACD iteration function                                          | 
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
//---- Checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total
      || BarsCalculated(ATR_Handle)<min_rates_total
      || BarsCalculated(MACD_Handle)<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double atr,Atr[];

//---- Calculate the "limit" starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Atr,true);

//---- calculation of the necessary amount of data to be copied
   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Atr)<=0) return(RESET);
   if(CopyBuffer(MACD_Handle, MAIN_LINE,0,to_copy,MACDBuffer)<=0) return(RESET);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorMACDBuffer[bar]=0;
      atr=kATR*Atr[bar]; // ATR
      atr=MathMax(atr,ATRmin); // noise threshold
      if(MACDBuffer[bar]>0) ATRBuffer[bar]=MACDBuffer[bar]-atr; // for positive MACD values
      if(MACDBuffer[bar]<0) ATRBuffer[bar]=MACDBuffer[bar]+atr; // for negative MACD values
      // extremums
      if(MACDBuffer[bar]>0 && MACDBuffer[bar+1]<MACDBuffer[bar] && ATRBuffer[bar]>=0) ColorMACDBuffer[bar]=2; // peaks
      if(MACDBuffer[bar]<0 && MACDBuffer[bar+1]>MACDBuffer[bar] && ATRBuffer[bar]<=0) ColorMACDBuffer[bar]=1; // cavitys
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
