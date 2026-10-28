//+------------------------------------------------------------------+
//|                                                     LR_Ratio.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Linear regression ratio"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot LRR
#property indicator_label1  "LSMAR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod1        =  10;            // Period LSMA first
input uint                 InpPeriod2        =  20;            // Period LSMA second
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferLRR[];
double         BufferMA[];
double         BufferLRL1[];
double         BufferLRL2[];
//--- global variables
int            period1;
int            period2;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period2=int(InpPeriod2<1 ? 1 : InpPeriod2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLRR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferLRL1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferLRL2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"LSMA ratio("+(string)period1+","+(string)period2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLRR,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferLRL1,true);
   ArraySetAsSeries(BufferLRL2,true);
//--- create MA handle
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
//--- Проверка на минимальное колиество баров для расчёта
   int max=fmax(period1,period2);
   if(rates_total<max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max-1;
      ArrayInitialize(BufferLRR,EMPTY_VALUE);
      ArrayInitialize(BufferLRL1,EMPTY_VALUE);
      ArrayInitialize(BufferLRL2,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт LRL1, LRL2
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double x_reg1=0,y_reg1=0,xy_reg1=0,x2_reg1=0;
      double x_reg2=0,y_reg2=0,xy_reg2=0,x2_reg2=0;
      //--- LRL1
      for(int j=0; j<period1; j++)
        {
         y_reg1+=BufferMA[i+j];
         xy_reg1+=BufferMA[i+j]*j;
         x_reg1+=j;
         x2_reg1+=j*j;
        }
      //--- LRL1
      double temp1=period1*x2_reg1-x_reg1*x_reg1;
      double m1=(period1*xy_reg1-x_reg1*y_reg1)/(temp1!=0 ? temp1 : DBL_MIN);
      double yint1=(y_reg1+m1*x_reg1)/period1;
      BufferLRL1[i]=yint1-m1*period1;
      //--- LRL2
      for(int j=0; j<period2; j++)
        {
         y_reg2+=BufferMA[i+j];
         xy_reg2+=BufferMA[i+j]*j;
         x_reg2+=j;
         x2_reg2+=j*j;
        }
      //--- LRL1
      double temp2=period2*x2_reg2-x_reg2*x_reg2;
      double m2=(period2*xy_reg2-x_reg2*y_reg2)/(temp2!=0 ? temp2 : DBL_MIN);
      double yint2=(y_reg2+m2*x_reg2)/period2;
      BufferLRL2[i]=yint2-m2*period2;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferLRR[i]=BufferLRL1[i]/(BufferLRL2[i]>0 ? BufferLRL2[i] : DBL_MIN);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
