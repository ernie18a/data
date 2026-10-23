//+------------------------------------------------------------------+
//|                                         Chande_Kroll_Stop_v1.mq5 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property description ""
//---- Indicator version
#property version   "1.00"
//---- Drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers is 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  StepRSI indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//--- two colors are used for the indicator colors
#property indicator_color1  clrDeepSkyBlue,clrGray
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "Chande_Kroll_Stop_v1"
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
input int    Shift=0;      // Horizontal shift of the indicator in bars 
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double UpTrend[];
double DnTrend[];
//--- declaration of integer variables for the indicators handles
int ATR_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double smin[],smax[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by reference
                          int Size)
  {
//---
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
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+    
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(ATRPeriod+Length);

//---- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }

//---- memory distribution for variables' arrays  
   ArrayResize(Count,Length);
   ArrayResize(smin,Length);
   ArrayResize(smax,Length);
   ArrayInitialize(smin,-999999);
   ArrayInitialize(smax,+999999);
   ArraySetAsSeries(smin,true);
   ArraySetAsSeries(smax,true);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpTrend,INDICATOR_DATA);
//---- Indexing buffer elements as timeseries   
   ArraySetAsSeries(UpTrend,true);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnTrend,INDICATOR_DATA);
//---- Indexing buffer elements as timeseries   
   ArraySetAsSeries(DnTrend,true);

//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Chande_Kroll_Stop_v1(",Length,", ",ATRPeriod,", ",Kv,", ",Shift,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
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
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//--- declarations of local variables 
   int limit,to_copy,bar;
   double ATR[];

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);

//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-1-int(ATRPeriod); // starting index for calculating all bars
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars

   to_copy=limit+1;

//--- copy newly appeared data in the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      smin[Count[0]]=high[ArrayMaximum(high,bar,ATRPeriod)]-Kv*ATR[bar];
      smax[Count[0]]=low[ArrayMinimum(low,bar,ATRPeriod)]+Kv*ATR[bar];

      UpTrend[bar]=smin[ArrayMaximum(smin,0,WHOLE_ARRAY)];
      DnTrend[bar]=smax[ArrayMinimum(smax,0,WHOLE_ARRAY)];

      if(bar) Recount_ArrayZeroPos(Count,Length);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
