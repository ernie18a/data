//+------------------------------------------------------------------+
//|                                                          CAD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Consecutive Advance/Decline indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot Advance
#property indicator_label1  "Advance"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Decline
#property indicator_label2  "Decline"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferAdvance[];
double         BufferDecline[];
double         BufferMA[];
//--- global variables
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAdvance,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDecline,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Consecutive Advance/Decline");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAdvance,true);
   ArraySetAsSeries(BufferDecline,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
      limit=rates_total-2;
      ArrayInitialize(BufferAdvance,EMPTY_VALUE);
      ArrayInitialize(BufferDecline,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
         BufferAdvance[i]=BufferDecline[i]=0;
      else
        {
         if(BufferMA[i]>BufferMA[i+1])
           {
            BufferAdvance[i]=BufferAdvance[i+1]+1;
            BufferDecline[i]=0;
           }
         else
           {
            if(BufferMA[i]<BufferMA[i+1])
              {
               BufferDecline[i]=BufferDecline[i+1]+1;
               BufferAdvance[i]=0.;
              }
            else
               BufferAdvance[i]=BufferDecline[i]=0.;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
