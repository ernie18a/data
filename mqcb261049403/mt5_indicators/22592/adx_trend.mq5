//+------------------------------------------------------------------+
//|                                                    ADX_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "ADX Trend indicator"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Bearish ADXTrend"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Bullish ADXTrend"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_ANCHOR_BUFFER
  {
   ANCHOR_HL,     // High/Low
   ANCHOR_OPEN    // Open
  };
//--- input parameters
input uint                 InpPeriod1        =  10;            // First ADX period
input uint                 InpPeriod2        =  14;            // Second ADX period
input uint                 InpPeriod3        =  20;            // Third ADX period
input double               InpLev1           =  35.0;          // Lelel 1
input double               InpLev2           =  30.0;          // Level 2
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_ANCHOR_BUFFER   InpAnchorBuffer   =  ANCHOR_HL;     // Signal point anchor
//--- indicator buffers
double         BufferBear[];
double         BufferBull[];
double         BufferADX1[];
double         BufferADX2[];
double         BufferADX3[];
double         BufferPDI[];
double         BufferMDI[];
//--- global variables
double         lev1;
double         lev2;
int            period1;
int            period2;
int            period3;
int            handle_adx1;
int            handle_adx2;
int            handle_adx3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period3=int(InpPeriod3<1 ? 1 : InpPeriod3);
   lev1=(InpLev1);
   lev2=(InpLev2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBear,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBull,INDICATOR_DATA);
   SetIndexBuffer(2,BufferADX1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferADX2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferADX3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferPDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMDI,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ADX Trend indicator ("+(string)period1+","+(string)period2+","+(string)period3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBear,true);
   ArraySetAsSeries(BufferBull,true);
   ArraySetAsSeries(BufferADX1,true);
   ArraySetAsSeries(BufferADX2,true);
   ArraySetAsSeries(BufferADX3,true);
   ArraySetAsSeries(BufferPDI,true);
   ArraySetAsSeries(BufferMDI,true);
//--- create ADX's handles
   ResetLastError();
   handle_adx1=iADX(NULL,PERIOD_CURRENT,period1);
   if(handle_adx1==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx2=iADX(NULL,PERIOD_CURRENT,period2);
   if(handle_adx2==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx3=iADX(NULL,PERIOD_CURRENT,period3);
   if(handle_adx3==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period3,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferBear,EMPTY_VALUE);
      ArrayInitialize(BufferBull,EMPTY_VALUE);
      ArrayInitialize(BufferADX1,0);
      ArrayInitialize(BufferADX2,0);
      ArrayInitialize(BufferADX3,0);
      ArrayInitialize(BufferPDI,0);
      ArrayInitialize(BufferMDI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx1,0,0,count,BufferADX1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx2,0,0,count,BufferADX2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx3,0,0,count,BufferADX3);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx1,PLUSDI_LINE,0,count,BufferPDI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx1,MINUSDI_LINE,0,count,BufferMDI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ADX1_0=BufferADX1[i];
      double ADX2_0=BufferADX2[i];
      double ADX3_0=BufferADX3[i];
      double ADX1_1=BufferADX1[i+1];
      double ADX2_1=BufferADX2[i+1];
      double ADX3_1=BufferADX3[i+1];
      double DMI=BufferPDI[i]-BufferMDI[i];

      BufferBear[i]=BufferBull[i]=EMPTY_VALUE;
      if(ADX1_1<ADX1_0 && ADX2_1<ADX2_0 && ADX3_1<ADX3_0 && ADX1_0>lev1 && ADX2_0>lev2)
        {
         if(DMI>0)
            BufferBear[i]=(InpAnchorBuffer==ANCHOR_HL ? high[i] : open[i]);
         else
            BufferBull[i]=(InpAnchorBuffer==ANCHOR_HL ? low[i] : open[i]);
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
