//+------------------------------------------------------------------+
//|                                     Average_True_Range_Bands.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Average True Range Bands"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot Top
#property indicator_label1  "Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bottom
#property indicator_label2  "Bottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Top2
#property indicator_label3  "Bottom2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom2
#property indicator_label4  "Top2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//---
enum ENUM_CALC_MODE
  {
   MODE_CALC_CLOSE,  // Close
   MODE_CALC_HL      // High/Low
  };
//--- input parameters
input uint              InpPeriod         =  14;               // ATR period
input double            InpDeviation      =  2.0;              // Deviation
input ENUM_CALC_MODE    InpMode           =  MODE_CALC_CLOSE;  // Calculating mode
input ENUM_INPUT_YES_NO InpShowDeviation  =  INPUT_NO;         // Show deviation line
//--- indicator buffers
double         BufferTop[];
double         BufferBottom[];
double         BufferTop2[];
double         BufferBottom2[];
double         BufferTrend[];
double         BufferATR[];
//--- global variables
double         deviation;
int            period_atr;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTop2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferTrend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR Bands ("+(string)period_atr+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpShowDeviation);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,InpShowDeviation);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferTop2,true);
   ArraySetAsSeries(BufferBottom2,true);
   ArraySetAsSeries(BufferTrend,true);
   ArraySetAsSeries(BufferATR,true);
//--- create handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_atr,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferTop2,EMPTY_VALUE);
      ArrayInitialize(BufferBottom2,EMPTY_VALUE);
      ArrayInitialize(BufferTrend,0);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ATR=BufferATR[i];
      BufferTrend[i]=(close[i]>BufferTop[i+1] ? 1 : close[i]<BufferBottom[i+1] ? -1 : BufferTrend[i+1]);

      if(BufferTrend[i]==1)
        {
         if(InpMode==MODE_CALC_CLOSE)
           {
            BufferBottom[i]=close[i]-ATR*deviation;
            BufferTop[i]=close[i]+ATR*deviation;
           }
         else
           {
            BufferTop[i]=low[i]+ATR*deviation;
            BufferBottom[i]=high[i]-ATR*deviation;
           }
         if(BufferBottom[i]<BufferBottom[i+1])
            BufferBottom[i]=BufferBottom[i+1];
        }
      else
        {
         if(BufferTrend[i]==-1)
           {
            if(InpMode==MODE_CALC_CLOSE)
              {
               BufferBottom[i]=close[i]-ATR*deviation;
               BufferTop[i]=close[i]+ATR*deviation;
              }
            else
              {
               BufferBottom[i]=high[i]-ATR*deviation;
               BufferTop[i]=low[i]+ATR*deviation;
              }
            if(BufferTop[i]>BufferTop[i+1])
               BufferTop[i]=BufferTop[i+1];
           }
        }

      if(InpMode==MODE_CALC_CLOSE)
        {
         BufferBottom2[i]=close[i]+ATR*deviation;
         BufferTop2[i]=close[i]-ATR*deviation;
        }
      else
        {
         BufferBottom2[i]=low[i]+ATR*deviation;
         BufferTop2[i]=high[i]-ATR*deviation;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
