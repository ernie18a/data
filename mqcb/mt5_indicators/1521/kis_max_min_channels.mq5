//+------------------------------------------------------------------+
//|                                         KiS_max_min_Channels.mq5 |
//|                                           Copyright © 2007, KCBT |
//|                             http://www.kcbt.ru/forum/index.php?/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, KCBT"
#property link      "http://www.kcbt.ru/forum/index.php?/"
#property description "KiS_max_min_Channels"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 3 
//---- only three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- Purple color is used as the color of the indicator line
#property indicator_color1 clrPurple
//---- indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "KiS_max_min_Channels Middle"

//+--------------------------------------------------+
//|  Envelope levels indicator drawing parameters |
//+--------------------------------------------------+
//---- drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selection of levels colors
#property indicator_color2  clrBlue
#property indicator_color3  clrDarkOrange
//---- уровни - сплошные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- levels width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//---- display levels labels
#property indicator_label2  "KiS_max_min_Channels Upper"
#property indicator_label3  "KiS_max_min_Channels Lower"

//+-----------------------------------+
//|  Declaration of constants              |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double ExtLineBuffer0[];

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[];

//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| KiS_max_min_Channels indicator initialization function           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=100;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(ExtLineBuffer0,true);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- set the position, from which the levels drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"KiS_max_min_Channels");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| KiS_max_min_Channels deinitialization function                   |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
  }
//+------------------------------------------------------------------+ 
//| KiS_max_min_Channels iteration function                          | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of variables with a floating point  
   double D1High[1],D1Low[1],D1Close[1],D1Open[1];
//---- time variables declaration
   datetime D1Time[1];
//---- Declaration of integer variables
   int limit,bar;
   static uint LastCountBar;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 
   
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- copy newly appeared data into the arrays
      if(CopyTime(Symbol(),PERIOD_D1,time[bar],1,D1Time)<=0) return(RESET);
      if(CopyHigh(Symbol(),PERIOD_D1,time[bar],1,D1High)<=0) return(RESET);
      if(CopyLow(Symbol(),PERIOD_D1,time[bar],1,D1Low)<=0) return(RESET);
      ExtLineBuffer1[bar]=D1High[0];
      ExtLineBuffer0[bar]=(D1High[0]+D1Low[0])/2;
      ExtLineBuffer2[bar]=D1Low[0];    
      if(time[bar]>=D1Time[0] && time[bar+1]<D1Time[0]) LastCountBar=bar;
     }

//---- copy newly appeared data into the arrays
   if(CopyOpen(Symbol(),PERIOD_D1,time[0],1,D1Open)<=0) return(RESET);

   Comment("Daily high:",D1High[0]," Daily low:",D1Low[0],"\n","Channel middle:",ExtLineBuffer0[0]," Ширина канала:",
           (D1High[0]+D1Low[0])/_Point,"\n","From the channel middle to Open:",MathRound(MathAbs(ExtLineBuffer0[0]-D1Open[0])/_Point),
           "\n","From the channel middle to Close:",MathRound(MathAbs(ExtLineBuffer0[0]-close[0])/_Point));
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
