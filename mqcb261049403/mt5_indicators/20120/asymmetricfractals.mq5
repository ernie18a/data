//+------------------------------------------------------------------+
//|                                           AsymmetricFractals.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Fractal Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot DN
#property indicator_label2  "Fractal Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint     InpNumBefore   =  4; // Number of bars on the left
input uint     InpNumAfter    =  2; // Number of bars on the right
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
//--- global variables
int            num_before;
int            num_after;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   num_before=int(InpNumBefore<1 ? 1 : InpNumBefore);
   num_after=int(InpNumAfter<1 ? 1 : InpNumAfter);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"AsymmetricFractals("+(string)num_before+","+(string)num_after+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
//---
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
//--- Проверка на минимальное колиество баров для расчёта
   int max=num_before+num_after;
   if(rates_total<max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
     }
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      bool fractal_up=true;
      bool fractal_dn=true;
      //--- find
      for(int n=1; n<=num_before; n++)
        {
         if(high[i+num_after+n]>=high[i+num_after]) fractal_up=false;
         if(low[i+num_after+n]<=low[i+num_after]) fractal_dn=false;
        }
      for(int n=1 ;n<=num_after; n++)
        {
         if(high[i+num_after-n]>=high[i+num_after]) fractal_up=false;
         if(low[i+num_after-n]<=low[i+num_after]) fractal_dn=false;
        }
      //--- fractals
      if(fractal_up)
         BufferUP[i+num_after]=high[i+num_after];
      else
         BufferUP[i+num_after]=EMPTY_VALUE;
      if(fractal_dn)
         BufferDN[i+num_after]=low[i+num_after];
      else
         BufferDN[i+num_after]=EMPTY_VALUE;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
