//+------------------------------------------------------------------+
//|                                                       VORTEX.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "\"VORTEX\" indicator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot VIP
#property indicator_label1  "+VI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot VIM
#property indicator_label2  "- VI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
//--- indicator buffers
double         BufferVIP[];
double         BufferVIM[];
double         BufferVipRAW[];
double         BufferVimRAW[];
double         BufferATR[];
double         BufferVipAVG[];
double         BufferVimAVG[];
double         BufferAtrAVG[];
//--- global variables
int            period_ind;
int            handle_atr;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVIP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferVIM,INDICATOR_DATA);
   SetIndexBuffer(2,BufferVipRAW,INDICATOR_DATA);
   SetIndexBuffer(3,BufferVimRAW,INDICATOR_DATA);
   SetIndexBuffer(4,BufferATR,INDICATOR_DATA);
   SetIndexBuffer(5,BufferVipAVG,INDICATOR_DATA);
   SetIndexBuffer(6,BufferVimAVG,INDICATOR_DATA);
   SetIndexBuffer(7,BufferAtrAVG,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VORTEX ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVIP,true);
   ArraySetAsSeries(BufferVIM,true);
   ArraySetAsSeries(BufferVipRAW,true);
   ArraySetAsSeries(BufferVimRAW,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferVipAVG,true);
   ArraySetAsSeries(BufferVimAVG,true);
   ArraySetAsSeries(BufferAtrAVG,true);
//--- create MA's handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,1);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(1) object was not created: Error ",GetLastError());
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferVIP,EMPTY_VALUE);
      ArrayInitialize(BufferVIM,EMPTY_VALUE);
      ArrayInitialize(BufferVipRAW,0);
      ArrayInitialize(BufferVimRAW,0);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferVipAVG,0);
      ArrayInitialize(BufferVimAVG,0);
      ArrayInitialize(BufferAtrAVG,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVipRAW[i]=fabs(high[i]-low[i+1]);
      BufferVimRAW[i]=fabs(low[i]-high[i+1]);
     }
     
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVipRAW,BufferVipAVG)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVimRAW,BufferVimAVG)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferATR,BufferAtrAVG)==0)
      return 0;
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(BufferAtrAVG[i]!=0)
        {
         BufferVIP[i]=100.0*BufferVipAVG[i]/BufferAtrAVG[i];
         BufferVIM[i]=100.0*BufferVimAVG[i]/BufferAtrAVG[i];
        }
      else
        {
         BufferVIP[i]=EMPTY_VALUE;
         BufferVIM[i]=EMPTY_VALUE;
        }
     }
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
