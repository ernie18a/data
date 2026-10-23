//+------------------------------------------------------------------+
//|                                                     BB_Cloud.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Double-deviation Bollinger Band with cloud indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot Middle
#property indicator_label1  "Middle"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot TopCloud
#property indicator_label2  "Top Cloud H;Top Cloud L"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrMoccasin,clrMoccasin
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BottomCloud
#property indicator_label3  "Bottom Cloud H;Bottom Cloud L"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  clrLavender,clrLavender
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod      =  20;   // Period
input double   InpDeviation1  =  2.0;  // First deviation
input double   InpDeviation2  =  3.0;  // Second deviation
//--- indicator buffers
double         BufferMiddle[];
double         BufferTopCloud1[];
double         BufferTopCloud2[];
double         BufferBottomCloud1[];
double         BufferBottomCloud2[];
//--- global variables
double         deviation1;
double         deviation2;
int            period;
int            handle_bb1;
int            handle_bb2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation1=InpDeviation1;
   deviation2=InpDeviation2;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTopCloud1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTopCloud2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottomCloud1,INDICATOR_DATA);
   SetIndexBuffer(4,BufferBottomCloud2,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Double Bollinger Band ("+(string)period+","+DoubleToString(deviation1,1)+","+DoubleToString(deviation2,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferTopCloud1,true);
   ArraySetAsSeries(BufferTopCloud2,true);
   ArraySetAsSeries(BufferBottomCloud1,true);
   ArraySetAsSeries(BufferBottomCloud2,true);
//--- create handles
   ResetLastError();
   handle_bb1=iBands(NULL,PERIOD_CURRENT,period,0,deviation1,PRICE_CLOSE);
   if(handle_bb1==INVALID_HANDLE)
     {
      Print("The iBands(",(string)period,",",DoubleToString(deviation1,1),") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_bb2=iBands(NULL,PERIOD_CURRENT,period,0,deviation2,PRICE_CLOSE);
   if(handle_bb2==INVALID_HANDLE)
     {
      Print("The iBands(",(string)period,",",DoubleToString(deviation2,1),") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferTopCloud1,EMPTY_VALUE);
      ArrayInitialize(BufferTopCloud2,EMPTY_VALUE);
      ArrayInitialize(BufferBottomCloud1,EMPTY_VALUE);
      ArrayInitialize(BufferBottomCloud2,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_bb2,UPPER_BAND,0,count,BufferTopCloud1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb1,UPPER_BAND,0,count,BufferTopCloud2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb1,LOWER_BAND,0,count,BufferBottomCloud1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb2,LOWER_BAND,0,count,BufferBottomCloud2);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferMiddle[i]=(BufferTopCloud1[i]+BufferBottomCloud1[i])/2.0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
