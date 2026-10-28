//+------------------------------------------------------------------+
//|                                     Advanced_Fractal_Overlay.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Advanced Fractal Overlay"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot Candle
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLimeGreen,clrOrangeRed,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_TREND_TYPE
  {
   TREND_TYPE_BULLISH,
   TREND_TYPE_BEARISH,
  };
//--- indicator buffers
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
double         BufferFractUP[];
double         BufferFractDN[];
//--- global variables
int               handle_fr;
ENUM_TREND_TYPE   current;
bool              prev_fgnd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   current=TREND_TYPE_BULLISH;
   prev_fgnd=ChartGetInteger(0,CHART_FOREGROUND);
   ChartSetInteger(0,CHART_FOREGROUND,false);
   ChartRedraw();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferFractUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferFractDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Advanced Fractal Overlay");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferFractUP,true);
   ArraySetAsSeries(BufferFractDN,true);
//--- create handles
   ResetLastError();
   handle_fr=iFractals(NULL,PERIOD_CURRENT);
   if(handle_fr==INVALID_HANDLE)
     {
      Print("The iFractals object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartSetInteger(0,CHART_FOREGROUND,prev_fgnd);
   ChartRedraw();
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferFractUP,0);
      ArrayInitialize(BufferFractDN,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fr,UPPER_LINE,0,count,BufferFractUP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_fr,LOWER_LINE,0,count,BufferFractDN);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      SettingCandle(i,open,high,low,close);
      ENUM_TREND_TYPE trend_type=TrendType(rates_total,i,close);
      BufferColors[i]=(trend_type==TREND_TYPE_BULLISH ? 0 : trend_type==TREND_TYPE_BEARISH ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| SettingCandle                                                    |
//+------------------------------------------------------------------+
void SettingCandle (const int shift,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   BufferCandleOpen[shift]=open[shift];
   BufferCandleHigh[shift]=high[shift];
   BufferCandleLow[shift]=low[shift];
   BufferCandleClose[shift]=close[shift];
  } 
//+------------------------------------------------------------------+
//| TrendType                                                        |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE TrendType(const int rates_total,const int shift,const double &close[])
  {
   double last_fractal_up=0,last_fractal_dn=0;
   bool found_up=false,found_dn=false;
   int i=shift+1;
   while(!found_up && i<rates_total-1)
     {
      if(BufferFractUP[i]>0 && BufferFractUP[i]<EMPTY_VALUE)
        {
         last_fractal_up=BufferFractUP[i];
         found_up=true;
        }
      i++;
     }
   i=shift+1;
   while(!found_dn && i<rates_total-1)
     {
      if(BufferFractDN[i]>0 && BufferFractDN[i]<EMPTY_VALUE)
        {
         last_fractal_dn=BufferFractDN[i];
         found_dn=true;
        }
      i++;
     }
   if(current==TREND_TYPE_BEARISH)
     {
      if(close[shift]>last_fractal_up)
         current=TREND_TYPE_BULLISH;
     }
   if(current==TREND_TYPE_BULLISH)
     {
      if(close[shift]<last_fractal_dn)
         current=TREND_TYPE_BEARISH;
     }
   return current;
  }
//+------------------------------------------------------------------+
