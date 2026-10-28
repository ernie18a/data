//+------------------------------------------------------------------+
//|                                                  Trend_Score.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend score oscillator by Tushar S.Chande"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot TrendScore
#property indicator_label1  "TrendScore"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_METHOD_PRICE
  {
   PRICE_OPEN_CLOSE,    // Open/Close
   PRICE_CLOSE_CLOSE    // Close/Close
  };
//---
enum ENUM_METHOD_PERIOD
  {
   PERIOD_USE_ON,       // Use period
   PERIOD_USE_OFF       // Do not use period
  };
//--- input parameters
input ENUM_METHOD_PRICE    InpMethodPrice    =  PRICE_OPEN_CLOSE; // Price method
input ENUM_METHOD_PERIOD   InpMethodPeriod   =  PERIOD_USE_ON;    // Period method
input uint                 InpPeriod         =  10;               // Period
input int                  InpOverbought     =  5;                // Overbought
input int                  InpOversold       = -5;                // Oversold
//--- indicator buffers
double         BufferTrendScore[];
double         BufferRAW[];
//--- global variables
double         overbought;
double         oversold;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought=(fabs(InpOverbought)<0 ? 0 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>0 ? 0 : -fabs(InpOversold));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTrendScore,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend score ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTrendScore,true);
   ArraySetAsSeries(BufferRAW,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   int max=(InpMethodPeriod==PERIOD_USE_ON ? period : 4);
   if(rates_total<fmax(max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTrendScore,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
     }

//--- Расчёт индикатора
   double PrevPrice=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(InpMethodPeriod==PERIOD_USE_ON)
        {
         PrevPrice=(InpMethodPrice==PRICE_OPEN_CLOSE ? open[i] : close[i+1]);
         BufferRAW[i]=(close[i]>PrevPrice ? 1 : close[i]<PrevPrice ? -1 : 0);
         double sum=0;
         if(i<rates_total-period)
           {
            sum=0;
            for(int j=0; j<period; j++)
               sum=sum+BufferRAW[i+j];
           }
         BufferTrendScore[i]=sum;
        }
      //--- PERIOD_USE_OFF
      else
        {
         PrevPrice=(InpMethodPrice==PRICE_OPEN_CLOSE ? open[i] : close[i+1]);
         if(close[i]>PrevPrice)
            BufferTrendScore[i]=(BufferTrendScore[i+1]>=0 ? BufferTrendScore[i+1]+1 : 1);
         else if(close[i]<PrevPrice)
           {
            BufferTrendScore[i]=(BufferTrendScore[i+1]<0 ? BufferTrendScore[i+1]-1 : -1);
           }
         else
            BufferTrendScore[i]=BufferTrendScore[i+1];
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
