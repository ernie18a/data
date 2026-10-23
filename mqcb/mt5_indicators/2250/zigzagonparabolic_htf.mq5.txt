//+------------------------------------------------------------------+ 
//|                                        ZigZagOnParabolic_HTF.mq5 |
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                                Khabarovsk, farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//--- Copyright
#property copyright "Copyright © 2014, Nikolay Kositsin"
//--- a link to the website of the author
#property link      "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
#property description "The ZigZag indicator with the timeframe selection option available in its input parameters."
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- three buffers are used for the indicator calculation and drawing
#property indicator_buffers 3
//--- only 1 plot is used
#property indicator_plots   1
//+----------------------------------------------+ 
//| Indicator drawing parameters                 |
//+----------------------------------------------+ 
//--- ZIGZAG is used for the indicator
#property indicator_type1   DRAW_COLOR_ZIGZAG
//--- the following colors are used for the indicator line
#property indicator_color1 clrDeepPink,clrBlue
//--- Indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "ZigZagOnParabolic_HTF"
//+----------------------------------------------+ 
//| declaration of constants                     |
//+----------------------------------------------+ 
#define RESET 0      // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+ 
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Indicator chart period (timeframe)
input double Step=0.02;                     // SAR step
input double Maximum=0.2;                   // SAR maximum
input bool ExtremumsShift=true;             // Extremum shift flag
//+----------------------------------------------+
//--- declaring dynamic arrays that will be further used as the indicator buffers
double HighestBuffer[];
double LowestBuffer[];
double ColorBuffer[];
//--- declaration of integer variables for the indicators handles
int Ind_Handle;
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Getting a timeframe as a line                                    |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT))*2+1;
//--- getting the handle of the ZigZagOnParabolic indicator
   Ind_Handle=iCustom(Symbol(),TimeFrame,"ZigZagOnParabolic",Step,Maximum,ExtremumsShift);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the ZigZagOnParabolic indicator");
      return(INIT_FAILED);
     }
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- Indexing buffer elements as timeseries   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//--- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- data window name and subwindow label 
   string shortname;
   StringConcatenate(shortname,"ZigZag on Parabolic(",GetStringTimeframe(TimeFrame),", ",
                     double(Step),", ",double(Maximum),", ",bool(ExtremumsShift),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declarations of local variables 
   double UpZigZag[1],DnZigZag[1];
   int limit,bar;
   static int LastCountBar,LastHighPos,LastLowPos;
   datetime ZigZagTime[1];
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1;  // starting index for calculation of all bars
      LastCountBar=0;
      LastHighPos=0;
      LastLowPos=0;
     }
   else limit=rates_total-prev_calculated;  // Starting index for the calculation of new bars 
   LastHighPos+=limit;
   LastLowPos+=limit;
   limit+=LastCountBar;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---
   LowestBuffer[LastLowPos]=0.0;
   HighestBuffer[LastHighPos]=0.0;
//---
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HighestBuffer[bar]=0.0;
      LowestBuffer[bar]=0.0;
     }
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- copy newly appeared data in the arrays
      if(CopyTime(NULL,TimeFrame,time[bar],1,ZigZagTime)<=0) return(RESET);

      if(time[bar+1]<ZigZagTime[0] && time[bar]>=ZigZagTime[0])
        {
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(Ind_Handle,1,time[bar],1,UpZigZag)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,0,time[bar],1,DnZigZag)<=0) return(RESET);
         //---
         if(UpZigZag[0])
           {
            int maxbar=FindMax(UpZigZag[0],bar,0,high);
            HighestBuffer[maxbar]=UpZigZag[0];
            LastHighPos=bar;
           }
         if(DnZigZag[0])
           {
            int minbar=FindMin(DnZigZag[0],bar,0,low);
            LowestBuffer[minbar]=DnZigZag[0];
            LastLowPos=bar;
           }
        }
     }
   LastCountBar=MathMax(LastHighPos,LastLowPos);
//--- the second large indicator coloring loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Max=HighestBuffer[bar];
      double Min=LowestBuffer[bar];

      if(!Max && !Min) ColorBuffer[bar]=ColorBuffer[bar+1];
      if(Max && Min)
        {
         if(ColorBuffer[bar+1]==0) ColorBuffer[bar]=1;
         else                      ColorBuffer[bar]=0;
        }
      //---
      if( Max && !Min) ColorBuffer[bar]=1;
      if(!Max &&  Min) ColorBuffer[bar]=0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+    
//| Search for first extremum according to its value in timeseries   | 
//+------------------------------------------------------------------+  
int FindMax(double Value,int start,int end,const double &Array[])
  {
//---
   for(int bar=start; bar>=end; bar--) if(Array[bar]>=Value) return(bar);
//---
   return(ArrayMaximum(Array,end,start-end));
  }
//+------------------------------------------------------------------+    
//| Search for first extremum according to its value in timeseries   | 
//+------------------------------------------------------------------+  
int FindMin(double Value,int start,int end,const double &Array[])
  {
//---
   for(int bar=start; bar>=end; bar--) if(Array[bar]<=Value) return(bar);
//---
   return(ArrayMinimum(Array,end,start-end));
  }
//+------------------------------------------------------------------+
