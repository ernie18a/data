//+------------------------------------------------------------------+
//|                                                   HL_MA_Band.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot HIST
#property indicator_label1  "Band upper;Band lower"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrYellowGreen,clrMagenta,clrGreen,clrSalmon
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
//--- plot H
#property indicator_label2  "MA High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot L
#property indicator_label3  "MA Low"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint           InpPeriod   =  20;         // MA period
input ENUM_MA_METHOD InpMethod   =  MODE_EMA;   // MA method
//--- indicator buffers
double         BufferHIST1[];
double         BufferHIST2[];
double         BufferColors[];
double         BufferH[];
double         BufferL[];
//--- global variables
int            period_ma;
int            handle_mah;
int            handle_mal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHIST1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHIST2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,BufferH,INDICATOR_DATA);
   SetIndexBuffer(4,BufferL,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"High/Low MA band("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffers parameters
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHIST1,true);
   ArraySetAsSeries(BufferHIST2,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferH,true);
   ArraySetAsSeries(BufferL,true);
//--- create handle MA
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_mal=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_LOW object was not created: Error ",GetLastError());
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
   if(rates_total<period_ma) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferHIST1,EMPTY_VALUE);
      ArrayInitialize(BufferHIST2,EMPTY_VALUE);
      ArrayInitialize(BufferColors,EMPTY_VALUE);
      ArrayInitialize(BufferH,EMPTY_VALUE);
      ArrayInitialize(BufferL,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferL);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHIST1[i]=BufferH[i];
      BufferHIST2[i]=BufferL[i];
      if(BufferH[i]>BufferH[i+1])
        {
         if(BufferL[i]>BufferL[i+1])
            BufferColors[i]=0;
         else
            BufferColors[i]=3;
        }
      else
        {
         if(BufferL[i]>BufferL[i+1])
            BufferColors[i]=2;
         else
            BufferColors[i]=1;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
