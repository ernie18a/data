//+------------------------------------------------------------------+
//|                                                StepChoppy_v2.mq5 |
//|                                  Copyright © 2007, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property description ""
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing   |
//+-----------------------------------+
//---- drawing the indicator as a sequence of bars
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- the following colors are used as the indicator colors
#property indicator_color1  clrCrimson,clrTomato,clrOrange,clrYellow,clrAqua,clrLightBlue,clrDodgerBlue,clrMediumBlue
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying of the the indicator bar
#property indicator_label1  "StepChoppy_v2"
//+-----------------------------------+
//| Indicator window parameters                    |
//+-----------------------------------+
#property indicator_maximum  1.00
#property indicator_minimum  0.00
//+-----------------------------------+
//|  Declaration of constants              |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Declaration of enumerations          |
//+-----------------------------------+
enum MA_MODE //Type of constant
  {
   SMA,     //SMA
   LWMA     //LWMA
  };
//+-----------------------------------+
//|  Declaration of enumerations          |
//+-----------------------------------+
enum PRICE_MODE //Type of constant
  {
   HighLow,     //High/Low
   CloseClose   //Close/Close
  };
//+----------------------------------------------+
//| Input parameters of the StepMA_Line indicator     |
//+----------------------------------------------+
input int        Length      = 10;             // Volty Length
input double     Kv          = 1.0;            // Sensivity Factor
input int        StepSize    = 0;              // Constant Step Size (if need)
input MA_MODE    MA_Mode     = SMA;            // Volty MA Mode : SMA, LWMA 
input int        Advance     = 0;              // Offset
input double     Percentage  = 0;              // Percentage of Up/Down Moving   
input PRICE_MODE Switch      = HighLow;        // High/Low Mode Switch (more sensitive)   
//+----------------------------------------------+
//| Input parameters of the StepRSI_v5.2 indicator    |
//+----------------------------------------------+
input double     StepSizeFast=5;
input double     StepSizeSlow=15;
input uint       MAPeriod=1;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
input bool       Mode=true;
//+----------------------------------------------+
input int        Shift=0;                      //horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtBuffer[];
double ColorExtBuffer[];
//---- Declaration of integer variables for indicators handles
int StMA_Handle,SStRSI_Handle,FStRSI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   int min_rates_1=int(Length+1);
   int min_rates_2=int(Length+MAPeriod)+1;
   min_rates_total=MathMax(min_rates_1,min_rates_2)+1;

//---- getting handle of the StepMA_Line indicator
   StMA_Handle=iCustom(Symbol(),PERIOD_CURRENT,"StepMA_Line",Length,Kv,StepSize,MA_Mode,Advance,Percentage,Switch);
   if(StMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of StepMA_Line");
      return(INIT_FAILED);
     }

//---- getting the handle of StepRSI_v5.2
   FStRSI_Handle=iCustom(Symbol(),PERIOD_CURRENT,"StepRSI_v52",Length,StepSizeFast,MAPeriod,MAType,MAPrice,Mode);
   if(FStRSI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of StepRSI_v5.2");
      return(INIT_FAILED);
     }

//---- getting the handle of StepRSI_v5.2
   SStRSI_Handle=iCustom(Symbol(),PERIOD_CURRENT,"StepRSI_v52",Length,StepSizeSlow,MAPeriod,MAType,MAPrice,Mode);
   if(SStRSI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of StepRSI_v5.2");
      return(INIT_FAILED);
     }

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer,true);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorExtBuffer,true);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"StepChoppy_v2");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(StMA_Handle)<rates_total
      || BarsCalculated(SStRSI_Handle)<rates_total
      || BarsCalculated(FStRSI_Handle)<rates_total) return(RESET);

//---- declaration of integer variables
   int limit,clr,to_copy,Trend;
//---- declaration of variables with a floating point
   double iStMA[],iStRSI[],iFStRSI[],iSStRSI[];
   double RSI,FastRSI,SlowRSI;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(iStMA,true);
   ArraySetAsSeries(iStRSI,true);
   ArraySetAsSeries(iFStRSI,true);
   ArraySetAsSeries(iSStRSI,true);

   to_copy=limit+1;
//---- copy newly appeared data into the arrays  
   if(CopyBuffer(FStRSI_Handle,MAIN_LINE,0,to_copy,iStRSI)<=0) return(RESET);
   if(CopyBuffer(FStRSI_Handle,SIGNAL_LINE,0,to_copy,iFStRSI)<=0) return(RESET);
   if(CopyBuffer(SStRSI_Handle,SIGNAL_LINE,0,to_copy,iSStRSI)<=0) return(RESET);
   to_copy++;
   if(CopyBuffer(StMA_Handle,SIGNAL_LINE,0,to_copy,iStMA)<=0) return(RESET);

//---- The main loop of the indicator calculation
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtBuffer[bar]=1.0;
      clr=0;
      if(iStMA[bar]==1) Trend=+1;
      else if(iStMA[bar]==2) Trend=-1;
      else Trend=0;
      RSI=iStRSI[bar];
      SlowRSI=iSStRSI[bar];
      FastRSI=iFStRSI[bar];

      if(FastRSI>SlowRSI && RSI>FastRSI && Trend>0) clr=7;
      else if(FastRSI>SlowRSI && RSI<FastRSI && Trend>0) clr=6;
      else if(FastRSI<SlowRSI && RSI>FastRSI && Trend>0) clr=5;
      else if(FastRSI<SlowRSI && RSI<FastRSI && Trend>0) clr=4;
      else if(FastRSI<SlowRSI && RSI<FastRSI && Trend<0) clr=0;
      else if(FastRSI<SlowRSI && RSI>FastRSI && Trend<0) clr=1;
      else if(FastRSI>SlowRSI && RSI<FastRSI && Trend<0) clr=2;
      else if(FastRSI>SlowRSI && RSI>FastRSI && Trend<0) clr=3;

      ColorExtBuffer[bar]=clr;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
