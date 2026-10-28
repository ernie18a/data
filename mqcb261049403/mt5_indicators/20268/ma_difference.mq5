//+------------------------------------------------------------------+
//|                                                MA_Difference.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot Difference
#property indicator_label1  "Difference"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA1
#property indicator_label2  "MA1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOliveDrab
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot MA2
#property indicator_label3  "MA2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriodMA1      =  14;            // MA1 period
input ENUM_MA_METHOD       InpMethodMA1      =  MODE_SMA;      // MA1 method
input uint                 InpPeriodMA2      =  14;            // MA2 period
input ENUM_MA_METHOD       InpMethodMA2      =  MODE_EMA;      // MA2 method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_INPUT_YES_NO    InpAbsolute       =  INPUT_YES;     // Absolute difference
input ENUM_INPUT_YES_NO    InpShowDiff       =  INPUT_YES;     // Show difference MA1/MA2
input ENUM_INPUT_YES_NO    InpShowMA1        =  INPUT_YES;     // Show MA1
input ENUM_INPUT_YES_NO    InpShowMA2        =  INPUT_YES;     // Show MA2
//--- indicator buffers
double                     BufferDiff[];
double                     BufferMA1[];
double                     BufferMA2[];
double                     BufferTmpMA[];
double                     BufferTmpMA1[];
double                     BufferTmpMA2[];
//--- global variables
int                        period_ma1;
int                        period_ma2;
int                        handle_ma;
int                        handle_ma1;
int                        handle_ma2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_ma1=int(InpPeriodMA1<1 ? 1 : InpPeriodMA1);
   period_ma2=int(InpPeriodMA2<1 ? 1 : InpPeriodMA2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDiff,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTmpMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTmpMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferTmpMA2,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"MA difference("+(string)period_ma1+","+(string)period_ma2+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferTmpMA,true);
   ArraySetAsSeries(BufferTmpMA1,true);
   ArraySetAsSeries(BufferTmpMA2,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_ma1,0,InpMethodMA1,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period_ma2,0,InpMethodMA2,InpAppliedPrice);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma2,") object was not created: Error ",GetLastError());
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferDiff,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,EMPTY_VALUE);
      ArrayInitialize(BufferMA2,EMPTY_VALUE);
      ArrayInitialize(BufferTmpMA,EMPTY_VALUE);
      ArrayInitialize(BufferTmpMA1,EMPTY_VALUE);
      ArrayInitialize(BufferTmpMA2,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferTmpMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferTmpMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferTmpMA2);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double Pr=BufferTmpMA[i];
      double MA1=BufferTmpMA1[i];
      double MA2=BufferTmpMA2[i];
      BufferMA1[i]=(InpShowMA1 ? InpAbsolute ? fabs(MA1-Pr)/Point() : (MA1-Pr)/Point() : EMPTY_VALUE);
      BufferMA2[i]=(InpShowMA2 ? InpAbsolute ? fabs(MA2-Pr)/Point() : (MA2-Pr)/Point() : EMPTY_VALUE);
      BufferDiff[i]=(InpShowDiff ? InpAbsolute ? fabs(MA1-MA2)/Point() : (MA1-MA2)/Point() : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
