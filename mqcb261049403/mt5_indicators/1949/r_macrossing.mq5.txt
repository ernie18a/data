//+------------------------------------------------------------------+
//|                                                 r_MaCrossing.mq5 |
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
//--- two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used as the indicator colors
#property indicator_color1  clrDodgerBlue,clrHotPink
//--- displaying the indicator label
#property indicator_label1  "r_MaCrossing"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint period=5;                // MA period
input uint speriod=5;               // Signal line period 
input int  Shift=0;                 // Horizontal shift of the MA in bars
input int  PriceShift=0;            // Vertical shift of the indicator in points
input uint SignalBar=0;             // Bar number for the signal
input uint AlertCount=0;            // Number of produced alerts
input bool Push=true;               // Allow push notifications
//--- declaration of dynamic arrays that 
//--- will be used as indicator buffers
double UpBuffer[],DnBuffer[];
//--- declaration of the average vertical shift value variable
double dPriceShift;
//--- declaration of variables for the text of trading signals
string sBuySignal,sSellSignal;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int MA_Handle[4][7]; //[averaging method][price-1]
//+------------------------------------------------------------------+
//| Arrays of objects for creating multidimensional arrays of objects|
//+------------------------------------------------------------------+  
class CArray
  {
public: double    Array[];
  };
//+------------------------------------------------------------------+
//| Creating an array of objects                                     |
//+------------------------------------------------------------------+
CArray Arr[4][7];
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables   
   min_rates_total=int(period+speriod);
   sBuySignal="r_MaСrossing "+Symbol()+GetStringTimeframe(Period())+": ""Buy Signal!";
   sSellSignal="r_MaСrossing "+Symbol()+GetStringTimeframe(Period())+": ""Sell Signal!";
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
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="r_MaСrossing";
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
   static uint UpCount,DnCount,RePush;

//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-int(period)-1;     // Starting index for calculating all bars
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
      UpBuffer[bar]=0.0;
      for(int k=0; k<4; k++) for(int r=0; r<7; r++) UpBuffer[bar]+=Arr[k][r].Array[bar];
      UpBuffer[bar]/=28;

      //--- calculating the signal line by SMA method
      DnBuffer[bar]=0.0;
      for(int iii=0; iii<int(speriod); iii++) DnBuffer[bar]+=UpBuffer[bar+iii];
      DnBuffer[bar]/=speriod;

      UpBuffer[bar]+=dPriceShift;
      DnBuffer[bar]+=dPriceShift;
     }

   double Up0=UpBuffer[SignalBar];
   double Dn0=DnBuffer[SignalBar];
   double Up1=UpBuffer[SignalBar+1];
   double Dn1=DnBuffer[SignalBar+1];

//--- reset alerts counters to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }

//--- generate a buy alert
   if(UpCount<AlertCount && Dn1>=Up1 && Dn0<Up0)
     {
      UpCount++;
      Alert(sBuySignal);
     }

//--- generate a sell alert
   if(DnCount<AlertCount && Dn1<=Up1 && Dn0>Up0)
     {
      DnCount++;
      Alert(sSellSignal);
     }

//--- generate push notifications
   if(Push && SignalBar)
     {
      if(prev_calculated!=rates_total) RePush=true;

      if(RePush)
        {
         if(Dn1>=Up1 && Dn0<Up0) if(SendNotification(sBuySignal)) RePush=false;
         if(Dn1<=Up1 && Dn0>Up0) if(SendNotification(sSellSignal)) RePush=false;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
