//+------------------------------------------------------------------+
//|                                                      Mogalef.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Mogalef Bands indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot Top
#property indicator_label1  "Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Central
#property indicator_label2  "Central"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "Bottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriodLG    =  3;    // Linear regression period
input uint     InpPeriodDev   =  7;    // Standard deviation period
input double   InpMultiplier  =  2.0;  // Multiplier
//--- indicator buffers
double         BufferTop[];
double         BufferCentral[];
double         BufferBottom[];
double         BufferPrice[];
double         BufferDev[];
//--- global variables
double         multiplier;
int            period_lg;
int            period_dv;
int            period_max;
int            handle_dev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_lg=int(InpPeriodLG<2 ? 2 : InpPeriodLG);
   period_dv=int(InpPeriodDev<1 ? 1 : InpPeriodDev);
   period_max=fmax(period_dv,period_lg);
   multiplier=InpMultiplier;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCentral,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDev,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Mogalef Bands ("+(string)period_lg+","+(string)period_dv+","+DoubleToString(multiplier,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max+period_lg+1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_max+period_lg+1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,period_max+period_lg+1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferCentral,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferDev,true);
//--- create MA's handles
   ResetLastError();
   handle_dev=iStdDev(NULL,PERIOD_CURRENT,period_dv,0,MODE_SMA,PRICE_CLOSE);
   if(handle_dev==INVALID_HANDLE)
     {
      Print("The iStdDev(",(string)period_dv,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferTop,0);
      ArrayInitialize(BufferCentral,0);
      ArrayInitialize(BufferBottom,0);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferDev,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_dev,0,0,count,BufferDev);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferPrice[i]=(2.0*close[i]+open[i]+low[i]+high[i])/5.0;
      double x=0,y=0,xy=0,x2=0;
      for(int j=0; j<period_lg; j++)
        {
         y+=BufferPrice[i+j];
         xy+=BufferPrice[i+j]*j;
         x+=j;
         x2+=j*j;
        }
      double temp=period_lg*x2-x*x;
      double m=(period_lg*xy-x*y)/temp;
      double yint=(y+m*x)/period_lg;
      BufferCentral[i]=yint-m*period_lg;

      BufferTop[i]=BufferCentral[i]+multiplier*BufferDev[i];
      BufferBottom[i]=BufferCentral[i]-multiplier*BufferDev[i];

      if(BufferCentral[i]<BufferTop[i+1] && BufferCentral[i]>BufferBottom[i+1])
        {
         BufferTop[i]=BufferTop[i+1];
         BufferCentral[i]=BufferCentral[i+1];
         BufferBottom[i]=BufferBottom[i+1];
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
