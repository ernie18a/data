//+------------------------------------------------------------------+
//|                                        Projection_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Projection oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot PO
#property indicator_label1  "Projection osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  14;   // Period
input double   InpOverbought  =  90;   // Overbought
input double   InpOversold    =  10;   // Oversold
//--- indicator buffers
double         BufferPO[];
double         BufferH[];
double         BufferL[];
//--- global variables
double         overbought;
double         oversold;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Projection oscillator ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2*period-1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPO,true);
   ArraySetAsSeries(BufferH,true);
   ArraySetAsSeries(BufferL,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferPO,EMPTY_VALUE);
      ArrayInitialize(BufferH,0);
      ArrayInitialize(BufferL,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferH[i]=high[i];
      BufferL[i]=low[i];
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double SlopeHigh=LRegSlope(BufferH,i);
      double SlopeLow=LRegSlope(BufferL,i);
      double UpProjBand=high[i];
      double DnProjBand=low[i];

      for(int j=1; j<=period; j++)
        {
         UpProjBand=fmax(UpProjBand,high[i+j]+j*SlopeHigh);
         DnProjBand=fmin(DnProjBand,low[i+j]-j*SlopeLow);
        }
      BufferPO[i]=(UpProjBand!=DnProjBand ? 100.0*(close[i]-DnProjBand)/(UpProjBand-DnProjBand) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Linear regression slope                                          |
//+------------------------------------------------------------------+
double LRegSlope(const double &price[],const int index)
  {
   double x=0,y=0,xy=0,x2=0,temp=0,m=0;
   for(int i=0; i<period; i++)
     {
      y=y+price[index+i];
      xy=xy+price[index+i]*i;
      x=x+i;
      x2=x2+i*i;
     }
   temp=period*x2-x*x;
   m=(period*xy-x*y)/temp;

   return(-m);
  }
//+------------------------------------------------------------------+
