//+------------------------------------------------------------------+
//|                                                        ALWMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Asymmetric Linear Weighted Moving Average"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ALWMA
#property indicator_label1  "ALWMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_MODE
  {
   MODE_REGULAR,     // Regular
   MODE_INVERSE,     // Inverse
   MODE_ASYMMETRIC,  // Asymmetric
   MODE_INV_ASYMM    // Inverse asymmetric
  };
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_MODE            InpMode           =  MODE_REGULAR;  // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferALWMA[];
double         BufferMA[];
//--- global variables
int            period;
int            period_half;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   period_half=period/2;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferALWMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string method=StringSubstr(EnumToString(InpMode),5);
   IndicatorSetString(INDICATOR_SHORTNAME,ModeToString()+" LWMA ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferALWMA,true);
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferALWMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int bars=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,bars,BufferMA);
   if(copied!=bars) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double count=0,total=0,k=0;
      for(int j=i+period; j>=i; j--)
        {
         if(InpMode==MODE_REGULAR)
            count+=1;
         else
           {
            if(InpMode==MODE_INVERSE)
              {
               if(count==0)
                  count=period;
               else
                  count-=1;
              }
            else
              {
               if(InpMode==MODE_ASYMMETRIC)
                 {
                  if(count==0)
                     count=2;
                  else
                    {
                     if(j-i<period_half)
                        count+=2;
                     else
                        count-=2;
                    }
                 }
               else
                 {
                  if(count==0)
                     count=period;
                  else
                    {
                     if(j-i<period_half)
                        count-=2;
                     else
                        count+=2;
                    }
                 }
              }
           }
         k+=count;
         total+=BufferMA[j]*count;
        }
      BufferALWMA[i]=total/k;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Описание метода                                                  |
//+------------------------------------------------------------------+
string ModeToString(void)
  {
   return
     (
      InpMode==MODE_REGULAR ? "Regular" :
      InpMode==MODE_INVERSE ? "Inverse" :
      InpMode==MODE_ASYMMETRIC ? "Asymmetric" :
      "Inverse asymmetric"
     );
  }
//+------------------------------------------------------------------+
