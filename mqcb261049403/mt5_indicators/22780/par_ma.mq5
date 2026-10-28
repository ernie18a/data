//+------------------------------------------------------------------+
//|                                                       Par_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Parabolic Moving Average indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MA
#property indicator_label1  "Parabolic MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferPMA[];
double         BufferMA[];
//--- global variables
double         sum_x;
double         sum_x2;
double         sum_x3;
double         sum_x4;
int            period_pma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_pma=int(InpPeriod<3 ? 3 : InpPeriod);
   sum_x=(1.0+period_pma)*period_pma/2.0;
   sum_x2=(1.0+period_pma)*(2.0*period_pma+1.0)*period_pma/6.0;
   sum_x3=sum_x*sum_x;
   sum_x4=(1.0+period_pma)*period_pma*(2.0*period_pma+1.0)*(3.0*period_pma*period_pma+3.0*period_pma-1.0)/30.0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Parabolic MA ("+(string)period_pma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPMA,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_pma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_pma-1;
      ArrayInitialize(BufferPMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum_y=0.0;
      double sum_xy=0.0;
      double sum_x2y=0.0;
      for(int j=1;j<=period_pma;j++)
        {
         double tmp=BufferMA[i+period_pma-j];
         sum_y+=tmp;
         sum_xy+=tmp*j;
         sum_x2y+=tmp*j*j;
        }
      double F=sum_x3;
      double M=sum_x4;
      double P=sum_y;
      double R=sum_xy;
      double S=sum_x2y;
      double E=sum_x2;
      double L=sum_x3;
      double Q=sum_x/period_pma;
      E-=Q*sum_x;
      F-=Q*sum_x2;
      R-=Q*P;
      Q=sum_x2/period_pma;
      L-=Q*sum_x;
      M-=Q*sum_x2;
      S-=Q*P;
      Q=L/E;
      double B2=(S-R*Q)/(M-F*Q);
      double B1=(R-F*B2)/E;
      double B0=(P-sum_x*B1-sum_x2*B2)/period_pma;
      BufferPMA[i]=B0+(B1+B2*period_pma)*period_pma;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
