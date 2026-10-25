//+------------------------------------------------------------------+
//|                                                       Pro_Go.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Williams Pro-Go indicator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   2
//--- plot Prof
#property indicator_label1  "Professional"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bublic
#property indicator_label2  "Public"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod      =  7;    // Period
input double   InpLevelTop    =  75.0; // Overbought
input double   InpLevelBottom =  25.0; // Oversold
//--- indicator buffers
double         BufferProf[];
double         BufferPublic[];
double         BufferRaw1[];
double         BufferRaw2[];
double         BufferRaw3[];
double         BufferRaw4[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferMAO[];
double         BufferMAC[];
//--- global variables
double         lev_top;
double         lev_bottom;
int            period_ma;
int            handle_mao;
int            handle_mac;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   lev_top=(InpLevelTop>100 ? 100 : InpLevelTop<1 ? 1 : InpLevelTop<1 ? 1 : InpLevelTop);
   lev_bottom=(InpLevelBottom<0 ? 0 : InpLevelBottom>=lev_top ? lev_top-1 : InpLevelBottom);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferProf,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPublic,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRaw1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferRaw2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferRaw3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRaw4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMAO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMAC,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Pro Go ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,lev_top);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,lev_bottom);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferProf,true);
   ArraySetAsSeries(BufferPublic,true);
   ArraySetAsSeries(BufferRaw1,true);
   ArraySetAsSeries(BufferRaw2,true);
   ArraySetAsSeries(BufferRaw3,true);
   ArraySetAsSeries(BufferRaw4,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferMAO,true);
   ArraySetAsSeries(BufferMAC,true);
//--- create MA's handles
   ResetLastError();
   handle_mao=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_OPEN);
   if(handle_mao==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_OPEN object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mac=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_CLOSE);
   if(handle_mac==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_CLOSE object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferProf,EMPTY_VALUE);
      ArrayInitialize(BufferPublic,EMPTY_VALUE);
      ArrayInitialize(BufferRaw1,0);
      ArrayInitialize(BufferRaw2,0);
      ArrayInitialize(BufferRaw3,0);
      ArrayInitialize(BufferRaw4,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferMAO,0);
      ArrayInitialize(BufferMAC,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mao,0,0,count,BufferMAO);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mac,0,0,count,BufferMAC);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMA1[i]=BufferMAO[i]-BufferMAC[i];
      BufferMA2[i]=BufferMAO[i]-BufferMAC[i+1];

      int bh=ArrayMaximum(BufferMA1,i,period_ma);
      int bl=ArrayMinimum(BufferMA1,i,period_ma);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double LLV=BufferMA1[bh];
      double HHV=BufferMA1[bl];

      BufferRaw1[i]=BufferMA1[i]-LLV;
      BufferRaw2[i]=HHV-LLV;

      bl=ArrayMinimum(BufferMA2,i,period_ma);
      bh=ArrayMaximum(BufferMA2,i,period_ma);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      LLV=BufferMA2[bl];
      HHV=BufferMA2[bh];

      BufferRaw3[i]=BufferMA2[i]-LLV;
      BufferRaw4[i]=HHV-LLV;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Avg2=GetSMA(rates_total,i,period_ma,BufferRaw2);
      double Avg4=GetSMA(rates_total,i,period_ma,BufferRaw4);
      BufferProf[i]=(Avg2!=0 ? 100.0*GetSMA(rates_total,i,period_ma,BufferRaw1)/Avg2 : 0);
      BufferPublic[i]=(Avg4!=0 ? 100.0*GetSMA(rates_total,i,period_ma,BufferRaw3)/Avg4 : 0);
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
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
