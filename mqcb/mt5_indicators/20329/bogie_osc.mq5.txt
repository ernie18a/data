//+------------------------------------------------------------------+
//|                                                    Bogie_Osc.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Bogie
#property indicator_label1  "Bogie"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodFast     =  7;             // Fast MA period
input uint                 InpPeriodSlow     =  14;            // Slow MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferBogie[];
double         BufferMAF[];
double         BufferMAS[];
double         BufferMA1[];
//--- global variables
int            period_maf;
int            period_mas;
int            handle_maf;
int            handle_mas;
int            handle_ma1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_maf=int(InpPeriodFast<2 ? 2 : InpPeriodFast);
   period_mas=int(InpPeriodSlow<2 ? 2 : InpPeriodSlow);
   if(period_mas==period_maf) period_mas=period_maf+1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBogie,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMAF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA1,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Bogie("+(string)period_maf+","+(string)period_mas+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBogie,true);
   ArraySetAsSeries(BufferMAF,true);
   ArraySetAsSeries(BufferMAS,true);
   ArraySetAsSeries(BufferMA1,true);
//--- create MA's handle
   ResetLastError();
   handle_maf=iMA(NULL,PERIOD_CURRENT,period_maf-1,0,MODE_SMA,InpAppliedPrice);
   if(handle_maf==INVALID_HANDLE)
     {
      Print("The iMA(",string(period_maf-1),") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mas=iMA(NULL,PERIOD_CURRENT,period_mas-1,0,MODE_SMA,InpAppliedPrice);
   if(handle_mas==INVALID_HANDLE)
     {
      Print("The iMA(",string(period_mas-1),") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
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
   if(rates_total<3) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferBogie,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAF,0);
      ArrayInitialize(BufferMAS,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maf,0,0,count,BufferMAF);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mas,0,0,count,BufferMAS);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double left=BufferMAF[i+1]*(period_maf-1)*period_mas;
      double right=BufferMAS[i+1]*(period_mas-1)*period_maf;
      double bottom=period_maf-period_mas;
      double BogiePX=(left-right)/(bottom!=0 ? bottom : DBL_MIN);
      double ma=BufferMA1[i];
      BufferBogie[i]=(BogiePX/(ma!=0 ? ma : DBL_MIN)-1)*100;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
