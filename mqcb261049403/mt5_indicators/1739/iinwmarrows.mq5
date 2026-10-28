//+------------------------------------------------------------------+
//|                                                  IINWMARROWS.mq5 |
//|                                 Copyright © 2007, Iin Zulkarnain | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Iin Zulkarnainn"
#property link ""
#property description ""
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in the main window
#property indicator_chart_window 
//---- Two buffers used for the indicator calculation and drawing
#property indicator_buffers 2
//---- Two graphical constructions used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters for the bearish indicator        |
//+----------------------------------------------+
//---- Indicator 1 is drawn as a character
#property indicator_type1   DRAW_ARROW
//---- Pink is used for the color of the bearish line of the indicator
#property indicator_color1  clrMagenta
//---- Line width o indicator 1 is 4
#property indicator_width1  4
//---- Bullish label of the indicator
#property indicator_label1  "IINWMARROWS Sell"
//+----------------------------------------------+
//|  Parameters for drawing the bullish indicator      |
//+----------------------------------------------+
//---- Indicator 2 is drawn as a character
#property indicator_type2   DRAW_ARROW
//---- Blue is used for the color of the bullish line of the indicator
#property indicator_color2  clrBlue
//---- Line width of indicator 2 is 4
#property indicator_width2  4
//---- Bearish label of the indicator
#property indicator_label2 "IINWMARROWS Buy"

//+----------------------------------------------+
//|  Declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // A constant for returning an indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint              FastMAPeriod=13;
input  ENUM_MA_METHOD   FastMAType=MODE_EMA;
input uint              SlowMAPeriod=13;
input  ENUM_MA_METHOD   SlowMAType=MODE_EMA;
//+----------------------------------------------+

//---- Declaring dynamic arrays that will further 
// be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---- Declaring integer variables of the start of data calculation
int min_rates_total,AtrPeriod;
//---- Declaring integer variables for the indicator handles
int FsMA_Handle,SlMA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of global variables
   AtrPeriod=10;
   min_rates_total=int(MathMax(MathMax(FastMAPeriod,SlowMAPeriod)+3,AtrPeriod));

//---- Getting the handle of the iMA indicator
   FsMA_Handle=iMA(NULL,0,FastMAPeriod,0,FastMAType,PRICE_CLOSE);
   if(FsMA_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iMA indicator");
//---- Getting the handle of he iMA indicator
   SlMA_Handle=iMA(NULL,0,SlowMAPeriod,0,SlowMAType,PRICE_OPEN);
   if(SlMA_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iMA indicatoк ");

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

/ / ---- Setting the recording fidelity of the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- A name for the data window and a label for sub-windows 
   string short_name="IINWMARROWS";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double GetRange(int index,const double &High[],const double &Low[],uint Len)
  {
//----
   double AvgRange=0.0;
   for(int count=int(index+Len-1); count>=index; count--) AvgRange+=MathAbs(High[count]-Low[count]);
//---- 
   return(AvgRange/Len);
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
//---- Checking the number of bars to be enough for the calculation
   if(BarsCalculated(FsMA_Handle)<rates_total
      || BarsCalculated(SlMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int limit,bar,to_copy;
   double FsMA[],SlMA[];
   double fasterMAnow,slowerMAnow,fasterMAprevious;
   double slowerMAprevious,fasterMAafter,slowerMAafter;

//---- Calculation of the required amount of copied data
//and the limit starting index for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars

//---- Indexing elements in arrays as time series  
   ArraySetAsSeries(FsMA,true);
   ArraySetAsSeries(SlMA,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   to_copy=limit+3;
//---- Copy the newly appeared data into the arrays
   if(CopyBuffer(FsMA_Handle,0,0,to_copy,FsMA)<=0) return(RESET);
   if(CopyBuffer(SlMA_Handle,0,0,to_copy,SlMA)<=0) return(RESET);
   
   SellBuffer[0]=0.0;
   BuyBuffer[0]=0.0;

//---- The main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;

      fasterMAnow=FsMA[bar+1];
      fasterMAprevious=FsMA[bar+2];
      fasterMAafter=FsMA[bar];
      //----
      slowerMAnow=SlMA[bar+1];
      slowerMAprevious=SlMA[bar+2];
      slowerMAafter=SlMA[bar];

      if(fasterMAnow>slowerMAnow && fasterMAprevious<slowerMAprevious && fasterMAafter>slowerMAafter)
        {
         BuyBuffer[bar]=low[bar]-GetRange(bar,high,low,AtrPeriod)*0.5;
        }

      if(fasterMAnow<slowerMAnow && fasterMAprevious>slowerMAprevious && fasterMAafter<slowerMAafter)
        {
         SellBuffer[bar]=high[bar]+GetRange(bar,high,low,AtrPeriod)*0.5;
        }

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
