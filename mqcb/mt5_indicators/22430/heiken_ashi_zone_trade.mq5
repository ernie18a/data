//+------------------------------------------------------------------+
//|                                       Heiken_Ashi_Zone_Trade.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Heiken Ashi Zone Trade"
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   4
//--- plot UP
#property indicator_label1  "Bullish zone"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Bearish zone"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot NL
#property indicator_label3  "Neutral zone"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Candle
#property indicator_label4  "Open;High;Low;Close"
#property indicator_type4   DRAW_COLOR_CANDLES
#property indicator_color4  clrGreen,clrChartreuse,clrRed,clrOrange,clrLightGray,clrLavender,clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- enums
enum ENUM_CALC_SOURCE
  {
   SOURCE_PRICE,     // Price
   SOURCE_HA         // Heiken Ashi
  };
//---
enum ENUM_CALC_MODE
  {
   MODE_AO,          // AO
   MODE_AC,          // AC
   MODE_AOAC         // AO+AC
  };
//--- input parameters
input ENUM_CALC_SOURCE  InpSource      =  SOURCE_PRICE;  // Data source
input uint              InpPeriodFast  =  5;             // Fast MA period
input uint              InpPeriodSlow  =  35;            // Slow MA period
input uint              InpPeriodAC    =  5;             // AC period
input ENUM_CALC_MODE    InpMode        =  MODE_AOAC;     // Calculating method
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
double         BufferHA_O[];
double         BufferHA_C[];
double         BufferHA_M[];
double         BufferAO[];
double         BufferAC[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_ac;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_ac=int(InpPeriodAC<1 ? 1 : InpPeriodAC);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(6,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(7,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,BufferHA_O,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferHA_C,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferHA_M,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferAO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferAC,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,32);
   PlotIndexSetInteger(1,PLOT_ARROW,32);
   PlotIndexSetInteger(2,PLOT_ARROW,32);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Heiken Ashi Zone Trade ("+(string)period_fast+","+(string)period_slow+","+(string)period_ac+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNL,true);
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferHA_O,true);
   ArraySetAsSeries(BufferHA_C,true);
   ArraySetAsSeries(BufferHA_M,true);
   ArraySetAsSeries(BufferAO,true);
   ArraySetAsSeries(BufferAC,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,6);
      ArrayInitialize(BufferHA_O,0);
      ArrayInitialize(BufferHA_C,0);
      ArrayInitialize(BufferHA_M,0);
      ArrayInitialize(BufferAO,0);
      ArrayInitialize(BufferAC,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(InpSource==SOURCE_HA)
        {
         BufferHA_O[i]=(i==rates_total-2 ? (open[i+1]+close[i+1])/2.0 : (BufferHA_O[i+1]+BufferHA_C[i+1])/2.0);
         BufferHA_C[i]=(open[i]+high[i]+low[i]+close[i])/4.0;
         double HA_H=fmax(BufferHA_O[i],fmax(BufferHA_C[i],high[i]));
         double HA_L=fmin(BufferHA_O[i],fmin(BufferHA_C[i],low[i]));
         BufferHA_M[i]=(HA_H+HA_L)/2.0;
        }
      else
         BufferHA_M[i]=(high[i]+low[i])/2.0;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferAO[i]=GetSMA(rates_total,i,period_fast,BufferHA_M)-GetSMA(rates_total,i,period_slow,BufferHA_M);
      BufferAC[i]=BufferAO[i]-GetSMA(rates_total,i,period_ac,BufferAO);
     }
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      bool ao=(BufferAO[i]>BufferAO[i+1] ? true : false);
      bool ac=(BufferAC[i]>BufferAC[i+1] ? true : false);

      BufferUP[i]=BufferDN[i]=BufferNL[i]=EMPTY_VALUE;
      BufferCandleOpen[i]=open[i];
      BufferCandleHigh[i]=high[i];
      BufferCandleLow[i]=low[i];
      BufferCandleClose[i]=close[i];

      if(InpMode==MODE_AO)
        {
         if(ao)
           {
            BufferUP[i]=open[i];
            BufferColors[i]=(open[i]<close[i] ? 0 : open[i]>close[i] ? 1 : 6);
           }
         else
           {
            if(!ao)
              {
               BufferDN[i]=open[i];
               BufferColors[i]=(open[i]>close[i] ? 2 : open[i]<close[i] ? 3 : 6);
              }
            else
              {
               BufferNL[i]=open[i];
               BufferColors[i]=(open[i]<close[i] ? 4 : open[i]>close[i] ? 5 : 6);
              }
           }
        }
      else
        {
         if(InpMode==MODE_AC)
           {
            if(ac)
              {
               BufferUP[i]=open[i];
               BufferColors[i]=(open[i]<close[i] ? 0 : open[i]>close[i] ? 1 : 6);
              }
            else
              {
               if(!ac)
                 {
                  BufferDN[i]=open[i];
                  BufferColors[i]=(open[i]>close[i] ? 2 : open[i]<close[i] ? 3 : 6);
                 }
               else
                 {
                  BufferNL[i]=open[i];
                  BufferColors[i]=(open[i]<close[i] ? 4 : open[i]>close[i] ? 5 : 6);
                 }
              }
           }
         //--- MODE_AOAC
         else
           {
            if(ao && ac)
              {
               BufferUP[i]=open[i];
               BufferColors[i]=(open[i]<close[i] ? 0 : open[i]>close[i] ? 1 : 6);
              }
            else
              {
               if(!ao && !ac)
                 {
                  BufferDN[i]=open[i];
                  BufferColors[i]=(open[i]>close[i] ? 2 : open[i]<close[i] ? 3 : 6);
                 }
               else
                 {
                  BufferNL[i]=open[i];
                  BufferColors[i]=(open[i]<close[i] ? 4 : open[i]>close[i] ? 5 : 6);
                 }
              }
           }
        }
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
