//+------------------------------------------------------------------+
//|                                             Projection_Bands.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Projection Bands indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot BandUP
#property indicator_label1  "Band Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BandDN
#property indicator_label2  "Band Down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod=14;   // Period
//--- indicator buffers
double         BufferBandUP[];
double         BufferBandDN[];
double         BufferH[];
double         BufferL[];
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
   SetIndexBuffer(0,BufferBandUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBandDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Projection Bands ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2*period-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,2*period-1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBandUP,true);
   ArraySetAsSeries(BufferBandDN,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferBandUP,EMPTY_VALUE);
      ArrayInitialize(BufferBandDN,EMPTY_VALUE);
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
      BufferBandUP[i]=UpProjBand;
      BufferBandDN[i]=DnProjBand;
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
