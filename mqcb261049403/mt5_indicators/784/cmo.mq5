//+------------------------------------------------------------------+
//|                                                          CMO.mq5 | 
//|                           Copyright © 2006, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property description "CMO"
//---- indicator version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window
//---- number of buffers used (2)
#property indicator_buffers 2 
//---- number of graphic plots used (1)
#property indicator_plots   1
//+----------------------------------------------+
//| constants                                    |
//+----------------------------------------------+
#define RESET  0 // constant used for recalculation of indicator values
//+----------------------------------------------+
//| CMO indicator plot settings                  |
//+----------------------------------------------+
//---- drawing style - DRAW_FILLING
#property indicator_type1   DRAW_FILLING
//---- colors used
#property indicator_color1  LightSeaGreen,DarkOrange
//---- indicator line style
#property indicator_style1  STYLE_SOLID
//---- line width
#property indicator_width1  1
//---- line label
#property indicator_label1  "CMO"
//+----------------------------------------------+
//| Horizontal levels                            |
//+----------------------------------------------+
#property indicator_level1  +50
#property indicator_level2    0
#property indicator_level3  -50
#property indicator_levelcolor SlateGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint Length=14;                        // Period
input ENUM_MA_METHOD Method=MODE_SMA;        // Smoothing method
input ENUM_APPLIED_PRICE Price=PRICE_CLOSE;  // Applied price
input int Shift=0;                           // Horizontal shift in bars
//+----------------------------------------------+
//---- declaration of arrays, used as indicator buffers
double Line1Buffer[];
double Line2Buffer[];
//---- declaration integer variables, used for calculation indexes
int min_rates_total;
//---- declaration of integer variable used for a handle
int MA_Handle;
//---- arrays, used as cycle buffers
int Count[];
double Bulls[],Bears[];
//+------------------------------------------------------------------+
//|  Recalc position of the recent element in the array              |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CountArray[],// return index of the current value
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
      CountArray[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- set min rates
   min_rates_total=int(Length);

//---- get handler of iMA indicator
   MA_Handle=iMA(NULL,0,Length,0,Method,Price);
   if(MA_Handle==INVALID_HANDLE) {Print(" Error in creation of iMA indicator"); return(1);}

//---- распределение памяти под массивы переменных
   int size=int(Length);
   if(ArrayResize(Count,size)<size) {Print("Error in ArrayResize of Count[] array"); return(1);}
   if(ArrayResize(Bulls,size)<size) {Print("Error in ArrayResize of Bulls[] array"); return(1);}
   if(ArrayResize(Bears,size)<size) {Print("Error in ArrayResize of Bears[] array"); return(1);}

   ArrayInitialize(Count,0);
   ArrayInitialize(Bulls,0);
   ArrayInitialize(Bears,0);

//---- set Line1Buffer[] array as indicator buffer
   SetIndexBuffer(0,Line1Buffer,INDICATOR_DATA);
//---- set horizontal shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- set plot draw begin (+min_rates_total)
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- set indexing as time series
   ArraySetAsSeries(Line1Buffer,true);

//---- set Line2Buffer[] array as indicator buffer
   SetIndexBuffer(1,Line2Buffer,INDICATOR_DATA);
//---- set horizontal shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- set plot draw begin (min_rates_total)
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- set indexing as time series
   ArraySetAsSeries(Line2Buffer,true);

//---- prepare indicator short name
   string shortname;
   StringConcatenate(shortname,"CMO(",Length,")");
//--- set indicator short name (shown in indicator window and tooltip)
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // total bars in the history at current tick
                const int prev_calculated,// bars, calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // High prices
                const double& low[],      // Low prices
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking of bars calculated
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables
   int limit,to_copy,bar;
   double MA[],dPrice,Sum;

//---- starting index first
   if(prev_calculated>rates_total || prev_calculated<=0) // checking of first call
     {
      limit=rates_total-2-min_rates_total; // starting index for all bars
     }
   else limit=rates_total-prev_calculated; // starting index for new bars
   to_copy=limit+2;

//---- copy new data to array
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);

//---- set indexing as time series
   ArraySetAsSeries(MA,true);

//---- calculation of indicator values
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      dPrice=MA[bar]-MA[bar+1];
      Bulls[Count[0]]=0.5*(MathAbs(dPrice)+dPrice);
      Bears[Count[0]]=0.5*(MathAbs(dPrice)-dPrice);

      double SumBulls=0,SumBears=0;
      for(int iii=0; iii<int(Length); iii++)
        {
         SumBulls+=Bulls[Count[iii]];
         SumBears+=Bears[Count[iii]];
        }

      Sum=SumBulls+SumBears;
      if(Sum) Line1Buffer[bar]=(SumBulls-SumBears)/(SumBulls+SumBears)*100;
      else Line1Buffer[bar]=0.0;
      Line2Buffer[bar]=0.0;
      if(bar) Recount_ArrayZeroPos(Count,Length);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
