//+------------------------------------------------------------------+
//|                                                  Magic_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Magic trend"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot MT
#property indicator_label1  "MT"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrOrangeRed,clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriodCCI   =  50;   // CCI period
input uint     InpPeriodATR   =  5;    // ATR period
//--- indicator buffers
double         BufferMT[];
double         BufferColors[];
double         BufferCCI[];
double         BufferATR[];
//--- global variables
int            period_cci;
int            period_atr;
int            handle_cci;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MT("+(string)period_cci+","+(string)period_atr+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMT,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferATR,true);
//--- create CCI, ATR handle
   ResetLastError();
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMT,EMPTY_VALUE);
      ArrayInitialize(BufferCCI,0);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   double cci=0,atr=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(BufferMT[i+1]==0 || BufferMT[i+1]==EMPTY_VALUE)
        {
         cci=BufferCCI[i+1];
         atr=BufferATR[i+1];
         BufferMT[i+1]=(cci>0 ? low[i+1]-atr : high[i+1]+atr);
        }
      cci=BufferCCI[i];
      atr=BufferATR[i];
      BufferMT[i]=(cci>0 ? fmax(BufferMT[i+1],low[i]-atr) : fmin(BufferMT[i+1],high[i]+atr));
      BufferColors[i]=(BufferMT[i]>BufferMT[i+1] ? 0 : BufferMT[i]<BufferMT[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
