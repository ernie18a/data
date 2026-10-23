//+------------------------------------------------------------------+
//|                                                    EMA_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MA Trend indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot FH
#property indicator_label1  "Fast MA High"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot FL
#property indicator_label2  "Fast MA Low"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SH
#property indicator_label3  "Slow MA High"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot SL
#property indicator_label4  "Slow MA Low"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint           InpPeriodFastMA   =  21;         // Fast MA period
input ENUM_MA_METHOD InpMethodFastMA   =  MODE_EMA;   // Fast MA method
input uint           InpPeriodSlowMA   =  34;         // Slow MA period
input ENUM_MA_METHOD InpMethodSlowMA   =  MODE_EMA;   // Slow MA method
//--- indicator buffers
double         BufferFH[];
double         BufferFL[];
double         BufferSH[];
double         BufferSL[];
//--- global variables
int            period_fma;
int            period_sma;
int            handle_fhma;
int            handle_flma;
int            handle_shma;
int            handle_slma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_sma=int(InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFH,INDICATOR_DATA);
   SetIndexBuffer(1,BufferFL,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSH,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSL,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MA Trend ("+(string)period_fma+","+(string)period_sma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFH,true);
   ArraySetAsSeries(BufferFL,true);
   ArraySetAsSeries(BufferSH,true);
   ArraySetAsSeries(BufferSL,true);
//--- create MA's handles
   ResetLastError();
   handle_fhma=iMA(NULL,PERIOD_CURRENT,period_fma,0,InpMethodFastMA,PRICE_HIGH);
   if(handle_fhma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_fma,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_flma=iMA(NULL,PERIOD_CURRENT,period_fma,0,InpMethodFastMA,PRICE_LOW);
   if(handle_flma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_fma,") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_shma=iMA(NULL,PERIOD_CURRENT,period_sma,0,InpMethodSlowMA,PRICE_HIGH);
   if(handle_shma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_sma,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_slma=iMA(NULL,PERIOD_CURRENT,period_sma,0,InpMethodSlowMA,PRICE_LOW);
   if(handle_slma==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_sma,") by PRICE_LOW object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferFH,EMPTY_VALUE);
      ArrayInitialize(BufferFL,EMPTY_VALUE);
      ArrayInitialize(BufferSH,EMPTY_VALUE);
      ArrayInitialize(BufferSL,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fhma,0,0,count,BufferFH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_flma,0,0,count,BufferFL);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_shma,0,0,count,BufferSH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_slma,0,0,count,BufferSL);
   if(copied!=count) return 0;
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
