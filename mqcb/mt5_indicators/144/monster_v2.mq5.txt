//+------------------------------------------------------------------+
//|                                                 Monster_v1.3.mq5 |
//|                                         Copyright 2010, Q-Import |
//|                                                                  |
//+------------------------------------------------------------------+
// Please Modify and Post More Examples of Indicators
#property copyright "Q-Import"
#property version   "2.3"
#property indicator_separate_window
#property indicator_buffers 2            //Buffer On Indicator
#property indicator_plots   2            //Line On Indicator
//--- plot First Plot
#property indicator_label1  "Plot1"      //Type Of Line To Draw On First Plot
#property indicator_type1   DRAW_LINE      
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Second Plot                
#property indicator_label2  "Plot2"     //Type Of Line To Draw On Second Plot
#property indicator_type2   DRAW_LINE
#property indicator_color2  Blue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input bool               State1=true;
input int                Plot1=15;              //Period Of The First Plot
input int                Plot2=30;              //Period Of The Second Plot
input ENUM_APPLIED_PRICE ToClose=PRICE_CLOSE;   //Price Applied To Both Plots
//--- Other input parameters
int TriX_Handle1;   // handle for our Trix First Plot
int TriX_Handle2;   // handle for our Trix Second Plot
double TriX1[];     // Dynamic array to hold the values of Trix for each bars Plot 1
double TriX2[];     // Dynamic array to hold the values of Trix for each bars Plot 2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,TriX1,INDICATOR_DATA);
   SetIndexBuffer(1,TriX2,INDICATOR_DATA);
//--- get The Values For Array
   Print("Parameter AsSeries =",State1);
//--- Trix Plot1 Array
   ArraySetAsSeries(TriX1,State1);
//--- Trix Plot2 Array
   ArraySetAsSeries(TriX2,State1);
//--- display Name of Indicator,Periods, and Value
   IndicatorSetString(INDICATOR_SHORTNAME,"Trix CrossOver("+IntegerToString(Plot1)+")( "+IntegerToString(Plot2)+")"+string(State1));
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0.0);
//--- set accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,6);
   TriX_Handle1=iTriX(Symbol(),0,Plot1,ToClose);
   TriX_Handle2=iTriX(Symbol(),0,Plot2,ToClose);
//---
   return(0);
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
   int calculated=BarsCalculated(TriX_Handle1);
   if(calculated<rates_total)
     {
      Print("Not all data of TriX_Handle1 is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(TriX_Handle2);
   if(calculated<rates_total)
     {
      Print("Not all data of TriX_Handle2 is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<=0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      //--- last value is always copied
      to_copy++;
     }
//--- try to copy
   if(CopyBuffer(TriX_Handle1,0,0,to_copy,TriX1)<=0)return(0);
   if(CopyBuffer(TriX_Handle2,0,0,to_copy,TriX2)<=0)return(0);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
