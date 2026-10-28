//+------------------------------------------------------------------+
//|                                                      ZeroLag.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot ZL
#property indicator_label1  "ZL"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input uint                 InpGainLimit      =  50;            // Gain limit
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferZL[];
double         BufferSMA[];
double         BufferEMA[];
//--- global variables
int            handle_sma;
int            handle_ema;
int            period;
int            gain_limit;
double         gain10;
double         alpha;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   gain_limit=(int)InpGainLimit;
   alpha=2.0/(1.0+period);
   gain10=gain_limit/10.0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferZL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferEMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero lag EMA("+(string)period+","+(string)gain_limit+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferZL,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferEMA,true);
//--- create MA's handles
   ResetLastError();
   handle_sma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ema=iMA(Symbol(),PERIOD_CURRENT,period,0,MODE_EMA,InpAppliedPrice);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<3) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferZL,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferEMA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ema,0,0,count,BufferEMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   double diff=0,gain=0;
   for(int i=limit; i>=0; i--)
     {
      double err=BufferSMA[i]-BufferZL[i+1];
      if(fabs(alpha*err)>0.000000001)
        {
         double val=alpha*err;
         diff=BufferZL[i+1]-BufferEMA[i];
         gain=(val!=0 ? (err+alpha*diff)/val : 0);
        }
      double val=fmax(fmin(gain,gain10),-gain10);
      gain=(val>0 ? floor(val*10+0.5)/10 : ceil(val*10-0.5)/10);
      BufferZL[i]=alpha*(BufferEMA[i]+gain*err)+(1-alpha)*BufferZL[i+1];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
