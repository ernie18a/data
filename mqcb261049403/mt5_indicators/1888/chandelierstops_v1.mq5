//+------------------------------------------------------------------+
//|                                           ChandelierStops_v1.mq5 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property description ""
//---- Indicator version number
#property version   "1.00"
//---- Drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- four plots are used
#property indicator_plots   4
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
//---- lime color is used for the indicator
#property indicator_color1 clrLime
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying the signal line label
#property indicator_label1  "ChandelierStops Up"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- Magenta color is used for the indicator
#property indicator_color2 clrMagenta
//---- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width2 2
//---- displaying the signal line label
#property indicator_label2  "ChandelierStops Down"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- medium turquoise color is used as the color of the bullish line of the indicator
#property indicator_color3  clrMediumTurquoise
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- the width of the indicator 3 line is 4
#property indicator_width3  4
//---- bullish indicator label display
#property indicator_label3  "Buy ChandelierStops signal"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- DeepPink color is used for the indicator bearish line
#property indicator_color4  clrDeepPink
//---- the indicator 2 line is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- the width of the indicator 4 line is equal to 4
#property indicator_width4  4
//---- bearish indicator label display
#property indicator_label4  "Sell ChandelierStops signal"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint   Length=20;
input uint   ATRPeriod=10;
input double Kv=3;
input int    Shift=0; //horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double TrendUp[],TrendDown[],SignUp[],SignDown[];
//---- Declaration of integer variables for indicators handles
int ATR_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double smin[],smax[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by reference
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+    
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(ATRPeriod+Length);

//---- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }

//---- memory allocation for arrays of variables  
   ArrayResize(Count,Length);
   ArrayResize(smin,Length);
   ArrayResize(smax,Length);
   ArrayInitialize(smin,-999999);
   ArrayInitialize(smax,+999999);
   ArraySetAsSeries(smin,true);
   ArraySetAsSeries(smax,true);

//---- set ExtBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,TrendUp,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(TrendUp,true);

//---- set ExtBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,TrendDown,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(TrendDown,true);

//---- set SignUp [] dynamic array as an indicator buffer
   SetIndexBuffer(2,SignUp,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(SignUp,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,108);

//---- set SignDown[] dynamic array as an indicator buffer
   SetIndexBuffer(3,SignDown,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(SignDown,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,108);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ChandelierStops_v1(",Length,", ",ATRPeriod,", ",Kv,", ",Shift,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar;
   double trend0,ATR[];
   static double trend1;

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ATR,true);

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-1-int(ATRPeriod); // starting index for calculating all bars
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- The main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int bar0=Count[0];
      int bar1=Count[1];
      smin[Count[0]]=high[ArrayMaximum(high,bar,ATRPeriod)]-Kv*ATR[bar];
      smax[Count[0]]=low[ArrayMinimum(low,bar,ATRPeriod)]+Kv*ATR[bar];
      trend0=trend1;

      if(close[bar]>smax[Count[1]]) trend0=+1;
      if(close[bar]<smin[Count[1]]) trend0=-1;

      if(trend0>0)
        {
         if(smin[bar0]<smin[bar1]) smin[bar0]=smin[bar1];
         TrendUp[bar]=smin[bar0];
         TrendDown[bar]=0.0;
        }
      if(trend0<0)
        {
         if(smax[bar0]>smax[bar1]) smax[bar0]=smax[bar1];
         TrendUp[bar]=0.0;
         TrendDown[bar]=smax[bar0];
        }

      if(bar)
        {
         Recount_ArrayZeroPos(Count,Length);
         trend1=trend0;
        }

      SignUp[bar]=0.0;
      SignDown[bar]=0.0;

      if(TrendDown[bar+1] &&  TrendUp[bar]) SignUp[bar]=TrendUp[bar];
      if(TrendUp[bar+1]&& TrendDown[bar]) SignDown[bar]=TrendDown[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
