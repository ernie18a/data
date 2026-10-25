//+------------------------------------------------------------------+
//|                                                          WRB.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wide Range Body indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot UP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot NU
#property indicator_label3  "Neutral Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot ND
#property indicator_label4  "Neutral Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint     InpPeriod=3;    // Range
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNU[];
double         BufferND[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNU,INDICATOR_DATA);
   SetIndexBuffer(3,BufferND,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
   PlotIndexSetInteger(2,PLOT_ARROW,119);
   PlotIndexSetInteger(3,PLOT_ARROW,119);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Wide Range Body ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNU,true);
   ArraySetAsSeries(BufferND,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNU,EMPTY_VALUE);
      ArrayInitialize(BufferND,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUP[i]=BufferDN[i]=BufferNU[i]=BufferND[i]=EMPTY_VALUE;
      bool up=true, dn=true, nl=true;
      for(int j=1; j<=period; j++)
        {
         if(fabs(open[i]-close[i])<fabs(open[i+j]-close[i+j]))
            nl=up=dn=false;
         else
           {
            if(close[i+j]<open[i+j] || close[i]<open[i])
               up=false;
            if(close[i+j]>open[i+j] || close[i]>open[i])
               dn=false;
           }
        }

      if(up)
         BufferUP[i]=low[i];
      else
         BufferUP[i]=EMPTY_VALUE;

      if(dn)
         BufferDN[i]=high[i];
      else
         BufferDN[i]=EMPTY_VALUE;

      if(nl && !up && !dn)
        {
         if(open[i]<close[i])
           {
            BufferNU[i]=low[i];
            BufferND[i]=EMPTY_VALUE;
           }
         else
           {
            BufferND[i]=high[i];
            BufferNU[i]=EMPTY_VALUE;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
