//+------------------------------------------------------------------+
//|                                         FX5_SelfAdjustingRSI.mq5 | 
//|                                            Copyright © 2008, FX5 | 
//|                                                    hazem@uk2.net | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, FX5"
#property link "hazem@uk2.net"
#property description ""
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in a separate window
#property indicator_separate_window
//---- Number of indicator buffers is 4
#property indicator_buffers 4 
//---- Three graphical constructions used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- Indicator drawn as a line
#property indicator_type1   DRAW_LINE
//---- DodgerBlue is used for the indicator line color
#property indicator_color1 clrDodgerBlue
//---- Indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//---- The width of the indicator line is 2
#property indicator_width1  2
//---- Indicator label
#property indicator_label1  "RSI"

//+--------------------------------------------+
//|  Parameters for drawing BB levels indicator|
//+--------------------------------------------+
//---- Drawing Bollinger Bands as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- Selecting ccolors for Bollinger Bands
#property indicator_color2  clrMediumSeaGreen
#property indicator_color3  clrMagenta
//---- Bollinger Bands are solid lines
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- Width o Bollinger Bands is 2
#property indicator_width2  2
#property indicator_width3  2
//---- Show labels o Bollinger Bands
#property indicator_label2  "OverBought"
#property indicator_label3  "OverSold"
//+----------------------------------------------+
//| Parameters for drawing horizontal levels     |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 50.0
#property indicator_level3 20.0
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // A constant that returns indicator recalculation command to the terminal

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Length=12; // RSI period  
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE; // RSI timeseries price                
input double BandsDeviation=2.0; // Deviation
input bool MA_Method=true; // Use smoothing for BB
input int Shift=0; // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double ExtLineBuffer[],ExtLineBuffer1[],ExtLineBuffer2[],ExtCalcBuffer[];

//---- Declaring integer variables of the start of data calculation
int min_rates_total,min_rates_;
//---- Declaring integer variables for the indicator handles
int RSI_Handle,STD_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=int(Length);
   min_rates_total=int(min_rates_+2*Length);

//---- Getting the handle of the iRSI indicator
   RSI_Handle=iRSI(NULL,PERIOD_CURRENT,Length,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iRSI indicator");

//---- Getting the handle of the iStdDev indicator
   if(!MA_Method)
     {
      STD_Handle=iStdDev(NULL,PERIOD_CURRENT,Length,0,MODE_SMA,RSI_Handle);
      if(STD_Handle==INVALID_HANDLE)Print(" Failed to get the handle of the iStdDev indicator");
     }

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- Shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- Shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//---- Setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- Set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- Drawing of empty values is forbidden
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtCalcBuffer,INDICATOR_CALCULATIONS);

//---- Initializations of variable for indicator short name;
   string shortname;
   StringConcatenate(shortname,"FX5_SelfAdjustingRSI(",Length,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- End of initialization
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
//---- Checking if the number of bars is enough for the calculation
   if(BarsCalculated(RSI_Handle)<rates_total
      || !MA_Method && BarsCalculated(STD_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double STD[];

//---- Calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_-1; // Starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(RSI_Handle,0,0,to_copy,ExtLineBuffer)<=0) return(RESET);
   if(!MA_Method)if(CopyBuffer(STD_Handle,0,0,to_copy,STD)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(STD,true);

//---- Main calculation loop of the indicator
   if(MA_Method==true)
     {
      for(bar=limit; bar>=0 && !IsStopped(); bar--)
        {
         double smoothedRSI=GetSmoothedRSI(bar);
         ExtCalcBuffer[bar]=MathAbs(ExtLineBuffer[bar]-smoothedRSI);
         double kDiviation=BandsDeviation*GetAbsDiviationAverage(bar);
         ExtLineBuffer1[bar]=50+kDiviation;
         ExtLineBuffer2[bar]=50-kDiviation;
        }
     }
   else
     {
      for(bar=limit; bar>=0 && !IsStopped(); bar--)
        {
         double kDiviation=BandsDeviation*STD[bar];
         ExtLineBuffer1[bar]=50+kDiviation;
         ExtLineBuffer2[bar]=50-kDiviation;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSmoothedRSI(int shift)
  {
//----
   double sum=0;
   for(int iii=int(shift+Length-1); iii>=shift; iii--) sum+=ExtLineBuffer[iii];
//----
   return(sum/Length);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAbsDiviationAverage(int shift)
  {
//----
   double sum=0;
   for(int iii=int(shift+Length-1); iii>=shift; iii--) sum+=ExtCalcBuffer[iii];
//----
   return(sum/Length);
  }
//+------------------------------------------------------------------+
