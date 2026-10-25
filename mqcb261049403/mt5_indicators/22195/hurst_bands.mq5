//+------------------------------------------------------------------+
//|                                                  Hurst_Bands.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Hurst Bands indicator"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   7
//--- plot Center
#property indicator_label1  "Center"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ExtUP
#property indicator_label2  "Extreme High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLightBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ExtDN
#property indicator_label3  "Extreme Low"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLightBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot OutUP
#property indicator_label4  "Outer High"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot OutDN
#property indicator_label5  "Outer Low"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot InnUP
#property indicator_label6  "Inner High"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrYellowGreen
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot InnDN
#property indicator_label7  "Inner Low"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrYellowGreen
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  10;         // Period
input double            InpInner       =  1.6;        // Inner value
input double            InpOuter       =  2.6;        // Outer value
input double            InpExtreme     =  4.2;        // Extreme value
input ENUM_INPUT_YES_NO InpShowExtreme =  INPUT_YES;  // Show extreme lines
input ENUM_INPUT_YES_NO InpShowOuter   =  INPUT_YES;  // Show outer lines
input ENUM_INPUT_YES_NO InpShowInner   =  INPUT_YES;  // Show inner lines
//--- indicator buffers
double         BufferCenter[];
double         BufferExtUP[];
double         BufferExtDN[];
double         BufferOutUP[];
double         BufferOutDN[];
double         BufferInnUP[];
double         BufferInnDN[];
double         BufferMA[];
//--- global variables
double         inner;
double         outer;
double         extreme;
int            period;
int            displacement;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   displacement=int(period/2.0+1.0);
   inner=fabs(InpInner);
   outer=fabs(InpOuter);
   extreme=fabs(InpExtreme);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCenter,INDICATOR_DATA);
   SetIndexBuffer(1,BufferExtUP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferExtDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferOutUP,INDICATOR_DATA);
   SetIndexBuffer(4,BufferOutDN,INDICATOR_DATA);
   SetIndexBuffer(5,BufferInnUP,INDICATOR_DATA);
   SetIndexBuffer(6,BufferInnDN,INDICATOR_DATA);
   SetIndexBuffer(7,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Hurst Bands ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCenter,true);
   ArraySetAsSeries(BufferExtUP,true);
   ArraySetAsSeries(BufferExtDN,true);
   ArraySetAsSeries(BufferOutUP,true);
   ArraySetAsSeries(BufferOutDN,true);
   ArraySetAsSeries(BufferInnUP,true);
   ArraySetAsSeries(BufferInnDN,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period,0,MODE_SMA,PRICE_MEDIAN);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(displacement+period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-displacement-period-1;
      ArrayInitialize(BufferCenter,EMPTY_VALUE);
      ArrayInitialize(BufferExtUP,EMPTY_VALUE);
      ArrayInitialize(BufferExtDN,EMPTY_VALUE);
      ArrayInitialize(BufferOutUP,EMPTY_VALUE);
      ArrayInitialize(BufferOutDN,EMPTY_VALUE);
      ArrayInitialize(BufferInnUP,EMPTY_VALUE);
      ArrayInitialize(BufferInnDN,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCenter[i]=BufferMA[i+displacement];
      double extreme_band=BufferCenter[i]*extreme/100.0;
      double outer_band=BufferCenter[i]*outer/100.0;
      double inner_band=BufferCenter[i]*inner/100.0;

      BufferExtUP[i]=(InpShowExtreme ? BufferCenter[i]+extreme_band : EMPTY_VALUE);
      BufferExtDN[i]=(InpShowExtreme ? BufferCenter[i]-extreme_band : EMPTY_VALUE);
      BufferOutUP[i]=(InpShowOuter ? BufferCenter[i]+outer_band : EMPTY_VALUE);
      BufferOutDN[i]=(InpShowOuter ? BufferCenter[i]-outer_band : EMPTY_VALUE);
      BufferInnUP[i]=(InpShowInner ? BufferCenter[i]+inner_band : EMPTY_VALUE);
      BufferInnDN[i]=(InpShowInner ? BufferCenter[i]-inner_band : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
