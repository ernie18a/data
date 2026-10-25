//+------------------------------------------------------------------+
//|                                                         r_Ma.mq5 |
//|                                         Copyright © 2006, Rosych | 
//|                                                   rosych@mail.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Rosych"
#property link "rosych@mail.ru"
#property description "Averaged MA"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- IndianRed color is used as the color of the indicator line
#property indicator_color1  clrIndianRed
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "r_Ma"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint period=5;     // MA period
input int  Shift=0;      // Horizontal shift of the MA in bars
input int PriceShift=0;  // Vertical shift of the MA in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Buffer[];
//--- declaration of the average vertical shift value variable
double dPriceShift;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int MA_Handle[4][7];  //[метод усреднения][цена-1]
//+--------------------------------------------------------------------+
//|  Arrays of objects for creating multidimensional arrays of objects |
//+--------------------------------------------------------------------+  
class CArray
  {
public: double    Array[];
  };
//+------------------------------------------------------------------+
//| Creating an array of objects                                     |
//+------------------------------------------------------------------+
CArray Arr[4][7];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables   
   min_rates_total=int(period);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- Getting indicator handles
   for(int k=0; k<4; k++)
      for(int r=0; r<7; r++)
        {
         MA_Handle[k][r]=iMA(NULL,0,period,0,ENUM_MA_METHOD(k),ENUM_APPLIED_PRICE(r+1));
         if(MA_Handle[k][r]==INVALID_HANDLE)
           {
            Print(" Failed to get the handle of iMA");
            return(INIT_FAILED);
           }
        }
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="r_Ma";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- initialization end
   return(INIT_SUCCEEDED);
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
//--- checking if the number of bars is enough for the calculation
   for(int k=0; k<4; k++) for(int r=0; r<7; r++) if(BarsCalculated(MA_Handle[k][r])<rates_total) return(RESET);
   if(rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int limit,to_copy;
//--- calculations of the necessary number of copied data and limit starting index for the  bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total;   // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars
//--- indexing elements in arrays as in timeseries 
   for(int k=0; k<4; k++) for(int r=0; r<7; r++) ArraySetAsSeries(Arr[k][r].Array,true);
//---
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   for(int k=0; k<4; k++) for(int r=0; r<7; r++) if(CopyBuffer(MA_Handle[k][r],0,0,to_copy,Arr[k][r].Array)<=0) return(RESET);
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Buffer[bar]=0.0;
      for(int k=0; k<4; k++) for(int r=0; r<7; r++) Buffer[bar]+=Arr[k][r].Array[bar];
      Buffer[bar]/=28;
      Buffer[bar]+=dPriceShift;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
