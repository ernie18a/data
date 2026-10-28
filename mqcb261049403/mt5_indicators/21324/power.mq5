//+------------------------------------------------------------------+
//|                                                        Power.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Power oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot Peak
#property indicator_label1  "Bear Power"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Valley
#property indicator_label2  "Bull Power"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Power
#property indicator_label3  "Power"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
input uint     InpRange    =  14;   // Range
//--- indicator buffers
double         BufferBearPower[];
double         BufferBullPower[];
double         BufferPower[];
double         BufferBL[];
double         BufferBR[];
double         BufferMA[];
//--- global variables
int            period_ma;
int            range;
int            period_max;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   range=int(InpRange<1 ? 1 : InpRange);
   period_max=fmax(period_ma,range);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBearPower,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBullPower,INDICATOR_DATA);
   SetIndexBuffer(2,BufferPower,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferBR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Power ("+(string)period_ma+","+(string)range+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBearPower,true);
   ArraySetAsSeries(BufferBullPower,true);
   ArraySetAsSeries(BufferPower,true);
   ArraySetAsSeries(BufferBL,true);
   ArraySetAsSeries(BufferBR,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferBearPower,EMPTY_VALUE);
      ArrayInitialize(BufferBullPower,EMPTY_VALUE);
      ArrayInitialize(BufferPower,EMPTY_VALUE);
      ArrayInitialize(BufferBL,0);
      ArrayInitialize(BufferBR,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBL[i]=(high[i]>BufferMA[i] ? 1 : 0);
      BufferBR[i]=(low[i]<BufferMA[i] ? 1 : 0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double BullAvg=GetSMA(rates_total,i,range,BufferBL);
      double BearAvg=GetSMA(rates_total,i,range,BufferBR);

      BufferPower[i]=100.0*fabs(BullAvg-BearAvg);
      BufferBearPower[i]=100.0*BearAvg;
      BufferBullPower[i]=100.0*BullAvg;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
     result=result+(as_series ? price[index+i] : price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
